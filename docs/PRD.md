# Kavach Women Safety App — Product Requirements

## Purpose

Kavach is intended to help women prepare for and respond to physical and digital safety concerns, contact people they trust, and organize incident information. Sharing should be deliberate, privacy-conscious, and reported accurately: a sent alert, confirmed delivery, acknowledgement, and a contact response are distinct outcomes.

The sibling design is a static visual blueprint. It does not demonstrate working navigation, emergency calls, messaging, authentication, location tracking, evidence storage, or analysis.

## Users

- **Primary:** Women who may face unsafe travel, harassment, stalking, privacy violations, or digital abuse. The design considers stressful moments, limited connectivity or battery, and situations where asking for help openly may be difficult.
- **Secondary:** Trusted contacts who may receive an alert and need concise, clearly qualified information and response options.

The source PRD focuses on India and names Kannada, Hindi, and English. Deployment region and language scope need confirmation before release.

## Product scope

The product direction combines physical safety, digital safety guidance, and incident records. The actual deck has 50 screen references covering entrance/onboarding, Home and Trusted Circle, SOS, Vault, Shield, Journey Guardian, Safety Map, Help, Settings, Safety Assurance, Fake Call, and Safety Mode. See [`DESIGN.md`](DESIGN.md) for the screen inventory and visual evidence.

### Initial MVP

The initial usable product should prioritize the core setup and emergency journey:

1. Splash and welcome/onboarding.
2. Phone verification and a basic user profile/PIN flow, subject to an approved authentication design.
3. Permission explanation and user-controlled setup of trusted contacts.
4. A user-triggered SOS review/countdown and cancellation flow, with truthful status and recovery when an operation cannot be confirmed.
5. Explicit, consent-based location inclusion when available, plus clear behavior when permission, location, network, or messaging is unavailable.
6. A Help surface with a user-confirmed phone handoff for emergency calling; the app must not imply that it placed or connected a call unless verified.

This is a proposed implementation scope based on the core journeys in the deck, not a statement that these capabilities exist today. Backend, delivery channel, emergency-service integration, and platform behavior must be settled before making service promises.

### Later, only after feasibility and product review

- Trusted-contact acknowledgement/response view and richer status history.
- Vault media capture/import, SOS automation, location capture, export sharing, retention, and deletion remain later work; see the implemented note-only scope below.
- Shield message/image guidance or analysis; results must be framed as estimates, not proof or legal advice.
- Journey Guardian, background arrival detection, voice phrase trigger, and battery handoff. These concepts need platform feasibility, consent, battery, and reliability review.
- Safety Map, community reports, and nearby police stations. Reports need moderation and station data must be verified and maintained.
- Offline Safety Kit, Guided Help, Privacy Centre, Safety Readiness/Response Plan, and safe simulation.
- Decoy calculator and device recovery guidance.

The deck is not evidence that any later feature is functional or safe to ship.

## Screens and intended flows

Screen numbering below follows the current static deck and [`SCREEN_FLOW_AUDIT.md`](../../kavach-design/SCREEN_FLOW_AUDIT.md).

| Journey | Designed screens and intent |
|---|---|
| Onboarding | 1 Splash → 2 Welcome → 3 Phone sign-in → 4 Enter code → 5 Permissions → 6 Profile → 7 Set PIN → 8 Add first contact → 9 Home. Invalid/expired code, permission denial, PIN mismatch, and contact selection are inline or modal states. |
| Home and Trusted Circle | 9 Home → 10 Trusted Circle → 11 Contact options. Add/edit/remove, duplicate checks, and test-alert preview are component states. Offline, no-contact, and location-disabled conditions appear on Home. |
| SOS | 9 Home → 12 Countdown → 13 PIN cancellation or alert review → 38 Alert status. Status distinguishes sent, delivery confirmed, acknowledged, and responding. 39 is a trusted-contact response view. |
| Vault | 14 Vault → add-evidence sheet → 15 Case timeline → 16 Export preview. Capture, permission, save, and export outcomes are component states. |
| Digital safety | 17 Shield → 18 Analyze message → 19 Analyzing → 20 Result; image/video path 17 → 21 Choose media → 22 Consent, analysis, and result. Message analysis remains illustrative. |
| Journey Guardian | 9 Home → 23 Start Journey → optional Guardian → 24 Automatic Monitoring, with arrival/delay states. It is explicitly a concept with possible location pauses and platform limits. |
| Map and reporting | 9 Home → 25 Safety Map → marker detail or 26 Report a spot. Reports are unverified; the shown station marker is demo-only. |
| Help and settings | 27 Help → call handoff or 34 Guided Help. 28 Settings leads to 29 Voice phrase trigger, 30 device recovery, 31 calculator, 32 Offline Kit, and 33 Privacy Centre. |
| Safety Assurance | 9 Home → 35 Readiness → 36 Response Plan or 37 Safe Test. Simulation sends no real alert. |

## Functional requirements

- Provide a usable onboarding path to the app's main screen; validation and retry states must be visible and recoverable.
- Let the user choose and manage trusted contacts. Preview information and recipients before an alert is sent.
- Keep SOS cancellation and explicit confirmation clear. Show only statuses supported by evidence from the selected delivery mechanism.
- Request permissions in context, explain their use, support denial, and continue safely where possible.
- Include location only with user consent and a current available fix; clearly identify unavailable or stale location.
- Provide user-confirmed external call handoff. Do not promise automatic emergency-service contact.
- For any later evidence, analysis, map, or background feature, provide failure/empty states and honest limits before release.

## Non-functional requirements

- **Safety and clarity:** Plain language, high contrast, large actionable targets, accessible labels, and visible cancellation/recovery paths.
- **Privacy:** Minimize collection, make recipients and sharing explicit, protect sensitive local data, and explain retention/deletion.
- **Reliability:** Handle offline, permission, platform handoff, and service failures without reporting success prematurely.
- **Accessibility and localization:** Plan for screen readers, scalable text, reduced motion, and the confirmed launch languages. The source PRD calls for English, Kannada, and Hindi; implementation coverage is not yet verified.
- **Platform support:** Design target is adaptive iOS and Android. Actual minimum OS versions and native service constraints remain undecided.
- **Maintainability:** Flutter/Dart, feature-first structure, Riverpod, and GoRouter are the planned app stack; see [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Success and release gates

Before release, validate core flows on target devices, including accessibility, denied permissions, no network/location, cancellation, and ambiguous delivery. Agree on privacy/data-retention policy, legal review, service ownership, and support coverage. No success metrics or operational guarantees are established by the static design materials.

## Evidence Vault implementation boundary

- Cases and text notes are stored locally in platform secure storage. A note records device time and a SHA-256 hash of its text.
- Audio and video can be captured for up to 60 seconds, reviewed, and saved as AES-GCM encrypted local files. Each recording stores a SHA-256 hash and device timestamp. Users can open/share recordings through the platform sheet and delete recordings with their case entry.
- Notes can be deleted from a case timeline. A case can be generated as a multi-page PDF and handed to the platform share sheet; the report identifies notes and recordings with hashes and says location was not recorded.
- Images selected in Shield can be explicitly saved as encrypted photo evidence with a hash and timestamp. SOS-triggered capture and location points are not implemented. SOS itself is not connected, so no automatic evidence capture is claimed. Recording, image-save, and PDF flows need device-level validation.

## Shield implementation boundary

- Screens 17–22 provide a Shield landing page, message input/progress/result, and image/video selection and analysis results. Image/video analysis uses a Firebase callable backend source that calls Resemble Detect and Intelligence with zero-retention requested; it is not live until Firebase Functions/Storage are deployed and `RESEMBLE_API_KEY` is configured as a Firebase secret. The app asks before upload and treats results as estimates.
- If the user enables Save to Vault, the message is stored locally in a Shield message review case with a device timestamp and SHA-256 hash.
- Images and videos can be selected for an on-device preview, then submitted only after consent. The detector can return an inconclusive estimate; it cannot establish that every possible edit is absent. Images can also be explicitly saved as encrypted Vault evidence.
