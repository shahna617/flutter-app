# Guardly design rules (Forest Green, glass)

Read this file before creating or changing ANY screen or widget. All three team members and the AI agent must follow it so every screen looks like one app.

Visual reference: https://claude.ai/artifact/SzFryfawAVL1eAJbnGbRAS (the "Forest student", "Forest admin" and "Forest management" boards). The Management web dashboard follows section 13.

Style in one line: calm, professional, forest green and sage on a pale green-white base, soft glass cards, one floating pill bottom bar, fully rounded buttons.

## 1. Hard rules

- Never hardcode colors, font sizes, radii or spacing in screens. Use the shared theme tokens only.
- Build tokens ONCE in `lib/core/theme/` and reuse everywhere. No second theme, no per-screen styles.
- Reuse the shared widgets (section 7). If one is missing, add it to `lib/core/widgets/` first.
- Use only the colors in section 2. No gradients on buttons, no emoji as icons.
- Material 3 (`useMaterial3: true`), light theme only.
- Fix layout issues in the shared widget, never with one-off padding in a single screen.

## 2. Colors

| Token | Hex | Use |
|---|---|---|
| primary | #1F5238 | main buttons, key text accents, active nav label and icon |
| primarySoft | #DDE9E0 | role chip, icon tiles, filter chip (selected) |
| navActive | #D3E1D8 | active tab pill in the bottom bar |
| background | #F6F8F6 | screen base (gradient below) |
| textPrimary | #0F2A1D | headings and body (never pure black) |
| textMuted | #52695B | meta text, labels, subtitles |
| border | #DCE5DF | outlines, outline button border |
| onPrimary | #FFFFFF | text and icons on primary |
| glowA | #3F8A62 | background glow circle (top right), 30% opacity |
| glowB | #7DB596 | background glow circle (mid left), 35% opacity |
| pending | bg #F7E9C6, text #7A5A0B | status chip |
| inReview | bg #D3E1D8, text #1F5238 | status chip |
| resolved | bg #D6EFD9, text #14532D | status chip (light green, never the solid primary) |
| danger | #B42318 | reject and destructive actions only |

Screen background: gradient `#F6F8F6` to `#EEF3EF` to `#DCE7DE` (160 degrees) with two blurred circles (glowA top right, glowB mid left, blur about 42) behind content so the glass blur is visible.

Hex values were estimated from the design screenshots. To change a color, edit it here and in the theme file only.

## 3. Typography

Font: Plus Jakarta Sans (`google_fonts` package), weights 400, 500, 600, 700. Change the font in ONE place (theme) if the team picks another.

| Style | Size | Weight |
|---|---|---|
| greeting | 30 | 700 |
| screenTitle | 22 | 700 |
| sectionTitle | 20 | 700 |
| cardTitle | 16-18 | 600-700 |
| body | 14-15 | 400, textMuted for descriptions |
| meta | 12-13 | 400, textMuted |
| chip | 12 | 600 |
| statNumber | 30 | 700 |

Sentence case. No ALL CAPS except the small overview label ("REPORT OVERVIEW · 11 OCT", 13, letter spacing 0.3, textMuted).

## 4. Spacing system (strict 4/8 grid)

Allowed spacing values ONLY: 4, 8, 12, 16, 20, 24. Nothing else (no 18, 22, 15).

- Screen horizontal padding: 20, left and right always equal.
- Vertical gap between sections and cards: 16.
- Card inner padding: 16 (hero or main card 18 is not allowed, use 16 or 20 and keep it the same across all main cards).
- Gap inside a card between its elements: 12.
- Top padding below the status bar: 56 (use SafeArea plus 16 in Flutter).
- Scroll content bottom padding: 120 (nav height 68 + bottom offset 24 + 28 breathing room), so the last item is never hidden behind the nav.

## 5. Shape and elevation

- Card radius: 24. Inner boxes and icon tiles: 16. Buttons, chips, filter chips, bottom bar: fully rounded (999).
- Minimum tap target 44x44. Primary buttons 52 high.
- Shadow: `0 8 24` at 10% of #1F5238. Bottom bar uses `0 12 28` at 16%. Never black shadows.

## 6. Glass recipe

Normal cards and the bottom bar are glass:

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(24),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.66),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.85)),
        boxShadow: [BoxShadow(color: const Color(0xFF1F5238).withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: child,
    ),
  ),
)
```

Keep the glow circles in `AppScaffold` so the blur always has something to show.

## 7. Shared components

- `AppScaffold` - gradient and glow circles, SafeArea, a scrollable body with bottom padding 120, and the bottom bar placed OUTSIDE the scroll view (see section 8).
- `GlassCard` - the recipe above.
- `AppHeader` - shield logo and "Guardly" (22/700, primary) on the left, role chip (Student or Admin) on the right. Same on every screen.
- `PrimaryButton` - height 52, full width inside its card, pill, primary fill, white text 16/700, optional leading icon 20. Max one per card.
- `OutlineButton` - height 52, pill, 1.5 primary border, primary text (for "Submit a new report").
- `OutlineDangerButton` - same shape, danger border and text (Reject).
- `StatusChip` - pill, padding 12x5, 12/600. Values: pending, inReview, resolved.
- `StatsRow` - see section 9. Never build stats with Row and spaceBetween.
- `ReportCard` - GlassCard with top line (ID and date in meta style on the left, StatusChip on the right), title (16/600), location (13 muted), optional extra meta line (12 muted, admin only), chevron on the right, vertically centered. Whole card is tappable.
- `SectionHeader` - title (20/700) left, action text (14/600, primary) right, baseline aligned.
- `FilterChips` - horizontally scrollable pills; selected uses primarySoft with primary text 600, others transparent with border.
- `AppBottomNav` - see section 8.
- `AppTextField` - white 60% fill, radius 16, 1px border, focus border primary, label above.
- `IconTile` - 52x52, radius 16, primarySoft, primary outline icon 26.

Icons: outline style, 1.8 stroke, 20-26 px, one icon set only (Lucide or Material outlined).

## 8. Bottom bar (must be fixed)

- The bar is a floating glass pill: radius 999, height 68, 20 from left and right, 24 from the bottom (plus the device safe-area inset), padding 6.
- It is FIXED. It must never scroll with the page. Build it as `Scaffold(extendBody: true, bottomNavigationBar: ...)` or a `Stack` with the scroll view below and the bar on top. Never put it inside the `ListView` or `SingleChildScrollView`.
- Tabs are equal width (`Expanded`), each 56 high, icon 22 above label 12.
- Active tab: navActive pill background, primary icon and bold label. Inactive: transparent, textMuted, weight 500.
- Student tabs: Home, Submit, My reports. Admin tabs: Home, Queue, Alerts.
- Because it floats, every scrollable screen needs bottom padding 120.

## 9. Symmetry rules

- Stats (Your reports / Open / Resolved, or Pending / In review / Resolved): exactly 3 equal columns using `Row` with three `Expanded` children (or a 3-column grid). Each cell is centered: number (30/700) over label (13 muted), 2 gap. On the Student home the three stats sit inside one GlassCard with 16 vertical padding and thin dividers (1px, primary at 14%) between cells. On the Admin overview they sit inside the overview card above the button with no dividers. Never left-align stats and never use `spaceBetween`.
- Left and right padding of every element on a screen is equal (20). No element may touch or exceed these margins, except full-bleed backgrounds.
- Cards in the same list have the same height behavior, padding, radius and internal layout.
- Chips on the same row are the same height. Buttons in a row are the same height and width (use `Expanded`).
- Text alignment is consistent per area: headings and card text left aligned, stats and tab labels centered.

## 10. Screen patterns

Student
- Home: AppHeader, greeting (30/700) and subtitle (15 muted), GlassCard with IconTile + "Here to help you feel safe", description and PrimaryButton "Submit a report", StatsRow card, SectionHeader "Recent reports" / "View all", ReportCards.
- My reports: title "Your reports, in one place", subtitle, FilterChips (All, Pending, In review, Resolved), count line ("3 reports · Newest first"), ReportCards, info text, OutlineButton "Submit a new report".
- Submit form: category dropdown, description, photo or video upload, location dropdown, anonymous toggle, PrimaryButton "Submit report".

Admin
- Home: AppHeader (Admin), greeting "Welcome back, Alex", overview GlassCard (label, StatsRow, PrimaryButton "Open report queue"), SectionHeader "Awaiting review" / "View queue", ReportCards with the reporter and category line.
- Review detail: media preview, details, face-match panel (primarySoft), then OutlineDangerButton Reject and PrimaryButton Approve side by side (equal width). Show "Rejection needs two admins · X of 2 so far".

## 11. States

- Loading: skeleton GlassCards. Empty: short muted text and one action. Error: one plain sentence in danger color inside the card, no raw exceptions. Success: short snackbar ("Report submitted"), no exclamation marks.

## 12. Do and don't

Do: use the spacing scale, shared widgets, equal columns, the fixed bottom bar.
Don't: use spacing values outside the scale, add colors not listed, use pure black, put the bottom bar inside a scroll view, build custom card styles per screen.

## 13. Management web app (Next.js, desktop)

Same brand as the mobile app: same colors (section 2), same font, same radius language and the same status and role styling. Put all tokens in ONE CSS variables file (`:root`) and reuse them. Never hardcode hex values in components. The same 4/8 spacing scale applies; on desktop use 8, 12, 16, 24, 32.

### 13.1 Page shell (fixed, never scrolls away)

- Left sidebar: width 240, full height, FIXED. Background `#EAF0EB` (slightly darker than the page), 1px right border `#DCE5DF`.
  - Top: shield logo and "Guardly" (22/700, primary), padding 24.
  - Nav items (Dashboard, Accounts, Face Registration, Settings): height 44, radius 12, icon 20 outline plus label 14/500, gap 12, horizontal padding 12, items 4 apart. Inactive: textMuted. Active: `navActive` (#D3E1D8) background, primary text and icon, weight 600.
  - Bottom: small lock icon and "Campus management" (12 muted) above a 1px top divider.
- Top bar: height 72, FIXED/sticky, white (or glass at 80% white), 1px bottom border `#DCE5DF`, horizontal padding 32.
  - Left: page title ("Management Dashboard", 18/600).
  - Right: search field (width 320, height 40, radius 12, border `#DCE5DF`, search icon 16, placeholder muted), 1px vertical divider, then user chip: 36 circle avatar with initials (primarySoft background, primary text 12/600), name 13/600 over role 12 muted, chevron.
- Main content: scrolls under the top bar. Padding 32 left and right, 24 top, 32 bottom. Max content width 1200, left aligned to the same edge as the page title block. Sidebar and top bar never scroll with the content.

### 13.2 Dashboard layout (top to bottom, section gap 32)

1. Welcome row: left "Welcome back, {name}" (28/600) with subtitle (14 muted) below; right a primary button "+ Create Account" (height 40, radius 10, primary fill, white text 14/600, icon 16). The button is vertically aligned with the heading block.
2. Stat cards: exactly 3 equal columns (`grid-template-columns: repeat(3, 1fr)`, gap 16). Each card: padding 20, radius 14, 1px border `#DCE5DF`, white at 80% with glass blur. Top row: label (13 muted) left and outline icon (18, primary) right. Then number (32/600, textPrimary), then caption (12 muted). Cards: Student Accounts, Admin Accounts, Face Registrations. All three cards have identical height and identical internal alignment.
3. Quick Actions: section title (16/600), then ONE card split into 2 equal halves with a 1px vertical divider. Each half: 40 icon tile (radius 12, primarySoft), title 14/600, description 12 muted, arrow icon on the far right. The whole half is clickable (hover: background primarySoft at 40%).
4. Recent Accounts: header row with title (16/600) and subtitle (13 muted) on the left, and "View all accounts" link with arrow (13/600, primary) on the right. Below it the table card (13.3).

### 13.3 Data table

- Card: radius 14, 1px border, white at 80% (use higher opacity than mobile glass so text stays crisp). Header row and body rows live in one card with 1px row dividers (`#DCE5DF`).
- Header row: height 48, labels 12/500 muted, background `#F3F7F4`.
- Body rows: height 48-52, text 13, hover background `#F3F7F4`.
- Columns use fixed proportions so headers and cells always align on the same left edge: Name 24%, Email 30%, Role 14%, Department 22%, Actions 10% (right aligned). Header text starts exactly at the same x as the cell text below it.
- Name cell: 32 circle avatar with initials (white fill, 1px border, 11/500) plus name (13/600), gap 12.
- Role badge: pill, padding 4x10, 12/500. Student: background `#EEF3EF`, text `#52695B`. Admin: background `#D3E1D8`, text primary (600).
- Actions: pencil icon and "more" (three dots) icon, 18, textMuted, 32x32 hit areas, gap 8; hover primary.
- Footer row: "Showing N most recent accounts" (12 muted), padding 16 20.
- Long tables paginate or scroll inside the card. Never let the page body scroll sideways. Below 1024 width the table scrolls horizontally inside its card.

### 13.4 Other management pages

- Accounts: same shell, a title row with search and "Create Account", filter chips (All, Student, Admin), the same table component with pagination.
- Face Registration: form card (photo upload, name, department, register number) with PrimaryButton "Register face", and the same table component below for registered students. Only registered, consented students are listed.
- Create Account: modal or side panel (radius 20, white at 90% with blur), fields use `AppTextField` style, buttons right aligned (secondary then primary, equal height 40).
- Use the same chip colors from section 2 for any status.

### 13.5 Web symmetry and fixed-element rules

- Three stat cards, two quick-action halves and all table columns are equal or proportional grids, never margins guessed by hand.
- Every block in the main area starts at the same left edge (32) and ends at the same right edge. No block may be narrower or offset.
- Sidebar and top bar are fixed and never scroll with the page. Content has top padding for the top bar.
- Icon sizes: 16 in buttons and inputs, 18-20 in cards and nav. One outline set only.
- Buttons on the web are radius 10 (not pills); chips and badges are pills; inputs are radius 12.
- Responsive: below 1280 the stat cards stay 3 columns; below 1024 the sidebar collapses to icons only (width 72) and stat cards stack to 1 column.

## 14. Prompt line for the agent

Start every UI task with: "Follow DESIGN.md (section 13 for the Management web app). Use the shared theme and widgets only, keep the bottom bar fixed outside the scroll view, stats in three equal centered columns, spacing only from the 4/8 scale, and change only the files this task needs."
