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

- **Do not** import `session-desk.css`, `dashboard-widgets.css`, etc. into the app.
- **Do not** add homepage-specific rules to `index.css`; use utilities on components.
- Map mockup tokens to existing Tailwind theme: `hubspot-text`, `hubspot-border`, `hubspot-background`, `hubspot-teal`, `text-nav`, `text-menu`, `card`, `muted`, `secondary`, `border-border`.
- Prefer `@/components/ui/*` (`Button`, `Card` patterns, `cn()`) over new primitives.
- Mockup `.card` ≈ `SectionWrapper` surface: `bg-white border border-hubspot-border rounded-lg shadow-sm p-4 sm:p-5` (adjust to match `SectionWrapper`).
- Mockup `.desk-section-heading h2` ≈ `Heading` (`text-nav font-[650] tracking-nudge`).
- Dense stat pills ≈ `StatBadge` pattern, not `LegislativeStats` layout.

When a mockup rule has no utility equivalent, add **component-level** `className` strings; still no new global CSS file.

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
