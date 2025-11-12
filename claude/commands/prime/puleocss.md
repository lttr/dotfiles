---
allowed-tools: Bash(curl:*)
description: Load Puleo CSS library into context for styling
argument-hint:
---

## Context

Puleo CSS library implementation: `~/code/puleo/`

**Main library file:**
!`curl -s https://cdn.jsdelivr.net/npm/@lttr/puleo/output/puleo.post.css`

**Custom media queries:**
!`curl -s https://cdn.jsdelivr.net/npm/@lttr/puleo/output/media.css`

## Your task

You are now primed with the **Puleo CSS library** - a custom CSS design system. When working with CSS, Vue, Svelte, or similar files requiring styling, you MUST prefer Puleo's custom properties and utility classes.

## Available Custom Properties

### Spacing (Fluid & Responsive)
- `--space-1` through `--space-9` - Base spacing scale
- `--space-1-2`, `--space-2-3`, etc. - Fluid ranges between steps
- `--space-3-5`, `--space-4-6` - Larger fluid ranges

### Typography
- Font sizes: `--font-size--2` (smallest) through `--font-size-5` (largest)
- Weights: `--font-weight-3` through `--font-weight-7`
- Line heights: `--font-lineheight-0` (1.1) through `--font-lineheight-4` (1.75)

### Colors
**Primitives:** `--gray-1` through `--gray-12`, `--red-1` through `--red-12`, `--green-1` through `--green-12`, `--blue-1` through `--blue-12`, `--purple-3`, `--purple-7`

**Semantic tokens (prefer these):**
- Text: `--text-color-1`, `--text-color-2`, `--text-color-1-inverse`, `--text-color-2-inverse`
- Surfaces: `--surface-0` through `--surface-4`, `--surface-0-inverse` through `--surface-4-inverse`
- Brand: `--brand-color`, `--brand-color-dim`, `--brand-color-bright`
- Links: `--link-color`, `--link-color-visited`
- States: `--positive-color`, `--negative-color`
- Alerts: `--error-alert-color`, `--error-alert-bg-color`, `--positive-alert-color`, `--positive-alert-bg-color`

### Shadows
- `--shadow-1` through `--shadow-6` - Elevation shadows
- `--inner-shadow-1` through `--inner-shadow-4` - Inset shadows

### Borders & Radius
- `--radius-1` (2px) through `--radius-4` (2rem), `--radius-round` (fully rounded)
- `--border-size-1` (1px), `--border-size-2` (2px)
- `--border-1` through `--border-5` - Semantic border combinations

### Layout
- `--grid-max-width`, `--grid-gutter`, `--grid-columns`
- `--size-content-1` through `--size-content-3` - Content max-widths
- `--size-xxs` through `--size-xxl` - Breakpoint values

### Easing
- `--ease-1` through `--ease-4` - Cubic bezier timing functions

## Available Utility Classes

### Layout Patterns
- **`.p-page-layout`** - Full page layout with grid breakout system
- **`.p-container`** - Centered container with max-width and gutter padding
- **`.p-grid`** - CSS Grid with gutter spacing
- **`.p-auto-grid`** - Responsive auto-fit grid (customize with `--auto-grid-min`, `--auto-grid-repeat`)
- **`.p-layout-wrapper`** - Sticky footer layout (header/main/footer)

### Grid Breakout System
Use inside `.p-page-layout` for content width control:
- **`.p-inset`** - Narrowest area
- **`.p-content`** - Default content width (auto-applied to all children)
- **`.p-popout`** - Wider than content
- **`.p-full`** - Full viewport width, removes border-radius
- **`.p-full-bg`** - Full-width background with nested layout
- **Variants:** `.p-content-padded`, `.p-popout-start`, `.p-full-end`, `.p-inset-start`, etc.

### Flexbox Patterns
- **`.p-stack`** - Vertical stack with `--stack-space` gap (default: `var(--space-5)`)
- **`.p-cluster`** - Horizontal wrapping with `--cluster-space` gap (default: `var(--space-3)`)
- **`.p-center`** - Centered flex column
- **`.p-switcher`** - Responsive layout switching at `--switcher-treshold` (default: `var(--size-content-3)`)
- **`.p-flow`** - Vertical rhythm with `--flow-space` (default: 1em)

### Typography
- **`.p-heading-1`** through **`.p-heading-4`** - Heading styles
- **`.p-prose`** - Long-form content with balanced text, max-width, proper lists
- **`.p-secondary-text-regular`** / **`.p-secondary-text-bold`** - `--font-size--1`
- **`.p-additional-text-regular`** / **`.p-additional-text-bold`** - `--font-size--2`
- **`.p-base-text-bold`** - Bold base text

### Buttons
- **`.p-button`** - Primary button
- **`.p-button-secondary`** - Secondary button (less prominent)
- **`.p-button-brand`** - Brand-colored button

### Forms
- **`.p-form-group`** - Wraps label + input vertically with proper spacing
- **`fieldset`** with **`legend`** - Groups form controls (auto-styled)

## Custom Media Queries

From `media.css` (use with `@media`):

### Preferences
- `--motionOK`, `--motionNotOK` - Motion preferences
- `--OSdark`, `--OSlight` - Color scheme
- `--highContrast`, `--lowContrast` - Contrast preferences
- `--touch`, `--stylus`, `--pointer`, `--mouse` - Input methods

### Breakpoints
- `--xxs-only`, `--xxs-n-above`, `--xxs-n-below` - 0-240px
- `--xs-only`, `--xs-n-above`, `--xs-n-below` - 240-360px
- `--sm-only`, `--sm-n-above`, `--sm-n-below` - 360-480px
- `--md-only`, `--md-n-above`, `--md-n-below` - 480-768px
- `--lg-only`, `--lg-n-above`, `--lg-n-below` - 768-1024px
- `--xl-only`, `--xl-n-above`, `--xl-n-below` - 1024-1440px

Example usage:
```css
@media (--md-n-above) {
  /* Styles for 768px and wider */
}
```

## Usage Guidelines

### DO:
- ✅ Use utility classes: `.p-stack`, `.p-cluster`, `.p-grid`, `.p-button`
- ✅ Use custom properties in CSS: `padding: var(--space-4);`
- ✅ Write CSS in `<style>` blocks or separate CSS files
- ✅ Use semantic tokens: `var(--text-color-1)`, `var(--surface-2)`
- ✅ Customize via CSS custom properties: `--stack-space: var(--space-3);`
- ✅ Prefer fluid spacing: `var(--space-3-5)` over fixed values

### DON'T:
- ❌ Use inline styles: `style="padding: 16px"`
- ❌ Use arbitrary values: `padding: 16px;`, `color: #333;`
- ❌ Use primitives when semantic tokens exist: prefer `--text-color-1` over `--gray-12`
- ❌ Write custom flexbox/grid when utility classes exist
- ❌ Use media queries with pixel values when custom media queries exist

## Examples

### Layout with Grid Breakout
```html
<div class="p-page-layout">
  <header class="p-full-bg">
    <div class="p-content">
      <nav class="p-cluster">
        <a href="/">Home</a>
        <a href="/about">About</a>
      </nav>
    </div>
  </header>

  <main class="p-stack">
    <article class="p-prose">
      <h1>Article Title</h1>
      <p>Content with automatic max-width and flow...</p>
    </article>
  </main>
</div>
```

### Component Styling
```css
/* In a .css file or <style> block */
.card {
  background-color: var(--surface-1);
  border-radius: var(--radius-2);
  padding: var(--space-4);
  box-shadow: var(--shadow-2);
}

.card-title {
  color: var(--text-color-1);
  font-size: var(--font-size-2);
  font-weight: var(--font-weight-6);
  margin-block-end: var(--space-3);
}
```

### Vue/Svelte Component
```vue
<template>
  <div class="p-stack">
    <h2 class="p-heading-2">Section Title</h2>
    <div class="p-auto-grid">
      <div class="card">Card 1</div>
      <div class="card">Card 2</div>
    </div>
  </div>
</template>

<style scoped>
.card {
  background: var(--surface-2);
  padding: var(--space-4);
  border-radius: var(--radius-2);
}

/* Customize utility class */
.p-stack {
  --stack-space: var(--space-3);
}

.p-auto-grid {
  --auto-grid-min: 250px;
}
</style>
```

### Responsive with Custom Media
```css
.sidebar {
  display: none;
}

@media (--lg-n-above) {
  .sidebar {
    display: block;
  }
}
```

## Rules

1. **ALWAYS** use Puleo custom properties and utility classes when styling
2. **NEVER** use inline styles - write CSS in `<style>` blocks or separate files
3. **NEVER** use arbitrary values like `padding: 16px` or `color: #333`
4. **PREFER** semantic tokens (`--text-color-1`) over primitives (`--gray-12`)
5. **PREFER** utility classes over custom CSS when applicable
6. **PREFER** custom media queries over pixel-based media queries
