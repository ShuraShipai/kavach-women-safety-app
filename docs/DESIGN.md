# Kavach Design Reference

## Evidence and limits

Inspected sibling directory: [`../../kavach-design`](../../kavach-design). Primary visual source is `all_screens.html`; screen numbering and flow notes are in `SCREEN_FLOW_AUDIT.md`. The HTML is a static design deck: 50 mobile screen frames at 390 × 844 CSS px plus 15 reusable popup/sheet examples. It has no executable app behavior. `PRODUCT.md` and `UI_IMPLEMENTATION_PLAN.md` contain older references to 51 frames. This document follows the current 50-screen HTML and screen-flow audit.

Values below are observed in source styles and should guide implementation, not be treated as proof of a complete production design system. Where no asset or explicit rule establishes a value, it is marked unverified.

## Verified visual tokens

### Colors

| Token | Value | Use in deck |
|---|---|---|
| Brand crimson | `#711832` | Primary buttons, selected states, emphasis, logo lockup. |
| Warm cream | `#F8F6F2` | Screen and gallery background in the deck's final design-system overrides. |
| Charcoal | `#242326` | Main text and bottom navigation surface. |
| Cool gray | `#ECE9E4` | Secondary surface, dividers, inactive controls in the deck's final design-system overrides. |
| Surface white | `#FFFFFF` (`#fff`) | Cards, inputs, primary-action text. |

Additional colors occur for alert/status details and shadows; they are not a documented semantic palette. Do not promote them into tokens without review. Note: `app_icon.svg` uses a separate red `#D6204A`; do not silently substitute it for the current screen-deck crimson.

### Typography

- Font stack in HTML: `-apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", system-ui, sans-serif`.
- No font files are present in the design directory. SF Pro Text is a preferred system family in the stack, not a bundled/guaranteed cross-platform font. The exact Android-rendered family is therefore unverified.
- Observed sizes: 10–20 px for labels/body/control text; 22–34 px for screen headings; 72/120 px for isolated display/countdown cases. Common body sizes are 13–17 px. Common weights are 500, 600, 650, 700, 750, and 800; fractional weights are browser CSS values and do not map exactly to every Flutter font. Line heights vary by screen, commonly around 1.3–1.5; titles use roughly 1.12–1.25.
- No separate, named type scale is declared by the source. The frequencies above are observed values, not a mandate to use every size.

#### Verified onboarding typography (screens 2–9)

Values below come from inline styles in `all_screens.html`; a line height or letter spacing is listed only where the source explicitly sets one. Text color is the enclosing `#242326` unless noted otherwise.

| Screen/role | CSS values |
|---|---|
| Welcome title | 32 px, weight 700; line-height and letter-spacing unspecified. |
| Welcome feature title | 17 px, weight 600. |
| Welcome feature description | 15 px, line-height 1.35. |
| Welcome/flow primary action | 17 px, weight 600, white on `#711832`; 50 px high, 14 px radius. |
| Onboarding titles (3–6, Home 9) | 34 px, weight 700, letter-spacing 0.3 px; line-height unspecified. |
| Intro/body copy | 15 px; where specified, line-height 1.35 or 1.4. |
| Step labels, form labels, ordinary controls | 17 px; step labels use weight 600. |
| OTP digits | 24 px, weight 600. |
| Permission descriptions and footer captions | 13 px. |
| Profile section label | 13 px, uppercase; no explicit tracking value. |
| PIN prompt/digit | 22 px, weight 700 / 30 px, weight 400. |
| First-contact prompt | 22 px, weight 700; supporting text 15 px, line-height 1.4. |
| Home SOS label | 34 px, weight 800, crimson on white. |
| Home card heading / selected action | 15 px / 17 px with CSS weight 650; platform CSS weight is not guaranteed to map exactly in Flutter. |
| Bottom navigation | 11 px, weight 500, inactive gray with a crimson selected state on translucent cream. |

Flutter tokens for these roles live in `lib/core/design_system/tokens/app_typography.dart`. CSS weight 650 is mapped to Flutter's nearest supported 600. Flutter's default platform family is retained because the source provides only a CSS system stack and no licensed font asset; iOS/Android metric equivalence remains unverified.

### Spacing and layout

- Screen reference canvas: 390 × 844 CSS px. This is the reference composition, not a fixed device-size requirement.
- Common horizontal insets are 16 px for cards/controls and 20 px for screen headings; 28–32 px appear in centered onboarding content. Common vertical increments include 4, 8, 12, 14, 16, and 20 px, but no formal spacing scale is declared.
- Screen content scrolls inside a safe-area-aware mobile composition. The HTML uses a top content inset commonly 44 px and bottom navigation safe-area padding. Exact OS inset behavior must be validated in Flutter.
- Adaptive target is iOS and Android. The gallery scales under 390 px and wraps at larger widths; this responsive gallery behavior does not define app tablet layouts. Tablet, landscape, and foldable behavior remain unverified.

### Components and geometry

- Primary buttons are commonly 50 px high with 14 px radius. Other prominent actions use 46–54 px; popup actions have a 44 px minimum.
- Input rows commonly have a 44 px minimum height. Some keypad buttons are 56 px. Reusable screen targets are at least 44 px in the source, though verify Flutter hit regions and accessibility.
- Card radii commonly 12–16 px; compact icon tiles 8–9 px; gallery device frame 26 px. Pill/switch radii are 99 px.
- Bottom navigation icons are 26 × 26 px, with 11 px labels. Onboarding feature icons are 34 × 34 px; several row icon containers are 25–28 px. These are examples, not a universal icon scale.
- Shadows observed: device frame `0 10px 26px rgba(36,35,38,.10)`; popup card `0 2px 8px rgba(36,35,38,.06)`; toggle thumb `0 2px 4px rgba(0,0,0,.25)`; one emphasis shadow `0 8px 24px rgba(185,35,61,.18)`. The latter uses a different red and should not be copied without design review.
- Inputs, buttons, bottom navigation, cards, dialogs, and sheets appear in the deck. Exact keyboard, focus, pressed, disabled, and full error-state visuals are not comprehensively specified.

## Screens and design assets

The 50 screens are inventoried in `SCREEN_FLOW_AUDIT.md`: Splash, Welcome, authentication/onboarding, Home/Trusted Circle, SOS, Vault, Shield, Journey Guardian, Safety Map, Help, Settings, Offline Kit, Privacy Centre, Readiness/Response Plan, Safe Test, SOS status, trusted-contact response, Fake Call, and Safety Mode/recordings. The deck also has 15 reusable popup/sheet examples. Their presence is visual reference only.

Screens 14–22 now have app routes for the Vault list, incident timeline with delete actions, export preview, recordings list with capture/review, Shield landing page, message input/progress/result, and image/video selection with consent and analysis results. Audio/video recordings and explicitly saved images are encrypted locally and deletable. Image/video analysis requires deploying the Firebase backend and configuring its Resemble secret before it is live.

Assets in the sibling design folder:

| Asset | Verified details | Reference/use |
|---|---|---|
| `kavach_logo_transparent.png` | PNG, 796 × 901, RGBA. | Full lockup used on Splash and Welcome (HTML screens 1–2). Confirm alpha bounds and export/copy into app assets before use. |
| `app_icon.svg` | SVG, viewBox 100 × 100, red rounded square and white shield mark; source canvas declares 512 × 512. | App mark asset. Its red differs from current screen palette. Verify Flutter/platform icon support and export process before using. |
| `Kavach_ Shielded Strength and Hope.png` | PNG, 1254 × 1254, RGB. | Available brand image; no use in current screen deck was verified. |
| Fonts | No font assets listed. | Use platform/system fallback unless licensed font assets are added deliberately. |

The deck also contains inline SVG screen icons; there is no separate icon library in the sibling folder. Prefer a consistent Flutter icon strategy rather than extracting individual glyphs without review.

## Flutter mapping

Implement verified values in centralized Dart token files under `lib/core/design_system/tokens/` (for example color, typography, spacing, radius, and elevation constants), then map semantic colors and text styles into `ThemeData`, `ColorScheme`, and `TextTheme`. Keep widget-specific layout values local only when they are true one-off composition details. Keep assets in the Flutter app's asset directory and declare them in `pubspec.yaml`; do not alter the sibling design source as part of app implementation. Validate system font fallback, safe areas, text scaling, contrast, and responsive behavior on both target platforms before calling the result design-faithful.

## Unverified design decisions

No formal spacing/type scale, semantic success/error palette, dark theme, minimum screen size, tablet rules, Android typeface, focus/keyboard states, or finalized component specification is present. Resolve these from the reference or an explicit product/design decision rather than inventing provenance.
