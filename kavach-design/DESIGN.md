# Kavach UI design reference

## Scope

This document describes the static HTML design deck in `all_screens.html`. It is a review artifact, not a functioning app. The deck contains 50 full-screen artboards: the original 39 screens and 11 static Fake Call and Safety Mode screens, plus 15 reusable popup examples.

## Visual system

- **Canvas:** 390 × 844 px phone composition. The gallery scales the canvas below 390 px while preserving its aspect ratio.
- **Palette:** soft ivory `#F8F6F2` for page and screen backgrounds; deep crimson `#711832` for primary actions and emphasis; charcoal `#242326` for body text and navigation; warm stone `#ECE9E4` for secondary surfaces; white for cards and primary text on dark/emergency surfaces.
- **Typography:** system sans-serif stack led by `-apple-system`, `BlinkMacSystemFont`, and `SF Pro Text`. Screen titles use a strong, compact hierarchy; supporting copy stays concise and readable.
- **Surfaces:** white cards on ivory screens, generally 12–16 px corner radii, fine cool-gray dividers, and subtle frame shadows. Phone frames use a 48 px outer radius.
- **Navigation:** light translucent ivory bottom navigation with a crimson-tint current destination on standard app screens. Focused call and recording states omit the app navigation and show their task controls directly. Home keeps SOS and core actions visible; secondary tools stay behind a keyboard-accessible disclosure that is collapsed by default.
- **Icons and branding:** reuse inline line icons and the supplied Kavach logo assets. The caller photo is optional; the static default uses an initial avatar because no caller portrait asset was supplied.

## New feature presentation

### Fake Call

Help starts the incoming call immediately; caller and timing customization on screen 40 is optional. The full flow is incoming → active simulated conversation → ended. Incoming and active states use a charcoal call canvas with high-contrast caller identity and standard answer/end controls. A restrained “Simulated call” label keeps the visual presentation honest. SOS remains visible during incoming and active states. The flow is visual only and never connects to a person.

### Safety Mode

Help offers direct Start audio and Start video actions; either begins recording immediately when access is already available. Screen 44 remains the mode-choice reference. The access explanation appears only when microphone or camera access is needed. The flow then continues to stopped/review → saved recordings, with a separate unavailable state. Recording states show a clear REC indicator and elapsed time, compact pause/stop controls, and a visible, consistently aligned SOS control in the recording header. Audio uses a contained illustrative waveform panel; video uses a camera-preview panel. The interface does not claim that a hardware power-button sequence starts Kavach recording; native Emergency SOS sequences and actions are controlled by the device. Copy makes clear that recording does not itself send an alert. Permission and recording screens are static concepts only.

## Static-deck constraints

All controls are illustrative. The HTML contains no recording logic, permission requests, call integration, storage, authentication, or service behavior. Sample history rows and timers are visual examples. Do not present them as live data or verified evidence.

## Open design decisions

- No caller portrait asset is supplied; use the initial avatar as the default and an optional photo placeholder in setup.
- The sample caller name and scripted conversation need product/content approval and localization.
- Platform-specific call presentation, power-button shortcut integration, recording retention, export, and deletion policies remain unresolved and should be settled before implementation.
