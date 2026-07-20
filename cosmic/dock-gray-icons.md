# COSMIC dock: grayscale app icons

How the bottom-panel app icons were muted from colorful brand logos to grayscale, plus the dead ends worth not retrying.

## Setup

COSMIC on PopOS. App launcher icons live in the **Panel** (moved to the bottom), applet `com.system76.CosmicAppList`. Favorites: `~/.config/cosmic/com.system76.CosmicAppList/v1/favorites` (tracked here as `applist/favorites`).

Display: single Samsung 1920x1200, scale 100%, rotate270. Panel size XS, so app icons render small (~26-32px physical).

## Working method

- Grayscale PNGs at `~/.local/share/icons/dock-gray/<name>.png`, generated with:

  ```sh
  convert SRC -colorspace Gray -filter Lanczos -resize NxN -background none -gravity center -extent NxN
  ```

  `N` must equal the panel's exact render size. Confirmed crisp at `N=32`; tune to taste. Slack comes from its SVG via `rsvg-convert`.

- Shadow `.desktop` files in `~/.local/share/applications/` (highest precedence) copy the originals but set `Icon=` to the **absolute PNG path**. Covers native and flatpak basenames. kitty's own file is edited in place.

- Apply with `pkill -f cosmic-panel` — the session respawns it (exits 144 but comes back).

### Why absolute-path PNG at the exact size

The panel scales any source to its render size with a no-antialiasing (nearest-ish) filter, which comes out jagged. Supplying the PNG at exactly the render size means it displays 1:1, so the Lanczos antialiasing baked into the PNG survives. SVG is also jagged — the panel rasterizes the SVG at its declared size, then nearest-scales that.

## Verification gotcha

`cosmic-screenshot` captures at ~2x (3760px for a 1920px display), i.e. upscaled, which fakes smooth antialiasing on icons that are actually jagged. Screenshots can confirm gray-vs-color but **cannot** judge edge crispness — ask instead.

## Dead ends

- Icon-name override via `~/.local/share/icons/hicolor` or `~/.icons/hicolor` (even after removing a stale `icon-theme.cache`): the panel resolves icon names only against the system theme path, never user dirs. Name-based override is impossible here.
- COSMIC has no per-icon opacity, and brand logos aren't part of icon themes, so theme-switching can't mute them.
- **active-app tile background:** `active_hint` is the wrong knob — it borders focused windows, not panel tiles; left at 0. The tile color comes from the global theme `component.selected`/`hover` grey (~0.29 on Dark). COSMIC has no panel-only setting, and raising it lightens every selected/hovered control system-wide, so this was left alone deliberately. Don't re-attempt.

## Maintenance

Newly pinned apps show in color until a gray PNG plus shadow `.desktop` is added for them.

**Revert:** delete `~/.local/share/icons/dock-gray`, delete the shadow desktop files, restore kitty's `Icon=`, reset `active_hint` to 0. Leftover `~/.icons/hicolor/<size>/apps/<name>.png` gray copies and a copied `index.theme` are inert and can be removed too.
