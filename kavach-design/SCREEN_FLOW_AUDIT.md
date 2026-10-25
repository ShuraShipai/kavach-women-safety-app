# Kavach screen-flow audit — hackathon edition

## Verdict

**PASS as a compact visual blueprint.** The gallery now contains **50 distinct app screens**, with repeated confirmations, validation, empty/error states and routine outcomes represented in 15 reusable popup/bottom-sheet examples. The nearby-police-station concept appears as a compact static marker-detail card on the Safety Map screen.

This is still a static design reference. It does not prove runtime navigation, real station data, call/message delivery, or any other service behavior. I did not perform browser rendering or runtime testing.


## Copy cleanup completed

- Removed the visible destination word beside back chevrons; the arrow remains, with an accessible label in the static markup. Kept explicit **Cancel** and **Close** actions where they perform a different task.
- Removed repeated screen titles on Trusted Circle, contact options, Safe Walk setup, case detail, SOS status, recipient view, and response planning; removed the duplicate **Your data** section label in Privacy Centre. Changed the report form heading to **Report a spot** and removed the duplicate map title.
- Shortened repeated setup, PIN, SOS countdown, Safe Walk, Offline Kit, readiness, and simulation descriptions. Kept consent, offline-service limits, unverified-map warnings, emergency guidance, and truthful delivery/acknowledgement states.
- Removed internal design instructions from SOS status and contact-response copy; replaced them with concise user-facing status text. Applied the supplied transparent logo lockup on Splash, Welcome, and the gallery header; shortened the Welcome title to avoid repeating the logo wordmark.
- Rewrote popup examples as interface copy and consolidated repeated demo/live-data explanations on the nearby-station sheet.
- Harmonized primary crimson buttons and matching accents with the supplied logo's deep burgundy (`#711832`), while retaining white-on-burgundy emergency actions and the white PIN-cancellation button for clear action hierarchy.
- Refined the SOS countdown hierarchy: centered and constrained the safety message, reduced the oversized numeral, clarified that confirmation is required before sending, and kept PIN cancellation as the bottom primary exit.
- Added Voice phrase trigger as a Settings sub-screen, with phrase setup, opt-in, selected response actions, microphone/platform limitations, and an explicit inactive-prototype label. Added a reusable trigger-detected countdown sheet; it uses the configured actions after the countdown unless cancelled. Calls open the dialer for user confirmation.
- Replaced manual Safe Walk check-ins and checkout with an optional Journey Guardian concept. The journey preview keeps **Call 112** and **SOS** visible, shows arrival detection only where supported, provides a delayed-journey prompt, and states that location updates can pause.
- Simplified Safety Map categories to **Reported concerns**, **Poor lighting**, and **Police stations**; gave each marker a distinct shape and legend, identified the user location, and retained the unverified-report limitation.
- Replaced the missed-check-in sheet with a delayed-journey prompt offering **I’ve arrived**, **Running late**, and **Call 112**, with explicit location and safety limitations.
- Simplified journey setup into destination, expected arrival, optional Journey Guardian, optional per-walk Battery Handoff, and one Start action. Replaced the blank Cancel/title row and repeated setup copy with a compact navigation header.
- Fixed the popup gallery’s stretch causes: grid items were stretching to the tallest card in each row, each sample had a 168px minimum height, and narrow breakpoints forced every sample into a viewport-wide single column. The library is now width-constrained with content-aware auto-fit columns; each sample is one white card with its former gray context and inner white sheet wrappers removed. The voice-trigger example was moved into the popup grid. Action buttons use compact 44px targets, two-column layouts when suitable, and content-fitting layouts for multi-choice prompts.
- Replaced fixed 620px PIN and 470px report sheets with content-driven height, bounded scrolling, and safe-area padding. Reduced PIN keypad spacing and targets to 56px. Kept the export dialog and contact action sheet content-sized.
- Simplified combined popup examples so each depicts one state at a time: SOS review no longer stacks delivery outcomes; contact actions, evidence choices, and delete confirmation no longer share unrelated forms or results. Standardized popup action rows to 44px minimum height and prevented status labels from forcing horizontal overflow.
- Kept Safety Map report states visibly distinct as alternatives (submitted, missing details, or unavailable map) and clarified that only one state appears at a time. Clarified that saving a response plan sends no alerts.

## Main journeys

| Journey | Screens and intended transitions | Popup/inline states |
|---|---|---|
| Onboarding | 1 Splash → 2 Welcome → 3 Phone sign-in → 4 Code → 5 Permissions → 6 Profile → 7 PIN → 8 First contact → 9 Home | Invalid/expired code, retry limits, network errors, permission denial, PIN mismatch/confirmation, and contact selection are inline feedback or sheets. |
| Home and Trusted Circle | 9 Home → 10 Trusted Circle → 11 Contact options; add starts from Home or Trusted Circle | Empty circle, contact form/picker, duplicate validation, removal confirmation, and test-message review are component states. Offline, no contacts, and location disabled are Home banners/cards, not separate screens. |
| SOS | 9 Home → 12 Countdown → 13 PIN cancellation or alert-review sheet → 38 SOS status | Wrong PIN/cancel, awaiting confirmation, send failure, sent but delivery unconfirmed, verified delivery, acknowledgement, and response use distinct status/dialog states. They are never presented as equivalent. Screen 39 is the trusted-contact view. Screen 38 now demonstrates separately confirmed sent, delivered, acknowledged, and responding states; screen 39 separates acknowledgement from the contact’s response action. |
| Voice phrase trigger | 28 Settings → 29 Voice phrase trigger → voice-trigger countdown sheet → configured response action → 38 SOS status | The phrase is user-selected. After the short countdown, selected contact/location actions begin unless cancelled with the PIN. A 112 action opens a call screen for user confirmation. This is a static concept; no microphone is active. |
| Vault | 14 Vault → add-evidence sheet → 15 Case timeline → 16 Export preview | Empty Vault, capture/picker permission, save confirmation/failure, export cancellation/failure are reusable states. Export preview does not claim sharing succeeded. |
| Shield | 17 Shield → 18 Message input → 19 Analysis progress → 20 Result; image path 17 → 21 Check image → 22 Result | Invalid input, unavailable analysis, permission/preview, and follow-up guidance use inline feedback or sheets. Analysis remains illustrative. |
| Journey Guardian | 9 Home → 23 Start Journey → optional Guardian → 24 Automatic Monitoring → arrival or exception handling | Arrival detection is a static concept where supported. A delayed journey offers I’ve arrived, Running late, or Call 112. Location updates can pause because of signal, permissions, battery, or background limits. Call 112 and SOS stay visible. |
| Safety Map | 9 Home → 25 Map → select a marker detail card or 26 Report a spot | Categories separate reported concerns, poor lighting, and police stations with distinct marker shapes. User location is visually distinct. Reports remain unverified; the police-station pin is explicitly demo-only and must not be used for navigation. |
| Help | 27 Help → call confirmation/system handoff or Guided Help screen 34; quick safety tools start Fake Call at incoming state 41 or start audio/video recording directly | Cancelled/unavailable handoff and topic guidance are sheets or return states. No call is placed by the gallery. |
| Fake Call | 27 Help → 41 incoming immediately → 42 active simulated conversation → 43 ended → return to Kavach; optional customization is 40 → 41 | Caller name, optional photo, and call timing are static choices. No setup or wait is required for the direct start. The call never connects to a person; SOS remains visible during call states. |
| Safety Mode | 27 Help → direct Start audio/Start video action → 46/47 immediately when access is already available. Screen 44 remains the mode chooser reference; 45 appears only when access is needed; 50 is the unavailable state. Stop → 48 → 49 saved recordings. | Recording, permission, timer, and history states are static. Any required system access step is limited to access that is missing. Recording itself does not send an alert or call emergency services; both recording artboards keep the SOS control in the same top-right header position. Hardware shortcuts remain phone-controlled and are not represented as Kavach recording triggers. |
| Settings and privacy | 9 Home → 28 Settings → 29 Voice phrase trigger; 30 device recovery, 31 calculator, 32 Offline Kit, 33 Privacy Centre | Language selection, battery/Find My handoff, privacy detail, and data-deletion confirmation/results are sheets. Destructive actions require explicit confirmation. |
| Safety Assurance | 9 Home → 35 Readiness → 36 Response Plan or 37 Safe Test; SOS status is 38 and recipient view is 39 | Plan-save and simulation results are modal states. Simulation is clearly marked as sending no real alert. |

## Screen inventory

The 50 full-screen references are: **1** Splash, **2** Welcome, **3** Phone sign-in, **4** Enter code, **5** Permissions, **6** Profile, **7** Set PIN, **8** Add first contact, **9** Home, **10** Trusted Circle, **11** Contact options, **12** SOS countdown, **13** Enter PIN to cancel, **14** Vault, **15** Case detail/timeline, **16** Export preview, **17** Shield, **18** Analyze message, **19** Analyzing, **20** Analysis result, **21** Check image, **22** Image result, **23** Start Journey, **24** Automatic Monitoring, **25** Safety map, **26** Report a spot, **27** Help, **28** Settings, **29** Voice phrase trigger, **30** If my phone dies, **31** Decoy calculator, **32** Offline Safety Kit, **33** Privacy Centre, **34** Guided Help, **35** Safety readiness, **36** Response plan, **37** Safe test simulation, **38** SOS status and response, **39** Trusted contact response view, **40** Fake Call setup, **41** Fake Call incoming, **42** Fake Call active, **43** Fake Call ended, **44** Safety Mode activation, **45** Recording permission explanation, **46** Audio recording, **47** Video recording, **48** Recording stopped, **49** Safety recordings, and **50** Recording unavailable.

Screens 40–43 are the Fake Call flow; screen 40 is optional customization and screen 41 is the direct Help entry. Screens 44–50 are the Safety Mode flow and its saved/unavailable states; recording starts directly when access is already available.

## Consolidation decisions

The following former full-screen frames were moved into reusable visual states to reduce screen count:

- Permission prompt, contact form sheet, Home no-contact/offline/location-disabled variants, delivery-confirmed example, empty Vault, and add-evidence menu.
- Battery Handoff configuration, delayed-journey prompt, call confirmation, language selector, and delete-data confirmation.
- The 39 supplemental recovery/outcome screens from the previous 90-frame version are no longer standalone artboards; their key states are summarized in the flow map and represented with reusable popup patterns.

The standalone screens that change context remain full screens, including the SOS status, recipient response view, Safe Walk active journey, map/report, evidence case, Safety Assurance, Fake Call, and Safety Mode flows. Back controls use a leading chevron with the prior context where known; Cancel and Close remain for modal and external handoff contexts.

## Safety Map markers

Screen 25 uses clear categories and a compact legend for reported concerns, poor lighting, police stations, and the user location. Reports remain unverified and may be outdated; the police-station marker is illustrative and not for navigation. Real use requires a maintained, verified source for station locations and details, with location permission as appropriate; do not present demo stations as nearby or verified in a real app.

## Remaining UI gaps and non-UI dependencies

- Popup examples are reusable patterns, not separate screen-by-screen variants. The Flutter implementation still needs to apply the correct copy and recovery action at each entry point.
- The map’s police station list is demo-only; live nearby results require a data source and location handling.
- OTP authentication, OS permission prompts, Settings handoff, calls, SMS, trusted-contact acknowledgement, emergency messaging, and voice recognition are not functional in this HTML. iOS apps can be suspended in the background and have limited background execution modes; continuous phrase detection must be validated against platform policy and device behavior before it is presented as dependable. [Apple background execution modes](https://developer.apple.com/documentation/Xcode/configuring-background-execution-modes?changes=__8), [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/).
- Journey Guardian background location and arrival detection are static concepts. Any implementation would depend on platform permissions, signal, battery, and background limits and cannot be guaranteed by this design.
- Evidence capture, local storage, export/share, and deletion need implementation; the gallery does not verify secure storage or file integrity.
- Shield analysis, Safety Map reports/moderation, and external recipient response require real services before they can be claimed as working.
- Responsive sizing, accessibility, and safe-area behavior remain to be checked in an actual app/device preview. Fake Call is a static simulation; platform-specific call overlays and alerting are not designed or implemented. Recording permissions, retention, export, and deletion policies remain unresolved.

## Final UI refinement

- Integrated the transparent full-logo asset on Splash, Welcome, and the gallery header.
- Replaced the Safe Walk check-in/checkout flow with optional Journey Guardian setup, concept-only automatic monitoring and arrival detection, delayed-journey choices, and persistent emergency actions.
- Reduced Safety Map clutter and clarified marker categories.
- Flattened the Report a spot sheet, compacted the PIN keypad, and retained content-fitting reusable popup cards.
- Aligned SOS status and trusted-contact acknowledgement/response states; tightened the narrow viewport gallery sizing.

## Static-source check

The HTML source contains 50 sequential numbered screen frames at 390 × 844, plus 15 reusable popup examples. Popup examples use content-sized cards; the PIN and report sheets use compact, bounded layouts. The narrow gallery layout preserves the 390 × 844 screen canvas at 390px and scales it proportionally below 390px. The source contains no JavaScript, framework imports, or service calls; controls remain illustrative. A browser renderer was unavailable for screenshot review, so this is a source-level viewport and overflow check rather than a rendered visual sign-off.
