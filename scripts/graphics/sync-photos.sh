#!/usr/bin/env bash

# sync-photos.sh - Synchronize photos from multiple sources and organize by events
# Usage: sync-photos.sh [--dry-run] [--sync-only] [--group-only]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MONTHS_TO_SYNC=3
TIME_THRESHOLD_DAYS=3
GPS_DISTANCE_THRESHOLD_KM=50
SOURCE_DIR="${HOME}/Photos/synced"
GROUPED_DIR="${HOME}/Photos/grouped"

# SMB configuration
SMB_SERVER="diskstation.local"
SMB_SHARE="homes"
SMB_MOUNT_POINT="/run/user/$(id -u)/gvfs/smb-share:server=${SMB_SERVER},share=${SMB_SHARE}"

# SMB source paths
SMB_PATH_TUC="tuc/Photos/fotky z mobilu/DCIM/Camera"
SMB_PATH_ZIPI="zipi/Photos"
SMB_FULL_PATH_TUC="${SMB_MOUNT_POINT}/${SMB_PATH_TUC}"
SMB_FULL_PATH_ZIPI="${SMB_MOUNT_POINT}/${SMB_PATH_ZIPI}"

# Flags
DRY_RUN=false
SYNC_ONLY=false
GROUP_ONLY=false

# Help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [options]

Synchronize photos and videos from SMB and SD card sources, then organize by events.
Supports: JPG, JPEG, HEIC, MP4, MOV, AVI, MKV (PNG excluded as screenshots).
Automatically removes iPhone Live Photo MOV files when matching HEIC exists.

Options:
    --dry-run          Show what would be done without making changes
    --sync-only        Only sync photos, don't group by events
    --group-only       Only group existing photos, don't sync new ones
    -h, --help         Show this help message

Configuration:
    Source directories:
        - SMB (tuc): smb://${SMB_SERVER}/${SMB_SHARE}/${SMB_PATH_TUC}
        - SMB (zipi): smb://${SMB_SERVER}/${SMB_SHARE}/${SMB_PATH_ZIPI}
        - SD cards: Auto-detected at /media/\$USER/*/DCIM/

    Destination:
        - Synced: ${SOURCE_DIR}
        - Grouped: ${GROUPED_DIR}

    Filters:
        - Sync: All files (rsync --update skips existing)
        - Event time gap: ${TIME_THRESHOLD_DAYS} days
        - Event GPS distance: ${GPS_DISTANCE_THRESHOLD_KM} km

Examples:
    $(basename "$0")                    # Full sync and grouping
    $(basename "$0") --dry-run          # Preview changes
    $(basename "$0") --sync-only        # Only sync new photos
    $(basename "$0") --group-only       # Only organize existing photos

EOF
}

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --sync-only)
            SYNC_ONLY=true
            shift
            ;;
        --group-only)
            GROUP_ONLY=true
            shift
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}" >&2
            show_help
            exit 1
            ;;
    esac
done

# Validate conflicting options
if [ "$SYNC_ONLY" = true ] && [ "$GROUP_ONLY" = true ]; then
    echo -e "${RED}Error: Cannot use --sync-only and --group-only together${NC}" >&2
    exit 1
fi

# Check dependencies
check_dependencies() {
    local missing_deps=()

    for cmd in rsync exiftool gio bc; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Error: Missing required dependencies: ${missing_deps[*]}${NC}" >&2
        echo "Install with: sudo apt-get install ${missing_deps[*]}" >&2
        exit 1
    fi
}

# Mount SMB share if needed
mount_smb() {
    echo -e "${BLUE}Checking SMB mount...${NC}"

    if [ -d "$SMB_MOUNT_POINT" ]; then
        echo -e "${GREEN}SMB share already mounted at ${SMB_MOUNT_POINT}${NC}"
        return 0
    fi

    echo -e "${YELLOW}Mounting SMB share...${NC}"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would mount: smb://${SMB_SERVER}/${SMB_SHARE}${NC}"
        return 0
    fi

    if ! gio mount "smb://${SMB_SERVER}/${SMB_SHARE}" 2>&1; then
        echo -e "${RED}Error: Failed to mount SMB share${NC}" >&2
        echo "Try mounting manually in your file manager first" >&2
        return 1
    fi

    # Wait a moment for mount to be ready
    sleep 2

    if [ ! -d "$SMB_MOUNT_POINT" ]; then
        echo -e "${RED}Error: SMB mount not accessible: ${SMB_MOUNT_POINT}${NC}" >&2
        return 1
    fi

    echo -e "${GREEN}SMB share mounted successfully${NC}"
}

# Auto-detect SD cards (silent, only returns paths)
detect_sd_cards() {
    # Find all DCIM directories under /media/$USER
    find "/media/${USER}" -maxdepth 3 -type d -name "DCIM" 2>/dev/null || true
}

# Sync photos from a source directory
sync_photos_from_source() {
    local source="$1"
    local label="$2"

    echo ""
    echo -e "${BLUE}Syncing photos from ${label}...${NC}"
    echo -e "${YELLOW}Source: ${source}${NC}"

    if [ ! -d "$source" ]; then
        echo -e "${RED}Warning: Source directory not found: ${source}${NC}" >&2
        return 1
    fi

    # Create destination directory
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$SOURCE_DIR"
    fi

    # Build rsync command with filter to exclude iPhone Live Photo MOV files
    # Use whitelist approach: include only photo/video formats, exclude everything else
    # Note: PNG files excluded - they're typically screenshots, not photos

    # Create a temporary filter file to exclude MOV files with matching HEIC
    local filter_file
    filter_file=$(mktemp)
    trap "rm -f $filter_file" EXIT

    # Find all HEIC files in source and create exclude rules for matching MOV files
    find "$source" -type f -iname "*.heic" 2>/dev/null | while read -r heic_file; do
        local basename
        basename=$(basename "$heic_file")
        local base="${basename%.*}"
        # Exclude both .mov and .MOV with same base name
        echo "- ${base}.mov" >> "$filter_file"
        echo "- ${base}.MOV" >> "$filter_file"
    done

    local rsync_cmd=(
        rsync
        -av
        --update
        --progress
        --filter="merge ${filter_file}"
        --include='*/'
        --include='*.jpg'
        --include='*.JPG'
        --include='*.jpeg'
        --include='*.JPEG'
        --include='*.heic'
        --include='*.HEIC'
        --include='*.mp4'
        --include='*.MP4'
        --include='*.mov'
        --include='*.MOV'
        --include='*.avi'
        --include='*.AVI'
        --include='*.mkv'
        --include='*.MKV'
        --exclude='*'  # Exclude all other files
    )

    if [ "$DRY_RUN" = true ]; then
        rsync_cmd+=(--dry-run)
    fi

    # Add source and destination
    rsync_cmd+=("${source}/" "${SOURCE_DIR}/")

    # Execute rsync
    echo -e "${YELLOW}Running rsync...${NC}"
    if ! "${rsync_cmd[@]}"; then
        echo -e "${RED}Warning: rsync encountered errors${NC}" >&2
        return 1
    fi

    # Organize files into year-based directories
    echo -e "${YELLOW}Organizing files by year...${NC}"
    local organized_count=0
    local duplicate_count=0
    local collision_count=0

    find "${SOURCE_DIR}" -maxdepth 1 -type f 2>/dev/null | while read -r file; do
        # Get year from file modification time
        local year
        year=$(stat -c %Y "$file" | xargs -I{} date -d @{} +%Y)

        # Create year directory
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "${SOURCE_DIR}/${year}"
        fi

        local basename
        basename=$(basename "$file")
        local target="${SOURCE_DIR}/${year}/${basename}"

        # Handle filename collisions
        if [ -f "$target" ]; then
            local target_size file_size
            target_size=$(stat -c %s "$target" 2>/dev/null || echo "0")
            file_size=$(stat -c %s "$file" 2>/dev/null || echo "0")

            if [ "$target_size" -eq "$file_size" ]; then
                # Same size = likely duplicate, skip
                if [ "$DRY_RUN" = false ]; then
                    rm "$file"
                fi
                ((duplicate_count++))
            else
                # Different size = collision, add timestamp
                local timestamp base ext
                timestamp=$(stat -c %Y "$file")
                base="${basename%.*}"
                ext="${basename##*.}"
                target="${SOURCE_DIR}/${year}/${base}_${timestamp}.${ext}"

                if [ "$DRY_RUN" = false ]; then
                    mv "$file" "$target"
                fi
                ((collision_count++))
            fi
        else
            # No collision, move normally
            if [ "$DRY_RUN" = false ]; then
                mv "$file" "$target"
            fi
            ((organized_count++))
        fi
    done

    if [ "$organized_count" -gt 0 ] || [ "$collision_count" -gt 0 ] || [ "$duplicate_count" -gt 0 ]; then
        echo -e "${GREEN}Organized: ${organized_count} files${NC}"
        if [ "$collision_count" -gt 0 ]; then
            echo -e "${YELLOW}Renamed: ${collision_count} files (name collision)${NC}"
        fi
        if [ "$duplicate_count" -gt 0 ]; then
            echo -e "${YELLOW}Skipped: ${duplicate_count} duplicates${NC}"
        fi
    fi

    echo -e "${GREEN}Sync from ${label} complete${NC}"
}

# Phase 1: Sync photos from all sources
sync_all_photos() {
    echo -e "${GREEN}=== Phase 1: Syncing Photos ===${NC}"

    # Mount and sync from SMB
    if mount_smb; then
        # Sync from tuc photos
        if [ -d "$SMB_FULL_PATH_TUC" ]; then
            sync_photos_from_source "$SMB_FULL_PATH_TUC" "SMB (tuc)"
        else
            echo -e "${YELLOW}Warning: SMB path not found: ${SMB_FULL_PATH_TUC}${NC}"
        fi

        # Sync from zipi photos
        echo ""
        if [ -d "$SMB_FULL_PATH_ZIPI" ]; then
            sync_photos_from_source "$SMB_FULL_PATH_ZIPI" "SMB (zipi)"
        else
            echo -e "${YELLOW}Warning: SMB path not found: ${SMB_FULL_PATH_ZIPI}${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping SMB sync due to mount failure${NC}"
    fi

    # Sync from SD cards
    echo ""
    echo -e "${BLUE}Detecting SD cards...${NC}"

    local sd_cards
    mapfile -t sd_cards < <(detect_sd_cards)

    if [ ${#sd_cards[@]} -eq 0 ] || [ -z "${sd_cards[0]}" ]; then
        echo -e "${YELLOW}No SD cards detected${NC}"
    else
        for sd_path in "${sd_cards[@]}"; do
            echo -e "${GREEN}Found SD card: ${sd_path}${NC}"
            sync_photos_from_source "$sd_path" "SD Card"
        done
    fi

    echo ""
    echo -e "${GREEN}Photo sync complete!${NC}"
}

# Extract EXIF data for a photo
get_photo_exif() {
    local photo="$1"
    local date gps_lat gps_lon

    # Try multiple EXIF date fields in order of preference
    # DateTimeOriginal - when photo was taken (camera)
    # CreateDate - when file was created (camera)
    # MediaCreateDate - for video files
    # DateTimeDigitized - when photo was digitized
    # SubSecDateTimeOriginal - more precise timestamp
    date=$(exiftool -s -s -s -d "%Y-%m-%d %H:%M:%S" -DateTimeOriginal "$photo" 2>/dev/null || \
           exiftool -s -s -s -d "%Y-%m-%d %H:%M:%S" -CreateDate "$photo" 2>/dev/null || \
           exiftool -s -s -s -d "%Y-%m-%d %H:%M:%S" -MediaCreateDate "$photo" 2>/dev/null || \
           exiftool -s -s -s -d "%Y-%m-%d %H:%M:%S" -DateTimeDigitized "$photo" 2>/dev/null || \
           exiftool -s -s -s -d "%Y-%m-%d %H:%M:%S" -SubSecDateTimeOriginal "$photo" 2>/dev/null || \
           echo "")

    # Get GPS coordinates
    gps_lat=$(exiftool -s -s -s -n -GPSLatitude "$photo" 2>/dev/null || echo "")
    gps_lon=$(exiftool -s -s -s -n -GPSLongitude "$photo" 2>/dev/null || echo "")

    # Return as pipe-separated string
    echo "${date}|${gps_lat}|${gps_lon}"
}

# Calculate distance between two GPS coordinates (Haversine formula)
calculate_distance() {
    local lat1=$1 lon1=$2 lat2=$3 lon2=$4

    # If any coordinate is empty, return large distance
    if [ -z "$lat1" ] || [ -z "$lon1" ] || [ -z "$lat2" ] || [ -z "$lon2" ]; then
        echo "999999"
        return
    fi

    # Haversine formula using bc
    local R=6371 # Earth radius in km

    local distance
    distance=$(bc -l <<EOF
        define rad(deg) { return deg * 4 * a(1) / 180; }
        define haversine(lat1, lon1, lat2, lon2) {
            dlat = rad(lat2 - lat1);
            dlon = rad(lon2 - lon1);
            a = s(dlat/2)^2 + c(rad(lat1)) * c(rad(lat2)) * s(dlon/2)^2;
            c = 2 * a(sqrt(a)/sqrt(1-a));
            return $R * c;
        }
        haversine($lat1, $lon1, $lat2, $lon2)
EOF
)

    echo "$distance"
}

# Calculate days between two dates
days_between() {
    local date1=$1 date2=$2

    if [ -z "$date1" ] || [ -z "$date2" ]; then
        echo "999999"
        return
    fi

    local epoch1 epoch2
    epoch1=$(date -d "$date1" +%s 2>/dev/null || echo "0")
    epoch2=$(date -d "$date2" +%s 2>/dev/null || echo "0")

    local diff=$(( (epoch2 - epoch1) / 86400 ))
    # Return absolute value
    echo "${diff#-}"
}

# Phase 2: Group photos by events
group_photos_by_events() {
    echo ""
    echo -e "${GREEN}=== Phase 2: Grouping Photos by Events ===${NC}"

    if [ ! -d "$SOURCE_DIR" ] || [ -z "$(ls -A "$SOURCE_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}No photos found in ${SOURCE_DIR}${NC}"
        return
    fi

    # Create temp file for photo data
    local temp_data
    temp_data=$(mktemp)
    trap "rm -f $temp_data" EXIT

    echo -e "${YELLOW}Extracting EXIF data from photos...${NC}"

    # Extract EXIF data for all photos and videos
    local photo_count=0
    while IFS= read -r photo; do
        local exif_data
        exif_data=$(get_photo_exif "$photo")
        echo "${photo}|${exif_data}" >> "$temp_data"
        ((photo_count++))

        if (( photo_count % 50 == 0 )); then
            echo -e "${YELLOW}Processed ${photo_count} photos...${NC}"
        fi
    done < <(find "$SOURCE_DIR" -mindepth 2 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.heic" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" \))

    echo -e "${GREEN}Processed ${photo_count} photos${NC}"

    # Sort by date
    sort -t'|' -k2 "$temp_data" -o "$temp_data"

    echo -e "${YELLOW}Clustering photos into events...${NC}"

    # Group photos into events
    local current_event=""
    local event_letter="A"
    local prev_date="" prev_lat="" prev_lon=""
    local no_date_photos=0

    while IFS='|' read -r photo date lat lon; do
        local event_dir
        local year_month

        if [ -z "$date" ]; then
            # Photos without date go to "unknown-date" folder
            event_dir="${GROUPED_DIR}/unknown-date"
            ((no_date_photos++))

            if [ "$DRY_RUN" = false ]; then
                mkdir -p "$event_dir"
            fi
        else
            # Extract year-month for event naming
            year_month=$(echo "$date" | cut -d' ' -f1 | cut -d'-' -f1,2)

            # Check if this should be a new event
            local new_event=false

            if [ -z "$current_event" ]; then
                # First event
                new_event=true
            else
                # Check time difference
                local days_diff
                days_diff=$(days_between "$prev_date" "$date")

                # Check GPS distance
                local gps_dist=0
                if [ -n "$lat" ] && [ -n "$lon" ] && [ -n "$prev_lat" ] && [ -n "$prev_lon" ]; then
                    gps_dist=$(calculate_distance "$prev_lat" "$prev_lon" "$lat" "$lon")
                    gps_dist=${gps_dist%.*} # Convert to integer
                fi

                # New event if time gap > threshold OR distance > threshold
                if (( days_diff > TIME_THRESHOLD_DAYS )) || (( gps_dist > GPS_DISTANCE_THRESHOLD_KM )); then
                    new_event=true
                fi
            fi

            # Create new event if needed
            if [ "$new_event" = true ]; then
                current_event="${year_month}-${event_letter}"
                echo -e "${BLUE}New event: ${current_event}${NC}"

                # Increment letter
                event_letter=$(echo "$event_letter" | tr 'A-Y' 'B-Z')
                if [ "$event_letter" = "Z" ]; then
                    event_letter="AA"
                fi
            fi

            # Set event directory
            event_dir="${GROUPED_DIR}/${current_event}"
            if [ "$DRY_RUN" = false ]; then
                mkdir -p "$event_dir"
            fi

            # Update previous values
            prev_date="$date"
            prev_lat="$lat"
            prev_lon="$lon"
        fi

        # Copy photo to event directory
        local photo_name
        photo_name=$(basename "$photo")
        local target="${event_dir}/${photo_name}"

        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would copy: ${photo} -> ${target}${NC}"
        else
            if [ ! -f "$target" ]; then
                cp "$photo" "$target"
            fi
        fi
    done < "$temp_data"

    # Report photos without date
    if [ "$no_date_photos" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Warning: ${no_date_photos} photos without EXIF date placed in 'unknown-date' folder${NC}"
    fi

    echo ""
    echo -e "${GREEN}Photo grouping complete!${NC}"
    echo -e "${GREEN}Grouped photos are in: ${GROUPED_DIR}${NC}"
}

# Main execution
main() {
    echo -e "${GREEN}Photo Synchronization Script${NC}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}=== DRY RUN MODE ===${NC}"
        echo ""
    fi

    # Check dependencies
    check_dependencies

    # Execute based on flags
    if [ "$GROUP_ONLY" = false ]; then
        sync_all_photos
    fi

    if [ "$SYNC_ONLY" = false ]; then
        group_photos_by_events
    fi

    echo ""
    echo -e "${GREEN}All done!${NC}"
}

main
