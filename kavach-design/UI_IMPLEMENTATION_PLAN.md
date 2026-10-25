# Kavach static screen deck: plan and change log

## Confirmed direction

- Static screen deck only; no interactive prototype.
- Keep the supplied `all_screens.html` as the working base.
- Use a calm transit-wayfinding visual language where route lines clarify navigation without overwhelming digital-safety content.
- Target adaptive iOS and Android product design; current frames use a 390 × 844 mobile canvas.
- Keep emergency, messaging, location, evidence, and analysis claims tied to explicit user actions and verified outcomes.

## Scope and priorities

| Priority | Change | Status | Acceptance criteria |
|---|---|---|---|
| P0 | Repair malformed inline CSS that broke font declarations and screen rendering | Complete | Quoted system fonts remain valid inside every screen's style attributes |
| P1 | Keep the original static deck as the active artifact | Complete | All screens are visual frames; no JavaScript or external prototype files are needed |
| P1 | Consolidate incident logging with Evidence Vault | Complete | The duplicate Harassment Log and its empty state are removed; Vault retains case and evidence states |
| P1 | Retain safety/privacy journeys and add the approved battery handoff proposal | Complete | Safe Walk, offline, location-off, permissions, Vault empty, settings, data deletion, and per-walk battery-handoff screens are present |
| P1 | Make the gallery responsive and consistent | Complete | Frames remain centered at desktop widths and fit narrow viewports without horizontal page overflow |
| P2 | Improve deck headings, frame edges, spacing, and presentation hierarchy | Complete | Warm cream gallery and phone canvases, white cards, cool-gray secondary surfaces, charcoal navigation, deep-crimson actions, consistent gutters |
| P2 | Review misleading copy in SOS, evidence, and fallback screens | Complete | Delivery, 112, location, evidence-integrity, and reporting claims are qualified or require explicit user action |
| P3 | Prepare the approved screens for Flutter implementation | Not started | Requires a Flutter project and a separate implementation phase |

## Current screen inventory

The static gallery contains **50 screen frames**: the 39 existing screens plus 11 static Fake Call and Safety Mode screens. It retains onboarding and permissions, trusted contacts, SOS, Vault, digital safety, Safe Walk, Help, settings, device-loss/decoy states, and the new simulated-call and recording flows. The two harassment-log frames were removed because that journey duplicates Vault case activity. A per-walk battery-handoff setup screen was added as an opt-in concept with explicit best-effort limits. The Vault case detail is now shown as an incident timeline. Static feature concepts include Offline Safety Kit, Privacy Centre, and Guided Help. The new Safety Assurance section adds readiness, response planning, a safe test simulation, honest SOS status, and a trusted-contact response view. All controls remain illustrative; no backend or working service is represented.

The `If my phone dies` frame shows a low-battery reminder and guidance for Apple's Find My / Google's Find Hub. The new `Battery handoff` frame proposes a per-Safe-Walk opt-in to send a recent location to selected contacts. It requires a native feasibility spike and must remain best-effort.

## Change log

1. Restored the supplied static HTML gallery as `all_screens.html` after the user clarified that the requested artifact is static.
2. Repaired the quoted system-font names in the font-bearing inline style attributes so browser parsing no longer terminates those declarations early.
3. Removed the separate Harassment Log and its empty state; incident records remain in the Vault flow.
4. Added responsive gallery styles for compact widths and consistent frame presentation while preserving the original 390 × 844 screen composition.
5. Removed the fake incoming-call control and clarified the offline, location, 112, evidence, and reporting copy.
6. Applied the user-selected palette: deep crimson `#B9233D`, warm cream `#F7F2EA`, charcoal `#242326`, and cool gray `#E8E8EB`, with warm-cream screen backgrounds, white cards, and charcoal bottom navigation.
7. Clarified that the low-battery control is a reminder, not a guaranteed location message to trusted contacts; clarified that Find My / Find Hub are device-recovery tools.
8. Added a static per-walk battery-handoff setup screen with selected recipients, a 20% threshold, and explicit delivery limits.
9. Removed the interactive prototype CSS, JavaScript, and replacement logo asset created during the earlier approach.
10. Removed global rules that forced screen and card colors; phone canvases use warm cream, cards remain white, and the shared navigation uses charcoal with a crimson selected state.
11. Made the content area scroll within each fixed-size phone frame while keeping the bottom navigation anchored.
12. Reworked the Vault case detail into a timestamped incident timeline and labeled device-time and sample-status limits.
13. Added static concepts for Offline Safety Kit, Privacy Centre, and Guided Help, with clear limitations and no service claims.
14. Added a five-screen Safety Assurance flow: readiness review, response plan, safe test simulation, honest SOS status, and trusted-contact response view. The simulation is clearly marked as sending no real alert.
15. Added visible home, Help, and Settings entry points for Safety Readiness, Offline Safety Kit, Guided Help, and Privacy Centre; added map-report limitations and a direct emergency-call fallback when no contacts are configured.
16. Replaced vague or overconfident copy in onboarding, offline, Safe Walk, countdown, and evidence states; standardized small supporting labels and frame geometry.
17. Fixed the SOS status card compression visible in the supplied browser capture by preventing scroll-area cards from shrinking below their content height.

## Structural flow audit

See [`SCREEN_FLOW_AUDIT.md`](SCREEN_FLOW_AUDIT.md) for the 50-screen inventory, conceptual journeys, entry points, missing outcome states, and priority findings. This is a static-structure audit; it does not imply runtime navigation is implemented.

## Validation and limitations

- The previous reviewed deck had 39 numbered artboards. The current deck has 50: those 39 plus four Fake Call and seven Safety Mode artboards. The 15 popup examples remain component references, not full-screen artboards.
- Rendered screenshot review remains outstanding because no browser or preview renderer is available in this environment. Source-level HTML structure and deck consistency were checked; visual rendering on real devices still needs review.
- This is a static visual deck. Controls shown within screen frames are design depictions and do not perform actions.
- No Flutter project, emergency dispatch integration, SMS provider, location service, or evidence-storage implementation is present in the workspace.

18. Added explicit content sizing and minimum row height to the SOS status card so the contact-response state remains readable in the fixed phone frame and scrolls with the screen.
19. Marked Home as the selected destination in the Privacy Centre frame to keep the shared bottom navigation state consistent.
20. Added static Fake Call screens for setup, incoming, active simulated conversation, and call ended.
21. Added static Safety Mode screens for activation, permission explanation, audio and video recording, recording stopped, saved recordings, and unavailable state.
22. Added Help entry points for both concepts and a Vault entry to saved recordings; updated the flow map and screen count to 50.
23. Updated the static flows for emergency speed: Help starts the Fake Call immediately with setup optional, and Safety Mode starts the selected recording mode immediately when access is already available; the access explanation is conditional.
24. Refined the audio recording visual with a contained waveform panel, then replaced the proposed hardware shortcut with direct one-tap Start audio and Start video actions on Help.

## Final static UI polish pass

- Added explicit intrinsic sizing and a minimum row height to the SOS status checklist, addressing the clipped-looking contact-response row in the supplied capture.
- Set the Home tab as selected in the Privacy Centre frame, where the shared navigation previously had no selected destination.
- Replaced the empty PIN keypad controls with decorative spacers and labelled the delete key for assistive technology.
- Rechecked the source inventory: 50 consecutively numbered frames, all with scrollable content regions; 22 shared navigation bars each have exactly one active destination; no external assets or scripts are used.
- Visual limitation: no local browser renderer is available here, so these source-level fixes still need a final rendered screenshot review at phone and narrow-width sizes. The gallery remains a static design reference, not an interactive app.


## Final UI refinement pass

- Replaced the square logo treatment with the transparent full-lockup asset on Splash, Welcome, and the gallery header.
- Replaced manual Safe Walk check-ins and checkout with an optional Journey Guardian concept, delayed-journey choices, concept-only arrival detection where supported, explicit tracking limitations, and persistent Call 112/SOS access.
- Clarified Safety Map filters and marker symbols for reported concerns, poor lighting, police stations, and user location.
- Flattened the Report a spot sheet, reduced PIN keypad sizing, and kept reusable popup examples compact and content-fitting.
- Aligned SOS status stages and separated trusted-contact acknowledgement from response.
- Kept all controls static and added no JavaScript, services, or frameworks.
