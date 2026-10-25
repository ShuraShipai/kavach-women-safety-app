# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Stack

Static HTML screen deck based on the supplied gallery. The current 50-frame artifact is a visual prototype only: controls are illustrative, with no backend, service integrations, or Flutter implementation.

## Users

Primary users are women facing physical safety risks, digital harassment, privacy violations, stalking, identity misuse, or situations where openly seeking help may increase danger. The PRD names a college student, a late-commuting professional, and a woman in an unsafe household. Trusted contacts are a secondary audience who receive alerts and need clear, minimal incident information.

## Product Purpose

Kavach is intended to help women prepare for, respond to, and document physical and digital safety incidents while keeping sharing user-controlled and privacy-conscious.

## Positioning

The PRD's intended product shape brings physical-safety journeys, digital-abuse guidance, and an evidence record into one app. Treat this as a product direction, not a claim of worldwide novelty or proven effectiveness.

## Operating Context

Users may be stressed, distracted, offline, low on battery, using a shared device, or unable to seek help openly. The supplied PRD focuses on India and names Kannada, Hindi, and English. The actual deployment region and service coverage remain undecided.

## Capabilities and Constraints

- The PRD proposes trusted contacts, user-triggered SOS, Safe Walk, a local evidence vault, digital-abuse guidance, a safety map, help resources, privacy controls, and optional decoy mode.
- The HTML deck contains 50 static screen mockups, including Offline Safety Kit, Privacy Centre, Guided Help, a Vault incident timeline, per-walk battery handoff, Safety Assurance, Fake Call, and Safety Mode audio/video recording concepts. These are visual concepts; they do not prove that any feature is implemented.
- No Flutter project, backend, external service configuration, ML model, or emergency-service integration was present in the workspace.
- The PRD says the hackathon demo is Android-first while the supplied screen deck is labeled iOS. The user has confirmed an adaptive iOS and Android target for the redesign; use native-feeling platform adaptations while keeping shared product behavior consistent.
- iOS standard SMS composition requires user action. Do not represent SMS as automatically sent or 112 as connected without a verified service.
- Automatic capture, background triggers, location-sharing behavior, evidence retention, and model processing require explicit product and technical decisions before production claims.
- Build for this request: static HTML screen gallery based on the supplied UI artifact. It does not replace or establish a Flutter application.

## Evidence on Hand

- `Kavach – Product Requirements Document (PS2 Women's Safety).pdf`: product intent, personas, feature requirements, user flows, proposed technical approach, risks, success metrics and references.
- `all_screens.html`: the supplied static deck, restored as the working base, with malformed inline CSS quoting repaired, responsive scrolling and shared navigation styling added, and redundant harassment-log screens consolidated into the Vault. The current deck has 50 visual mockups.
- `app_icon.svg`: original brand asset; the static deck uses valid inline copies of the mark.
- `UI_IMPLEMENTATION_PLAN.md`: chosen direction, scope, screen inventory, change log, validation record, and production blockers.
- `SCREEN_FLOW_AUDIT.md`: structural review of all 50 screens, conceptual journeys, missing states, and disconnected entry points.
- No runnable application, service credentials, model artifact, screenshots from a device, or backend implementation was supplied.

## Product Principles

1. Never claim an alert, call, share, capture, or deletion succeeded until the interface has evidence that it did.
2. Let the user choose who receives sensitive information and for how long.
3. Keep sensitive evidence local by default unless a clearly explained feature needs otherwise.
4. Design recovery and failure paths alongside the primary safety flow.
5. Treat automated risk and manipulation analysis as uncertain assistance, not proof or legal advice.

## Accessibility & Inclusion

The PRD requires English, Kannada, and Hindi, large touch targets, screen-reader labels, high contrast, haptic and voice feedback. These requirements are not verified in the supplied static deck.
