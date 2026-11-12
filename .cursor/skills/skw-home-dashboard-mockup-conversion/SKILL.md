---
name: skw-home-dashboard-mockup-conversion
description: >-
  Converts Skywolf (skw) home-experience mockups into Home dashboard React
  sections using the SessionOverview structure and Tailwind utilities only.
  Use when the user asks to port web/public/mockups/home-experience into
  web/src/pages/Dashboard/Home, or mentions Home dashboard mockup conversion,
  SessionOverviewSection, SectionHeadingWrapper superseding SectionHeader,
  or Tailwind-only homepage sections.
---

# Home dashboard — mockup → React conversion

**When:** User asks to port `web/public/mockups/home-experience/` into the live Home dashboard (`web/src/pages/Dashboard/Home/`).

**Do not** start conversion unless explicitly requested. This skill defines structure and styling standards only.

## Source of truth

| Layer | Location |
| --- | --- |
| Visual + interaction spec | `web/public/mockups/home-experience/` (`README.md`, `session-desk.js`, `dashboard-widgets.js`, HTML) |
| Target implementation | `web/src/pages/Dashboard/Home/components/` |
| Page shell | `web/src/pages/Dashboard/Home/index.tsx` |

Read mockup README for section names, filters, sample-data boundaries, and a11y. Treat mockup JS as behavior spec, not code to paste.

## Preferred section tree (canonical)

Follow `SessionOverviewSection.tsx` and its children:

```
SectionWrapper                    → card chrome (border, shadow, spacing)
  SectionHeadingWrapper + Heading → title row + collapse control
  *Stats / *Summary / *Filters   → data blocks (hooks inside leaf)
  *Timeline / *Content           → remaining section body
```

| File | Role |
| --- | --- |
| `SectionWrapper` | One white dashboard card; `section` + Tailwind (`bg-card`, `border-border`, `rounded-lg`, …) |
| `SectionHeadingWrapper` | Header toolbar; collapse/expand uses `@/components/ui/button` |
| `Heading` | Section title typography only; no fetch logic |
| `SessionStats` | Calls `useStat()` (or section hook); maps rows to `StatBadge` |
| `StatBadge` | Presentational stat cell; loader variant |
| `SessionTimeline` | Body subtree (timeline, tables, charts) |

**Section composer** (`*Section.tsx`) stays thin: compose wrappers + children, no `useStat` / API unless unavoidable.

## Heading supersession (replaces page `SectionHeader`)

Converted sections **own** title + collapse in the card. Page-level `SectionHeader` (icon, chevron, `defaultSections.label`) is **legacy** — remove it for that `sectionId` when the new section ships.

| Layer | Responsibility |
| --- | --- |
| `Heading` | Visible `h2` + mockup title typography (`text-nav`, `font-[650]`, …) |
| `SectionHeadingWrapper` | Title row chrome + collapse/expand control (mockup desk-section-heading toolbar) |
| `*Section.tsx` | Pairs wrapper + heading; title string lives here (may differ from ColumnManager label) |
| `index.tsx` `SectionHeader` | **Do not render** for ids already using the wrapper combo |

**Collapse:** Mockup parity puts toggle on `SectionHeadingWrapper`, not the old chevron header. Wire `aria-expanded`, `aria-label`, and body visibility inside the section (local state or props from page `openSections` / Expand–Collapse All when coordinated).

```tsx
// ❌ BAD — new card header + old page header (duplicate title, two toggles)
{sectionId === 'stats' && openSections.has(sectionId) ? <SessionOverviewSection /> : null}
<SectionHeader title={section.label} isOpen={…} onToggle={…} />
{openSections.has(sectionId) && (/* legacy body or second copy of section */)}
```

```tsx
// ✅ GOOD — section is full card; page only mounts it in the registry slot
{sectionId === 'stats' && <SessionOverviewSection />}
```

When converting `bookmarks`, `quickAccess`, etc.:

1. Add `SectionHeadingWrapper` + `Heading` inside `*Section.tsx` (match mockup section name from README/JS).
2. Drop `SectionHeader` + outer `mb-6` wrapper branch for that id in `renderSection`.
3. Keep `defaultSections[].label` for **Customize / ColumnManager** only unless product wants labels unified.
4. Sections not yet converted keep `SectionHeader` until their `*Section` includes the heading pair.

## Anti-pattern — current Legislative Stats block in `index.tsx`

```tsx
// ❌ BAD — page owns data + renders legacy shared widget inline
const { sessionDay, billPosted, … } = useStat();
{sectionId === 'stats' && (
  <div className="bg-linear-to-b …">
    <LegislativeStats legislature={sessionName} sessionDays={sessionDay} … />
  </div>
)}
```

Problems to avoid when replacing stats / other sections:

- Page-level hook with many destructured fields passed as props
- `LegislativeStats` in `components/ui/` as the home section implementation
- Section markup + loading + gradient wrapper inside `renderSection` switch
- Inline helpers (`QuickAccessCard`, `SectionHeader`) growing in `index.tsx` instead of `components/`
- `SectionHeader` left in place after adding `SectionHeadingWrapper` + `Heading` inside the new section (double heading)

```tsx
// ✅ GOOD — page only mounts section; section owns hook
{sectionId === 'stats' && <SessionOverviewSection />}
```

## `HomePage` responsibilities (keep narrow)

Allowed in `index.tsx`:

- Welcome header, Expand/Collapse All, Customize (`ColumnManager`)
- Section registry (`defaultSections`), order/visibility persistence (`useColumnConfiguration`)
- `renderSection` → render **one** `*Section` component per id (no parallel `SectionHeader` for converted ids)
- Collapse state keyed by section id; for converted sections, prefer driving `SectionHeadingWrapper` (lift state only if Expand/Collapse All must stay page-level)

Not allowed for new homepage work:

- New section UI trees or stat grids
- Data hooks for a single dashboard card (except page-wide orchestration)
- Copying mockup CSS into `index.css` or new `.css` files under `Home/`

## Mockup CSS → Tailwind

**Do not** import `session-desk.css`, `dashboard-widgets.css`, or any other mockup stylesheet. **Do not** add homepage rules to `index.css`. Resolve the computed style for each node at each viewport, then put only the winning declarations on the component that owns that node.

A class block in isolation is not the style. Descendants inherit from ancestors, ancestor selectors restyle children, and a later stylesheet overrides an earlier one.

### Stylesheet order

`index.html` loads, in this order:

1. `../bill-experience/styles.css` — `:root` tokens (`--ink: #283f50`, `--line: #e4e9ee`, …)
2. `dashboard.css`
3. `session-desk.css` — `.home-demo` replaces those tokens (`--ink: #33475b`, `--line: #e5e8eb`, `--muted: #64748b`, `--teal`, `--bg`) and sets the font stack
4. `session-workspace.css`
5. `app-shell.css`
6. `dashboard-widgets.css`
7. `bills-demo.css`
8. `dashboard-customization.css`

At equal specificity, the later file wins. Read `var(--ink)`, `var(--line)`, `var(--muted)`, and `var(--teal)` from the ancestor that sets them (`.home-demo`, not `:root`), then map the computed value onto the existing theme: `hubspot-text`, `hubspot-border`, `hubspot-background`, `hubspot-teal`, `text-nav`, `text-menu`, `card`, `muted`, `secondary`, `border-border`.

### Walk parent → child

For each element being ported, collect every matching rule from the outermost ancestor inward:

1. Inherited properties and custom properties on ancestors (`color`, `font`, `line-height`, `letter-spacing`, `--*`).
2. Descendant and child selectors that target this node (`.desk-session .session-stat`, `.desk-section-heading > small`, `.desk-view .desk-section-heading h2`).
3. The element's own class.
4. Later rules and state (`:hover`, `:focus-visible`, `.is-today`, `[aria-current]`). Then repeat the walk for each `@media` viewport — a query does not erase the wider-screen winners.

Port the winner for each property. Example — Session Overview stats:

| Rule | Declares | Inside `.desk-session` |
| --- | --- | --- |
| `.session-stat` | `padding: 10px 12px` | loses to `.desk-session .session-stat` → `padding: 6px 10px` |
| `.session-stat strong` | `font-size: 24px` | loses to `.desk-session .session-stat strong` → `font-size: 22px; margin-top: 2px` |
| `.desk-section-heading` | `margin-bottom: 17px` | loses to `.desk-session .desk-section-heading` → `margin-bottom: 8px` |

Put `6px 10px` and `22px` on the stat cell, not the earlier base rule. Same for any other section: if the node sits under `.home-demo`, `.desk-view`, or `.desk-session`, those ancestor rules are in scope.

### Where the utility goes

- Parent layout and inherited type (`display`, `gap`, `color`, font stack, custom properties) → the parent `className` (`SectionWrapper`, heading row). Children inherit; do not restate the same computed value on every leaf.
- A descendant selector's winning properties → the child component, not the parent.
- A parent rule that only paints one element (`h2`, `small`, `strong`, `> span`) → that child's `className`. No global element CSS.

### Preserve each viewport

The unscoped rule is only the winner above the first matching breakpoint. A `max-width` block does not beat a more specific ancestor: `.desk-session .session-stat strong` (`22px`) still wins over `.session-stat strong` (`25px`) inside `max-width: 740px`.

Mockup queries are desktop-first `max-width`, plus `min-width: 1600px` on the shell and `prefers-reduced-motion`. Resolve those ranges first. The utilities you write are mobile-first — see below. Do not leave `max-*` in the ported `className`.

Section widths: `1250px`, `1200px`, `1100px`, `1023px`, `740px`, `600px`. Shell-only: `1023px`, `640px`, `min-width: 1600px`. Leave the production app shell alone unless that chrome is part of the requested port.

Keep the behavior, not just the column count:

- Column steps. `.desk-view .session-stat-grid` is 7 columns, then 4 at `≤1200px`, then 2 at `≤740px`. `.home-demo .dashboard-summary-widgets` is 3 columns — the later rule in `dashboard-widgets.css` beats the 2-column rule in `session-workspace.css` — and 1 column at `≤1023px`.
- Divider direction when a row stacks. At `≤1023px`, discovery and tracked summaries drop `border-left` and the following sibling gets `border-top`. Port the parent grid and the child border.
- Scroll instead of wrap, including rules that have no `@media`. The schedule week (`repeat(7, minmax(145px, 1fr))` inside `.schedule-week-scroll`), the session timeline (`.session-progress-scroll`), and tables (`min-width: 850px` inside `.new-bills-table-scroll`) scroll horizontally at every width. At `≤740px`, `.week-calendar-grid.is-week` becomes `repeat(7, 500px)` inside that scroll container.
- Heading and filter stacks (`flex-direction: column`, `width: 100%`, `align-items: flex-start`) at `740px` and `600px`.
- Motion. Do not copy the universal `prefers-reduced-motion` rule into `index.css`. If the ported component adds a transition, gate it with `motion-reduce:`.

### Rewrite `max-width` to mobile-first

Once each range has a winner, invert desktop-first queries. Unprefixed utilities are the narrowest range. Wider ranges add `min-*` utilities. Do not emit `max-*`.

For each property:

1. Order the ranges narrow → wide.
2. Unprefixed class = the winner in the narrowest range, after specificity. A `max-width` declaration that loses to an ancestor is not the base.
3. Each wider range that changes the value steps up at one pixel above the `max-width` it leaves (`max-width: 740px` covers 0–740; the next band starts at 741).
4. Snap that step to a default Tailwind screen when the screen is within 80px of the query (inclusive). This app does not override the defaults: `sm` 640, `md` 768, `lg` 1024, `xl` 1280, `2xl` 1536. Nearest screen for the mockup queries: `600`/`640` → `sm`, `740` → `md`, `1023`/`1100` → `lg`, `1200`/`1250` → `xl`, `1600` → `2xl`.
5. If two queries on the same property both fall within 80px of one screen and their winners differ, snap only the closer query. Leave the other as `min-[query+1px]:` so the bands do not collapse. `1023` beats `1100` for `lg`; `1250` beats `1200` for `xl`.
6. When the narrow rule adds a property the wide rule does not have, reset it on the next band (`border-t` below `lg`, `lg:border-t-0`).
7. Omit a variant that repeats the same computed value.
8. A source `min-width` query is already mobile-first; snap it with the same 80px rule. `prefers-reduced-motion` stays `motion-reduce:`. Outside 80px, use `min-[query+1px]:`. Do not invent new `--breakpoint-*` tokens.

Session stat grid, winners 2 / 4 / 7. `740` is 28px from `md`; `1200` is 80px from `xl`:

```
grid-cols-2 md:grid-cols-4 xl:grid-cols-7
```

Discovery summaries, 1 column through 1023px and 3 above:

```
grid-cols-1 lg:grid-cols-3
```

Stacked divider through 1023px, vertical rule from 1024px:

```
border-t border-l-0 lg:border-t-0 lg:border-l
```

Prefer `@/components/ui/*` (`Button`, `Card` patterns, `cn()`) over new primitives.

- Mockup `.home-demo .card` (white surface, `--line` border, 8px radius, light shadow) ≈ `SectionWrapper`: `bg-white border border-hubspot-border rounded-lg shadow-sm p-4 sm:p-5` (adjust to the wrapper that already exists).
- Mockup `.desk-view .desk-section-heading h2` (`font-size: 15px; font-weight: 650; letter-spacing: -.2px`), after the `.desk-session` margin override on the heading row ≈ `Heading` (`text-nav font-[650] tracking-nudge`).
- Dense stat pills ≈ `StatBadge`, using the `.desk-session .session-stat` winners, not `LegislativeStats` and not the unscoped `.session-stat` padding.

When a winning declaration has no utility, add a **component-level** arbitrary value on that node. Still no new global CSS file.

## File placement

- One mockup dashboard section → `components/<Name>Section.tsx` (+ siblings: `<Name>Stats.tsx`, `<Name>Timeline.tsx`, …).
- Reusable outside Home → `web/src/components/` only if a second page needs it; default colocate under `Home/components/`.
- Hooks: `web/src/hooks/` (e.g. `useStat`); section leaves call hooks, composers do not.

## Architecture (inherits `frontend-patterns.mdc`)

- Fetch/transform/state → hook
- Section/leaf components → JSX + hook calls + Tailwind
- `index.tsx` → composition + dashboard chrome only

## Module exports (prefer named)

**New** Home dashboard components from mockup conversion → **named exports**, not `export default`.

| Rule | Detail |
| --- | --- |
| Define | `export function SessionOverviewSection() { … }` (name matches filename) |
| Import | `import { SessionOverviewSection } from './components/SessionOverviewSection'` |
| Barrel | Optional `components/index.ts` re-exports; still named only |
| Existing files | Many siblings still `export default` — leave until you edit that file; then convert file + its importers in same change |

Why: stable names in imports, better refactor/search, consistent with preferred app patterns for new UI.

```tsx
// ❌ BAD — new scaffold
export default function DiscoverySection() { … }
import DiscoverySection from './components/DiscoverySection';

// ✅ GOOD
export function DiscoverySection() { … }
import { DiscoverySection } from './components/DiscoverySection';
```

`HomePage` in `index.tsx` may stay a named page export (`export function HomePage`) as today; section leaves under `components/` follow named-export rule when added or touched.

## Conversion checklist (per section)

1. Identify mockup block in README + JS (e.g. Session Overview, Discovery row).
2. Scaffold `*Section.tsx` mirroring `SessionOverviewSection` composition (`SectionWrapper` → `SectionHeadingWrapper` + `Heading` → body leaves); use **named exports** for new files.
3. Remove page `SectionHeader` (and redundant open guard wrapper) for that id so the new heading pair is the only section title + collapse UI.
4. Port styles from mockup CSS to Tailwind on the smallest leaf components.
5. Wire real hooks where production data exists; keep mockup sample data only in stories/tests until wired.
6. Replace inline `index.tsx` branch for that section with `<FooSection />` only (no legacy header row).
7. Leave `web/public/mockups/home-experience/` unchanged unless user asks to sync demos.

## Reference map (mockup → React target)

| Mockup concept | Target component pattern |
| --- | --- |
| Session Overview card (stats + timeline) | `SessionOverviewSection` tree (extend, don’t duplicate in page) |
| Legislative / desk KPI strip | `SessionStats` + `StatBadge` (not `LegislativeStats` on Home) |
| Desk section heading + collapse | `SectionHeadingWrapper` + `Heading` (replaces `SectionHeader` in `index.tsx` for that section) |
| Other dashboard sections (Bookmarks, Discovery, …) | New `*Section.tsx` siblings, same wrapper pattern |
