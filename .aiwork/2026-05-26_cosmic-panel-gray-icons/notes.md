---
references:
  - "Memory: ~/.claude/projects/-home-lukas-dotfiles/memory/cosmic-dock-gray-icons.md"
artifacts_live_outside_repo: true
---

# COSMIC panel — grayscale app icons

Goal: mute the colorful app-launcher icons in the bottom panel (they were distracting). Outcome: all 11 pinned favorites render **grayscale and crisp**.

## Environment

- COSMIC desktop (PopOS). The icon bar is the **Panel** (moved to bottom), `com.system76.CosmicAppList` applet — not the Dock.
- Favorites: `~/.config/cosmic/com.system76.CosmicAppList/v1/favorites` → firefox, kitty, Ferdium, 1password, obsidian, Slack, Claude, google-chrome, microsoft-edge.
- Mixed native + flatpak: Slack/Edge/Obsidian/Ferdium are flatpaks (`com.slack.Slack`, `com.microsoft.Edge`, `md.obsidian.Obsidian`, `org.ferdium.Ferdium`); rest native.
- Display: single Samsung 1920x1200, **scale 100%**, rotate270. Panel size XS → icons render ~32px physical.

## Working solution

1. Grayscale PNGs at `~/.local/share/icons/dock-gray/<name>.png`, generated at **N=32px** (the panel's exact render size):
   ```
   convert SRC -colorspace Gray -filter Lanczos -resize 32x32 -background none -gravity center -extent 32x32 OUT.png
   ```
   Slack rasterized from its SVG via `rsvg-convert -w 32` then grayed.
2. Shadow `.desktop` files in `~/.local/share/applications/` (highest XDG precedence) copy each original entry but set `Icon=` to the **absolute PNG path**. Covers native + flatpak basenames. kitty's own file edited in place (`Icon=` → the gray PNG).
3. Apply: `pkill -f cosmic-panel` (cosmic-session respawns it; the kill reports exit 144 but the panel comes back).

## Why this exact approach (hard-won)

- **No per-icon opacity** in COSMIC; brand logos aren't part of icon themes, so theme-switching can't mute them.
- **Icon-name override fails.** Putting gray icons in `~/.local/share/icons/hicolor` or `~/.icons/hicolor` (even after deleting a stale `icon-theme.cache`) did nothing — the panel resolves icon *names* only against the system theme path, never user dirs. Name-based is impossible here.
- **Must match render size exactly.** The panel scales any source to its render size with a no-AA (nearest-ish) filter → jagged edges. A 256px PNG or an SVG both came out jagged. A PNG at exactly 32px is displayed **1:1**, so the Lanczos AA baked into the PNG is preserved → crisp. (Confirmed crisp by Lukas.)
- **Screenshot caveat:** `cosmic-screenshot` captures upscaled (~3760px for a 1920px display), which fakes smooth AA on truly-jagged icons. Screenshots can confirm gray-vs-color but **cannot** judge edge crispness — needs human eyes.

## active-app tile background (requested, not done)

Lukas wanted the focused app's panel tile to have a lighter background.
- `active_hint` is the **wrong knob** (borders focused *windows*, not the panel) — tried 4 then 8, no panel effect, reverted to 0.
- The tile color comes from the **global theme** `component.selected`/`hover` grey (~0.29 on Dark). No panel-only setting exists; raising it lightens every selected/hovered control system-wide.
- Decision: **leave as-is** — global side effect not worth it.

## Maintenance / revert

- **New pinned app** shows in color until a gray 32px PNG + shadow `.desktop` is added for it.
- Revert: delete `~/.local/share/icons/dock-gray`, delete the shadow `.desktop` files, restore kitty's original `Icon=`. (active_hint already back at 0.)
- Inert leftovers cleaned up: gray copies in `~/.icons/hicolor` were removed (panel ignored them).
