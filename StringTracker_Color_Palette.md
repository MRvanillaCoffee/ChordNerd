# StringTracker — Color Palette

Dark theme, two-tone violet/pink accent system. Derived from the login screen mockup.

## Backgrounds & surfaces

| Role | Hex | Usage |
|---|---|---|
| Background | `#0A0A0B` | App base / page background |
| Surface / input | `#141416` | Text inputs, input fields |
| Card / raised | `#18181B` | Cards, tab bar container, raised elements |
| Selected / active tab | `#2A2233` | Active tab, selected list item, toggled-on state |
| Border | `#2B2B30` | Hairline borders, dividers |

## Accents

| Role | Hex | Usage |
|---|---|---|
| Accent — primary | `#9D7BFF` | Primary buttons, links, active/interactive elements — keep to this one role |
| Accent — light/icon | `#C9AEFF` | Icons, subtle highlights, secondary icon color |
| Accent — streak/pink | `#FF8FCB` | Streaks, badges, celebratory/gamification moments only — use sparingly |

## Text

| Role | Hex | Usage |
|---|---|---|
| Text — primary | `#F2F2F3` | Headings, primary body text |
| Text — secondary | `#9C9BA2` | Supporting text, labels |
| Text — muted/placeholder | `#6B6A70` | Placeholder text, disabled/hint text |

## Usage guidelines

- **`#9D7BFF`** is the single primary action color — buttons, links, active nav states. Avoid spreading it across too many elements or it loses its "this is interactive" signal.
- **`#FF8FCB`** should stay rare and intentional — reserved for streaks, achievements, and celebratory UI. If it appears everywhere, it stops feeling special.
- **`#2A2233`** is a quiet way to indicate "selected" or "on" without using full-strength violet — good for tab bars, toggles, and selected rows.
- Background tiers (`#0A0A0B` → `#141416` → `#18181B`) create depth through lightness steps alone, with no color tint, keeping the neutral-grey base clean.
