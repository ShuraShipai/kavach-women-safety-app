---
version: 1
slug: "all-screens-html"
primary_target: "all_screens.html"
related_targets: []
---

# Kavach static mobile safety screen deck

Scope: Polish the supplied static screen gallery in `all_screens.html`; keep it static. Do not add app-like navigation behavior or implementation code. Mode: Operate.

Audience and task: Women preparing for and responding to physical and digital safety situations. The screens should make the next action and its consequences understandable at a glance, especially when a user is rushed or distracted.

Content and constraints: Preserve the existing screen journeys and states for onboarding, permissions, trusted contacts, SOS, Evidence Vault, digital-safety guidance, Safe Walk, Help, privacy settings, and device loss. Add static Fake Call setup/incoming/active/ended screens with a direct Help-to-incoming path and optional setup, plus Safety Mode activation with immediate audio/video starts when access is available; show the access-needed state only when required, alongside stopped, history, and unavailable screens. Put direct one-tap audio/video recording choices on Help when access is available; do not present a hardware power-button sequence as a Kavach-specific recording trigger. Add static concepts for Offline Safety Kit, Privacy Centre, Guided Help, and Safety Assurance (readiness, response plan, safe simulation, honest SOS status, and trusted-contact response); present Vault case details as an incident timeline. Include the approved static per-walk battery-handoff setup proposal; show it as opt-in and best-effort with permission, location, network, suspension, and shutdown limits. Consolidate incident logging into Vault. Omit duplicate harassment-log states. Clearly distinguish designs for success after verified delivery from preview or failure states. Fake Call must remain visibly identified as simulated and must never imply a real call. Safety Mode screens depict recording states only; they do not imply recording, permissions, SOS dispatch, or storage are implemented. Do not imply silent messaging, 112 dispatch, live tracking, tamper-proof evidence, or automated analysis unless the screen describes a verified implementation. Preserve the original brand mark as inline vector artwork.

Unresolved decisions: Production alert provider, 112 integration, background location, Safe Walk timer/check-in delivery, local secure storage, recording retention/export/deletion, platform-specific call presentation, automated analysis, and Flutter architecture remain to be decided before implementation.

## Direction contract

THESIS: A woman should recognize the next safety action, its status, and who may receive information without reading a wall of text.

OWN-WORLD: Calm transit wayfinding: connected route lines and clear stop labels establish the navigation grammar. Use soft ivory (#F8F6F2) for the gallery and screen canvases, white cards, warm stone (#ECE9E4) for secondary surfaces, charcoal (#242326) for text, and deep crimson (#711832) for brand and primary actions. Keep digital safety and evidence as equally legible destinations.

STORY: The deck moves from setup and consent to daily protection, emergency help, digital safety, documentation, and recovery. Each screen shows one clear purpose and the consequence of its primary action.

FIRST VIEWPORT: The gallery heading identifies Kavach and describes the static visual deck; controls are illustrative. At small widths, one screen frame fills the available content width with readable labels and no horizontal scrolling. Frames retain their 390 × 844 composition and safe-area spacing.

FORM: Static screen gallery restored as the base at the user's request; adaptive iOS/Android product target, represented with shared mobile layouts.

FINISH: All 50 frames remain readable at their gallery width, scroll within a fixed phone canvas, share the same light translucent ivory navigation with a crimson-tint active destination where appropriate, and distinguish visual concepts from service behavior. Duplicated incident logging is removed and service claims are bounded.
