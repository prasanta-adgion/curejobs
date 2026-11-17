# CureJobs — MOBILE-DESIGN.md

The visual language of the CureJobs web app, written down so the mobile app
looks and moves the same way. Every value here is taken from the web code; the
source file is named next to each section so you can check it when the web app
changes.

Values are platform-neutral: colors in hex, sizes in px. Treat 1 web px as
1 dp (Android) or 1 pt (iOS).

---

# 1. Character

CureJobs is a job board for healthcare workers. The look is calm, plain and
trustworthy, closer to a clinic noticeboard than a startup landing page.

- **One brand color.** Violet `#5937F5` marks what you can act on and where you
  are. Everything else is ink, grey and white.
- **Flat surfaces.** Cards have a 1px border and no shadow. Shadows belong only
  to things that float above the page: menus, dialogs, sheets.
- **Soft lavender for "selected" and "here".** The active tab, the current
  menu item and a selected job all use the lavender tint `#F1EEFF`, not a heavy
  fill.
- **Status colors carry meaning, never decoration.** Green means approved or
  published, amber means waiting, red means rejected or an error.
- **Motion answers a touch.** Things open, press and slide in response to the
  user. Nothing loops or bounces for attention.

---

# 2. Colors

Source: `apps/web/app/globals.css` (`:root`), `apps/web/tailwind.config.ts`.

## 2.1 Core palette

| Token | Hex | Use |
|---|---|---|
| `background` / `card` / `surface` | `#FFFFFF` | Screens, cards, sheets, inputs |
| `foreground` (ink) | `#16192E` | Headings, body text, icons on light surfaces |
| `muted-foreground` (ink soft) | `#5B6075` | Secondary text, captions, placeholders, inactive tabs and nav items |
| `primary` (violet) | `#5937F5` | Primary buttons, links, active indicators, focus ring, brand icons |
| `primary-pressed` (violet hover) | `#4826D9` | Primary button pressed/hover state |
| `primary-foreground` | `#FFFFFF` | Text and icons on violet |
| `accent` (violet tint) | `#F1EEFF` | Selected item background, brand badge, info alert, empty-state icon circle |
| `muted` / `secondary` | `#F5F6FA` | Secondary button, neutral badge, disabled input, grey panels |
| `border` / `input` | `#E4E6EE` | Every card, input, divider and list separator |
| `sidebar` | `#EEEBFF` | Workspace side menu / drawer background |
| `sidebar-border` | `#DDD7FB` | Edge of the side menu |
| `success` | `#0E8A6A` | Approved, published, selected, payment done |
| `success-tint` | `#E8FFF6` | Background of success badges and alerts |
| `warning` | `#A86200` | Pending, under review, needs changes, paused |
| `destructive` | `#C4322B` | Rejected, errors, delete actions, invalid fields |
| `overlay` | `#020617` at 50% | Dim layer behind dialogs and bottom sheets |

The app background on the web is a very light grey (`slate-50`, `#F8FAFC`)
behind white content areas. On mobile, use `#FFFFFF` for content screens and
`#F8FAFC` only where white cards sit on a page background.

## 2.2 Tints built from the core palette

The web builds lighter versions by putting a core color over white at a set
opacity. Use the same opacities on mobile.

| Use | Color | Opacity | Approximate hex on white |
|---|---|---|---|
| Brand badge / info alert border | `primary` | 20% | `#DED7FD` |
| Outline button border while pressed | `primary` | 40% | `#BDAFFB` |
| Focus ring around an input | `primary` | 20% | `#DED7FD` |
| Warning badge / alert background | `warning` | 10% | `#F6EFE6` |
| Warning border | `warning` | 20–25% | `#EEE0CC` |
| Danger badge / alert background | `destructive` | 10% | `#F9EAEA` |
| Danger border | `destructive` | 20–25% | `#F3D6D5` |
| Invalid input ring | `destructive` | 15% | `#F6E0DF` |
| Success border | `success` | 20–25% | `#CFE8E1` |
| Job card pressed background | `accent` | 30% | `#FBFAFF` |
| Selected job background | `accent` | 60% | `#F7F5FF` |
| Input border while pressed/hovered | `foreground` | 25% | `#C5C6CB` |
| Skeleton (loading placeholder) | `muted-foreground` | 15% | `#E6E7EA` |

## 2.3 Status colors

Source: `apps/web/components/ui/status-badge.tsx`.

| Tone | Text | Background | Border |
|---|---|---|---|
| neutral | `#5B6075` | `#F5F6FA` | `#E4E6EE` |
| brand | `#5937F5` | `#F1EEFF` | violet 20% |
| success | `#0E8A6A` | `#E8FFF6` | success 20% |
| warning | `#A86200` | warning 10% | warning 20% |
| danger | `#C4322B` | destructive 10% | destructive 20% |

Map statuses to tones exactly as the web does:

| Kind | neutral | warning | brand | success | danger |
|---|---|---|---|---|---|
| Application | Applied, Withdrawn | Under review | Shortlisted | Selected | Rejected |
| Job | Draft, Closed, Expired | Pending review, Paused | — | Published | Rejected |
| Verification | Not submitted, Revoked | Pending, Needs changes | — | Approved | Rejected |

## 2.4 Charts

Series colors in this order: violet `#5937F5`, green `#0F8A6A`, amber
`#A86200`, grey `#5B6075`, red `#C4322B`.

## 2.5 Dark mode

The web app has no dark theme yet. Ship mobile in light mode only until a dark
palette is designed for both.

---

# 3. Typography

Source: `apps/web/app/layout.tsx` (font), component files (sizes).

## 3.1 Typeface

**Onest** (Google Fonts, open license) for everything: headings, body, buttons,
numbers. Weights used: 400 Regular, 500 Medium, 600 Semibold, 700 Bold (logo
only). Bundle these four weights in the app.

Numbers that line up (salaries, counts, prices, dates in tables) use tabular
figures (`fontVariant: ['tabular-nums']` in React Native,
`FontFeature.tabularFigures()` in Flutter).

## 3.2 Type scale

| Role | Size / line height | Weight | Letter spacing | Web source |
|---|---|---|---|---|
| Display (home, contact hero) | 40–42 / 1.08 | 500 | −0.03em | home, contact page `h1` |
| Page title | 24 / 32 (28 / 36 on tablets) | 600 | −0.025em | `page-header.tsx` |
| Section title / dialog title | 20 / 28 | 600 | −0.025em | contact form, dialogs |
| Job title in list | 17 / 1.375 | 600 | 0 | `JobListItem.tsx` |
| Body large / lead | 15 / 1.625 | 400 | 0 | page descriptions, inputs on phones |
| Body (default) | 14 / 20 | 400 | 0 | most text |
| Label / button | 14 / 20 | 500 | 0 | buttons, nav, tabs, form labels |
| Small / caption | 13 / 20 | 400–500 | 0 | badges, helper text, tooltips, meta lines |
| Micro | 11–12 / 16 | 500–600 | 0 | counters, notification dots |

Rules the web follows:

- **Sentence case everywhere.** No all-caps labels, no title case on buttons.
- Headings are tight (negative tracking); body text is not.
- Inputs use 15px on phones so iOS does not zoom when the field is focused.
- Keep body lines under about 70 characters on tablets.

---

# 4. Corner radius

Source: `--radius: 0.75rem` in `globals.css`, `borderRadius` in
`tailwind.config.ts`.

| Token | Value | Use |
|---|---|---|
| `sm` | 6 | Menu items inside a dropdown, extra-small buttons, tags inside inputs |
| `md` | 8 | Buttons, inputs, selects, dropdown panels, tooltips |
| `lg` / `xl` | 12 | Cards, job list items, alerts, popovers, mobile nav rows |
| `2xl` | 16 | Dialogs and bottom sheets (top corners only for sheets) |
| `3xl` | 24 | Large hero panels (rare) |
| `full` | 999 | Badges, avatars, switches, the desktop nav pill, counters |

Hierarchy matters: the bigger and more "container-like" the element, the
larger the radius. Do not use one radius for everything.

---

# 5. Borders, dividers and focus

| Element | Border |
|---|---|
| Card, job item, input, select, outline button | 1px `#E4E6EE` |
| Input or job item while pressed / hovered | 1px ink at 20–25% |
| Input while focused | 1px `#5937F5` plus a 2px ring of violet at 20% outside it |
| Invalid input | 1px `#C4322B` plus a 2px ring of red at 15% |
| Selected job (tablet split view) | 1px `#5937F5`, background violet tint 60%, and a 3px solid violet bar on the inside left edge |
| Active item in mobile nav / side menu | Background `#F1EEFF`, text violet, a 3px rounded violet bar on the left (inset 10px top and bottom) |
| Tab bar | 1px `#E4E6EE` bottom line; the active tab gets a 2px violet underline |
| Header | 1px `#E4E6EE` bottom line, white background, no blur |
| Lists | 1px `#E4E6EE` dividers between rows, plus top and bottom lines on the group |

Keyboard and accessibility focus (for hardware keyboards, switch access and
TV-style navigation): a 2px violet ring, offset 2px from the element.

---

# 6. Elevation

Source: `apps/web/components/ui/card.tsx` comment, popover/select/modal files.

| Layer | Shadow |
|---|---|
| Screen content, cards, list items | **None.** Use the 1px border. |
| Dropdown menu, popover, select list | Large soft shadow tinted with ink at about 5% (`shadow-lg shadow-foreground/5`) |
| Dialog, bottom sheet, side drawer | Strongest shadow (`shadow-2xl`) over the 50% overlay |
| Switch thumb | Small shadow (`shadow-sm`) |

On Android, use elevation 0 for cards, about 8 for menus and about 24 for
dialogs and sheets. On iOS, use shadow color `#16192E` at 5–10% opacity with a
large blur radius (16–24) for menus, and a larger blur (40–50) for sheets.

---

# 7. Spacing and sizes

The web uses a 4px grid. Common steps: 4, 6, 8, 12, 16, 20, 24, 32, 40.

| Thing | Value |
|---|---|
| Screen side padding (phone) | 16 |
| Screen side padding (tablet) | 24–32 |
| Card / job item padding | 16 on phones, 20 on tablets |
| Gap between form fields | 20 |
| Gap between badges / chips | 6 |
| Header height | 64 on phones, 80 on tablets |
| Mobile nav row height | at least 48 |
| Minimum touch target | 44 × 44 (the web's small 32px buttons should grow to 44 on touch) |

## 7.1 Control sizes

| Control | Height | Horizontal padding | Text |
|---|---|---|---|
| Button large (main call to action, full width on phones) | 44–48 | 20 | 15–16 / 500 |
| Button default | 40 | 16 | 14 / 500 |
| Button small | 32 | 12 | 13 / 500 |
| Icon button | 40 × 40 (44 on touch) | — | icon 16 |
| Input / select | 40 (44–48 on touch) | 12 | 15 |
| Textarea | 6 rows | 12 | 15 |
| Badge | 24 | 10 | 13 / 500 |
| Switch | 24 × 44 track, 20 thumb | — | — |
| Tab | 40 | text width, 4px gap | 14 / 500 |
| Avatar | 32–40, round | — | — |

Icons: Lucide icon set, 16px inside buttons and badges (14px in badges), 20px
next to list rows and contact details, stroke width 2. Icons inherit the
text color of their row.

---

# 8. Components

## 8.1 Buttons

Source: `apps/web/components/ui/button.tsx`.

| Variant | Background | Text | Border | Pressed |
|---|---|---|---|---|
| Primary | `#5937F5` | white | none | `#4826D9` |
| Outline | white | ink | `#E4E6EE` | border violet 40%, background `#F1EEFF` |
| Secondary | `#F5F6FA` | ink | none | `#E4E6EE` at 60% |
| Ghost | transparent | ink | none | `#F1EEFF` |
| Destructive | red at 10% | `#C4322B` | none | red at 15% |
| Link | none | violet | none | underline |

Disabled buttons sit at 50% opacity and do not react to touch. A loading
button keeps its width, shows a spinning loader icon and changes its label to
the ongoing action ("Sending…", "Saving…").

Every button except Link gets the press feedback in section 9.4.

## 8.2 Inputs and selects

White background, 1px `#E4E6EE` border, radius 8, placeholder in `#5B6075`.
Focus: violet border and a soft violet ring. Error: red border, red ring,
and an error message in 13px red under the field. Disabled: `#F5F6FA`
background at 60% opacity.

Selects open as a list with radius 8, 4px inner padding and items with radius
6; the highlighted item uses `#F1EEFF`. On phones, prefer a bottom sheet list
for selects with more than about 6 options.

## 8.3 Cards

White, 1px `#E4E6EE` border, radius 12, no shadow, padding 16–20. Card title
16/600, description 14 in `#5B6075`.

## 8.4 Job list item

Source: `apps/web/components/jobs/JobListItem.tsx`.

```
┌──────────────────────────────────────────┐
│ Staff Nurse – ICU                [Boost] │  17 / 600, ink
│ Apollo Hospitals                         │  15 / 400, ink
│ 📍 Kolkata, West Bengal                  │  14, ink soft, 14px pin icon
│ ✓ Matches your specialty                 │  13, ink soft, violet check
│                                          │
│ ₹35,000 – ₹45,000 a month                │  14 / 500, tabular numbers
│ (Full time) (Night shift)                │  neutral badges, 6 gap
│ Posted 2 days ago                        │  13, ink soft
└──────────────────────────────────────────┘
```

Card: radius 12, border `#E4E6EE`, padding 16. Pressed: border ink 20%,
background violet tint 30%, title turns violet. Phones open the job on its
own screen; only the tablet split view uses the "selected" style from
section 5.

## 8.5 Badges

Pill shape (radius full), 1px border, 13/500 text, 10px side padding, optional
6px dot in the same color before the text. Colors from section 2.3.

## 8.6 Alerts

Radius 12, 1px border, 12/16 padding, 16px icon on the left, text in ink.

| Tone | Background | Border | Icon |
|---|---|---|---|
| Info | `#F1EEFF` | violet 20% | violet |
| Success | `#E8FFF6` | green 25% | green |
| Warning | amber 10% | amber 25% | amber |
| Danger | red 10% | red 25% | red |

## 8.7 Tabs

Text tabs on a 1px bottom line. Inactive `#5B6075`, active ink. A single 2px
violet underline slides to the active tab (section 9.3). No filled or boxed
tabs.

## 8.8 Navigation

- **Header:** white, 1px bottom border, logo on the left (40px tall on phones).
- **Mobile menu rows:** 48px tall, radius 12, 16px side padding, 16/500 text.
  Active row: `#F1EEFF` background, violet text and the 3px left bar.
- **Workspace side menu / drawer:** lavender `#EEEBFF` with a `#DDD7FB` edge.
  Count badges are violet pills with white 12/600 text.
- **Bottom tab bar (mobile only, if used):** white, 1px top border, active icon
  and label violet, inactive `#5B6075`. Do not add a filled background behind
  the active tab; the color change is enough.

## 8.9 Dialogs and sheets

Source: `apps/web/components/ui/modal-shell.tsx`.

- Overlay: `#020617` at 50%.
- Dialog: white, radius 16, 1px `#E4E6EE` border, strongest shadow, max width
  672 on tablets, 12px margin from the screen edge on phones.
- Side drawer (web) becomes a **bottom sheet** on phones: top corners radius 16,
  full width. On tablets a right-side drawer up to 430 wide.

## 8.10 Empty states

Centered: a 44px round `#F1EEFF` circle with a 20px violet icon, title 16/600,
one line of help in 14 `#5B6075` (max about 40 characters wide), then one
button that fixes the emptiness ("Browse jobs", "Upload resume").

## 8.11 Toasts

Short confirmations that name the action in the past tense ("Application
sent", "Changes saved"). 16px icon on the left; a spinner icon while work is
still running.

## 8.12 Loading

- Lists and cards: skeleton blocks in grey (`#5B6075` at 15%), radius 8, gently
  pulsing opacity.
- Whole-screen first load: the CureJobs logo with the violet heartbeat line
  drawing across it (web `curejobs-loader.tsx`), 2s loop. With reduced motion,
  show the line fully drawn and still.
- Inside buttons: a 16px spinning loader icon.

---

# 9. Motion

Source: `globals.css` (Motion section), `tailwind.config.ts`,
`components/ui/ripple.tsx`, `modal-shell.tsx`, `NavbarShell.tsx`, `tabs.tsx`.

## 9.1 Curves

| Name | Cubic bezier | Use |
|---|---|---|
| **standard** | `0.2, 0, 0, 1` | Everything that appears, moves or changes state. Starts quickly and settles gently. |
| **exit** | `0.3, 0, 1, 1` | Things leaving the screen (closing dialogs, menus). Accelerates away. |

Use only these two curves. No spring bounce, no linear except for spinners.

## 9.2 Durations

| Speed | Duration | Use |
|---|---|---|
| Instant feedback | 150 | Color changes on press, closing a menu or tooltip |
| Default | 200 | Any state change: borders, backgrounds, opening a menu or tooltip |
| Glide | 300 | Moving indicators: tab underline, nav pill |
| Screen enter | 350 | A new screen or section appearing |
| Dialog enter | 380 | Dialog or sheet opening |
| Dialog exit | 180 | Dialog or sheet closing (always faster than opening) |
| Ripple | 550 | Touch ripple spreading and fading |

## 9.3 Recipes

**Screen enter ("rise")**: fade from 0 to 1 and move up from 8px below to its
place. 350ms, standard curve. Only the content area moves; the header and tab
bar stay still. On mobile, use this for the content inside a screen, and keep
the platform's own push/pop navigation transition.

**Home first load**: heading, text, search box and links rise one after
another, 50ms apart (0, 50, 100, 150ms), each 420ms. Plays once per launch,
finishes within about 600ms.

**Dialog open**: overlay fades in over 240ms. Panel fades in and moves from
16px below at 98.5% size to its place over 380ms, standard curve.

**Dialog close**: panel moves 10px down to 98.5% size and fades out with the
overlay over 180ms, exit curve.

**Bottom sheet / drawer**: slides fully in from off-screen in 380ms, standard
curve; slides out in 180ms, exit curve.

**Menu, popover, tooltip, select list**: grows from its anchor point, from 95%
size and 0 opacity to full, 200ms standard. Closes back to 95% and 0 opacity in
150ms with the exit curve.

**Sliding indicator**: the active tab underline (and the web nav pill) moves
and resizes to the new item in 300ms, standard curve, instead of jumping.

**Expanding a section** (side menu groups, "show more"): animate height from 0
to its content height in 200ms, standard curve.

**Selecting another job (tablet split view)**: the detail panel fades and rises
into the new job's content; it does not reload the whole screen.

**Switch**: thumb slides across in 200ms; track color changes in the same time.

## 9.4 Touch feedback

- **Press scale:** every button except Link shrinks to 98% while pressed and
  returns on release.
- **Ripple:** a circle spreads from the touch point, starting at 22% opacity of
  the button's text color and fading to 0 over 550ms, standard curve. It is
  clipped to the button's rounded shape. Disabled buttons get no ripple.
  - Android: use the native ripple (`android_ripple` in React Native,
    `InkWell` in Flutter) with the button's text color at about 22%.
  - iOS: use the press scale plus a quick background change (section 8.1)
    instead of a ripple, which matches iOS conventions.

## 9.5 Rules

- Animate only opacity and transform (position, scale). Never animate layout
  size per frame except for the expand recipe above.
- No looping or attention-seeking motion on content. Only loading indicators
  loop.
- Never hide content until an animation runs. If the animation is skipped,
  everything must still be visible.
- **Reduced motion:** when the device's "Reduce motion" (iOS) or "Remove
  animations" (Android) setting is on, turn off every animation and transition
  except loading spinners. Things simply appear in their final state.

---

# 10. Tokens for code

Copy this into the mobile app's theme file. Keep names identical so web and
mobile can be compared line by line.

```json
{
  "color": {
    "background": "#FFFFFF",
    "pageBackground": "#F8FAFC",
    "foreground": "#16192E",
    "mutedForeground": "#5B6075",
    "primary": "#5937F5",
    "primaryPressed": "#4826D9",
    "primaryForeground": "#FFFFFF",
    "accent": "#F1EEFF",
    "muted": "#F5F6FA",
    "border": "#E4E6EE",
    "sidebar": "#EEEBFF",
    "sidebarBorder": "#DDD7FB",
    "success": "#0E8A6A",
    "successTint": "#E8FFF6",
    "warning": "#A86200",
    "destructive": "#C4322B",
    "overlay": "rgba(2, 6, 23, 0.5)"
  },
  "font": {
    "family": "Onest",
    "weight": { "regular": "400", "medium": "500", "semibold": "600", "bold": "700" },
    "size": { "micro": 11, "caption": 13, "body": 14, "bodyLarge": 15, "jobTitle": 17, "sectionTitle": 20, "pageTitle": 24, "display": 40 }
  },
  "radius": { "sm": 6, "md": 8, "lg": 12, "xl": 12, "sheet": 16, "hero": 24, "full": 999 },
  "border": { "width": 1, "focusRing": 2, "activeBar": 3, "tabUnderline": 2 },
  "space": { "1": 4, "1.5": 6, "2": 8, "3": 12, "4": 16, "5": 20, "6": 24, "8": 32, "10": 40 },
  "size": { "touchMin": 44, "button": 40, "buttonLarge": 48, "buttonSmall": 32, "input": 44, "header": 64, "navRow": 48 },
  "motion": {
    "easing": { "standard": [0.2, 0, 0, 1], "exit": [0.3, 0, 1, 1] },
    "duration": { "fast": 150, "default": 200, "glide": 300, "screen": 350, "dialogIn": 380, "dialogOut": 180, "ripple": 550 },
    "riseDistance": 8,
    "dialogRiseDistance": 16,
    "pressScale": 0.98,
    "popoverStartScale": 0.95,
    "rippleOpacity": 0.22
  }
}
```

---

# 11. Do not

- Do not add shadows to cards or list items.
- Do not introduce a second brand color, gradients or colored page backgrounds.
- Do not use status colors for decoration.
- Do not use all-caps labels or title-case buttons.
- Do not add bounce, spring overshoot or looping motion on content.
- Do not use one radius for every element.
- Do not ship a dark mode that the web does not have.

When the web tokens change (`globals.css`, `tailwind.config.ts`, the
`components/ui` files), update this document in the same change.
