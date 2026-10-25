---
name: Nocturnal Pulse
colors:
  surface: '#10131a'
  surface-dim: '#10131a'
  surface-bright: '#363941'
  surface-container-lowest: '#0b0e15'
  surface-container-low: '#191b23'
  surface-container: '#1d1f27'
  surface-container-high: '#272a32'
  surface-container-highest: '#32353d'
  on-surface: '#e1e2ec'
  on-surface-variant: '#bacac7'
  inverse-surface: '#e1e2ec'
  inverse-on-surface: '#2d3038'
  outline: '#859491'
  outline-variant: '#3b4a47'
  surface-tint: '#28ddcf'
  primary: '#47efe0'
  on-primary: '#003733'
  primary-container: '#00d2c4'
  on-primary-container: '#00554f'
  inverse-primary: '#006a63'
  secondary: '#d0bcff'
  on-secondary: '#3c0091'
  secondary-container: '#571bc1'
  on-secondary-container: '#c4abff'
  tertiary: '#ffcfa3'
  on-tertiary: '#4a2800'
  tertiary-container: '#ffa94f'
  on-tertiary-container: '#713f00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#56faeb'
  primary-fixed-dim: '#28ddcf'
  on-primary-fixed: '#00201d'
  on-primary-fixed-variant: '#00504a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d0bcff'
  on-secondary-fixed: '#23005c'
  on-secondary-fixed-variant: '#5516be'
  tertiary-fixed: '#ffdcbf'
  tertiary-fixed-dim: '#ffb872'
  on-tertiary-fixed: '#2d1600'
  on-tertiary-fixed-variant: '#6a3b00'
  background: '#10131a'
  on-background: '#e1e2ec'
  surface-variant: '#32353d'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 3.5rem
    fontWeight: '800'
    lineHeight: 4rem
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 2.25rem
    fontWeight: '700'
    lineHeight: 2.75rem
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 1.75rem
    fontWeight: '700'
    lineHeight: 2.25rem
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 1.5rem
    fontWeight: '600'
    lineHeight: 2rem
  body-lg:
    fontFamily: Inter
    fontSize: 1.125rem
    fontWeight: '400'
    lineHeight: 1.75rem
  body-md:
    fontFamily: Inter
    fontSize: 1rem
    fontWeight: '400'
    lineHeight: 1.5rem
  body-sm:
    fontFamily: Inter
    fontSize: 0.875rem
    fontWeight: '400'
    lineHeight: 1.25rem
  label-md:
    fontFamily: Inter
    fontSize: 0.875rem
    fontWeight: '600'
    lineHeight: 1.25rem
  label-sm:
    fontFamily: Inter
    fontSize: 0.75rem
    fontWeight: '500'
    lineHeight: 1rem
  code-xs:
    fontFamily: Inter
    fontSize: 0.6875rem
    fontWeight: '500'
    lineHeight: 0.875rem
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes a high-performance, nocturnal sensory environment tailored for offline, local-first listening across Android and Windows. It merges the focused utility of precision audio engineering with the immersive richness of night-mode listening. 

The aesthetic is anchored in deep obsidian surfaces, crisp geometric typography, and an energetic electric cyan glow. Interfaces prioritize immediate touch accessibility, tactile responsive feedback, and continuous spatial awareness. Surfaces feel layered and weighted rather than flat, framing album art and sound controls with utmost visual clarity without fatiguing the listener during late-night sessions.

## Colors

The palette leverages a nocturnal dark architecture that maximizes OLED battery conservation on mobile while delivering luminous contrast for track navigation and micro-metadata.

- **Primary (`#00D2C4`)**: Electric Cyan serves as the system's core focal point. Used strictly for active play states, progress scrubbers, focused states, and primary callouts.
- **Secondary (`#8B5CF6`)**: Neon Violet injects dynamic depth. Used for secondary active tags, audio visualization highlights, and gradient fills across ambient glow containers.
- **Surface Architecture (`#0A0D14`)**: Pure obsidian base canvas (`#0A0D14`), transitioning to elevated slate (`#131926`) for persistent navigation elements and container layers (`#1A2234`) for cards and modular panels.
- **Text & Foreground**: High-contrast pure white (`#FFFFFF`) for primary titles, soft muted slate (`#94A3B8`) for secondary artists and technical metadata, and low-opacity white (`rgba(255, 255, 255, 0.08)`) for dividers and borders.

## Typography

The typographic hierarchy pairs the friendly, geometric authority of **Plus Jakarta Sans** for large titles, track headings, and system banners with the utilitarian neutrality of **Inter** for dense metadata, track durations, bitrates, and settings labels.

- Use tight tracking on `display-lg` and `headline-lg` to create impact in expanded player views.
- Maintain tabular numeral alignment for all timestamp, sample rate, and track length displays (`body-sm` and `code-xs`).
- Ensure track artist and album secondary lines retain at least `body-sm` sizing on mobile viewports for effortless reading on the go.

## Layout & Spacing

The layout adapts between a fluid 4-column thumb-optimized single-hand grid on Android and a structured 12-column dual-pane configuration on Windows.

- **Mobile (Android)**: 
  - Standard edge margin of `1rem`. 
  - One-handed ergonomics: interactive triggers, playback controls, and scrubbers anchor to the bottom 40% of the display.
  - Floating sticky mini-player maintains a `0.75rem` safe gap from bottom system navigation bars.
- **Desktop (Windows)**:
  - 12-column grid with `1.5rem` gutters and `2rem` screen margins.
  - Persistent left sidebar (240px to 280px fixed width) for library routes, fluid middle pane for tracks/grids, and a bottom docked player shelf (80px height).
- **Component rhythm**:
  - Track list rows enforce a minimum touch height of `48px` (mobile standard `56px`) with `space-sm` internal padding.

## Elevation & Depth

Visual hierarchy uses a hybrid strategy of tonal tiering and subtle translucent acrylic surfaces, eliminating harsh drop shadows in favor of ambient luminescence and low-contrast borders.

- **Base Layer (Elevation 0)**: Flat `#0A0D14` backdrop, absorbing ambient light.
- **Surface Layer (Elevation 1)**: Elevated slate (`#131926`) for persistent sidebars, playlists, and section blocks.
- **Card & Modal Layer (Elevation 2)**: Container background (`#1A2234`) with a fine hairline border: `1px solid rgba(255, 255, 255, 0.08)`.
- **Floating Controls & Mini-Player (Elevation 3)**: Frosted acrylic material created with `background: rgba(19, 25, 38, 0.85)`, `backdrop-filter: blur(16px)`, and a soft cyan ambient halo: `box-shadow: 0 8px 32px -4px rgba(0, 0, 0, 0.6), 0 0 12px 0 rgba(0, 210, 196, 0.12)`.

## Shapes

The system relies on a consistent `roundedness: 2` geometry. This creates soft, approachable corners without drifting into playful or cartoonish forms:

- Standard controls, text fields, and list tiles utilize `0.5rem` (`rounded-md`).
- Album artwork cards, content sections, and modal sheets adopt `1rem` (`rounded-lg`).
- High-level containers, drawer sheets, and the floating mini-player shell use `1.5rem` (`rounded-xl`).
- Filter chips, pill badges, and scrub handle thumbs maintain full circular pill curvature (`9999px`).

## Components

### Buttons & Playback Triggers
- **Primary Play/Pause FAB**: Circular, sized at 56px on mobile and 48px on desktop. Solid `#00D2C4` background with an obsidian `#0A0D14` icon. Active press applies a subtle scale transform (`0.95`).
- **Secondary Action Buttons**: Translucent `#1A2234` fill, white text, 1px perimeter border of `rgba(255, 255, 255, 0.08)`. Hover introduces a 15% opacity Electric Cyan background tint.
- **Icon Controls (Shuffle, Repeat, Skip)**: Sleek, 24px bounding box with 44px tap targets. Inactive icons sit at `#94A3B8`; active states switch to `#00D2C4` with a 4px dot indicator underneath.

### Chips & Filter Badges
- **Library Filter Chips**: Pill-shaped, `space-xs` vertical and `space-md` horizontal padding. Default state: `#131926` background with `rgba(255, 255, 255, 0.1)` border. Selected state: `#00D2C4` text, `rgba(0, 210, 196, 0.15)` fill, and `#00D2C4` border.
- **Format Badges (FLAC, Hi-Res, DSD)**: Monospace micro-pills (`code-xs`), obsidian background, border tinted with `#8B5CF6`, text colored `#8B5CF6`.

### Lists & Track Rows
- **List Items**: Clean 56px row height. Left: 40px rounded album art thumbnail (`rounded-md`). Middle: track name (`body-md`, `#FFFFFF`) stacked above artist and duration (`body-sm`, `#94A3B8`). Right: quick-action menu (three-dot) and offline indicator.
- **Active Track State**: Background transitions to `rgba(0, 210, 196, 0.06)`, track title text switches to `#00D2C4`, with an animated three-bar equalizer graphic replacing the track number.

### Input Fields & Search Bars
- Background set to `#131926` with a default `1px solid rgba(255, 255, 255, 0.08)` border.
- Focus state brings an immediate outline shift to `#00D2C4` accompanied by a soft `0 0 0 3px rgba(0, 210, 196, 0.2)` glow.
- Sized at a comfortable 48px height with built-in clear ("X") buttons and leading search lens icons.

### Cards & Album Containers
- Full-bleed artwork cards maintain a 1:1 aspect ratio with `rounded-lg` corners.
- Hover or focus triggers a smooth upward translate (`-2px`) with an inner glass gloss highlight on top edges (`inset 0 1px 0 rgba(255, 255, 255, 0.15)`).

### Sliders & Scrubbers (Progress & Volume)
- Track background is a 4px tall rounded track using `rgba(255, 255, 255, 0.1)`.
- Filled progress is `#00D2C4` with a smooth 12px circular thumb that scales up to 16px during active dragging. Buffer progress (if applicable) displays in `rgba(255, 255, 255, 0.2)`.

### Persistent Bottom Mini-Player
- Suspended dock with `rounded-xl` corners floating `0.75rem` above the screen edge.
- Integrates a hairline top track progress bar directly integrated along the upper perimeter curve, seamless track playback toggles on the right, and full-width swipe gestures to skip tracks.