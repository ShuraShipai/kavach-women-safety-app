# Mandatory Rules for Kavach Coding Agents

These rules are the project coding contract. They apply to all application code, tests, examples, and future features. Read [`ARCHITECTURE.md`](ARCHITECTURE.md), [`DESIGN.md`](DESIGN.md), and relevant product/phase documentation before changing behavior or structure.

## 1. One widget class per Dart file

**Every Flutter widget class must be declared in its own dedicated Dart file, without exception.** This includes public and private widgets, `StatelessWidget`, `StatefulWidget`, helper/loading/error/empty/layout widgets, and widgets used only once. Keep each widget's responsibility focused in the owning feature's `presentation/` directory or in shared `core/design_system/widgets/` only when it is genuinely reusable.

Do not define two widget classes in one file, nest widget class declarations, or hide widget classes in tests/examples. A `State<T>` class must also be in its own Dart file; structure stateful code to avoid circular imports (for example, use a Dart `part` library when needed). Prefer stateless/consumer widgets when stateful lifecycle is unnecessary.

## 2. Mandatory layers and dependency direction

Keep presentation, application, domain, data, and infrastructure responsibilities separate as defined in [`ARCHITECTURE.md`](ARCHITECTURE.md). Dependencies point inward:

```text
Presentation -> Application -> Domain
Data -> Domain and data-source ports
Infrastructure -> inner-layer ports and external SDKs
App composition root -> routing/presentation entry points and concrete DI wiring
```

The app composition root is the only place allowed to connect concrete data/infrastructure implementations to application provider contracts. It must contain wiring only, not business decisions.

### Non-negotiable dependency rules

1. Widgets never access Firebase, databases, HTTP clients, or platform services directly.
2. Widgets never instantiate repositories or services manually.
3. Presentation communicates with workflows/state through Riverpod providers; it does not import data or infrastructure implementations.
4. Application coordinates use cases and domain contracts and contains no presentation code.
5. Domain remains pure Dart wherever possible and never imports Flutter, Riverpod, Firebase, UI, data, or infrastructure.
6. Data implementations implement contracts declared in the appropriate inner layer.
7. Firebase-specific code stays within data/infrastructure boundaries.
8. Domain and application never import concrete backend implementations.
9. Shared core code never imports feature-specific presentation code.
10. Features never reach into another feature's internals. Cross-feature communication uses explicit contracts or application-level coordination.
11. Do not introduce circular dependencies between layers or features.
12. Do not use global mutable state, service locators, global Riverpod containers, or hidden dependencies.
13. Do not bypass these rules for convenience or to reduce the number of files.

Allowed imports:

```dart
// Feature application depends on its domain contract.
import 'package:kavach/features/trusted_contacts/domain/contact_repository.dart';

// Data implementation satisfies the inner contract.
import 'package:kavach/features/trusted_contacts/domain/contact_repository.dart';

// Only the composition root wires the implementation.
import 'package:kavach/features/trusted_contacts/application/contact_providers.dart';
import 'package:kavach/features/trusted_contacts/data/contact_repository_impl.dart';
```

Forbidden imports:

```dart
// Never in presentation or domain.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kavach/features/trusted_contacts/data/contact_repository_impl.dart';

// Never in domain.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

## 3. Riverpod is mandatory

Use Riverpod consistently for application dependency injection and reactive feature state. Organize provider declarations by feature and responsibility, normally in `application/`. Inject repository contracts/service abstractions through providers; compose concrete implementations only in the app bootstrap. Choose providers/notifiers/asynchronous providers that match the state. Keep state immutable and feature-scoped.

Widgets render provider state and forward actions. Keep business logic out of widget `build()` methods. Keep short-lived presentation-only state in the UI. Model relevant loading, success, empty, and failure states explicitly. Do not read Riverpod containers globally to bypass injection, and do not add another state-management library. Do not create providers for static constants or simple immutable design tokens. Use code generation only when justified and document the generation workflow.

## 4. Feature and file organization

Use `lib/features/<feature>/` for feature-owned code and `lib/core/` only for genuinely shared foundations. Use `presentation/`, `application/`, `domain/`, `data/`, and `infrastructure/` only where each has a real responsibility. Keep repository contracts in the owning domain, concrete adapters at the outer boundary, and each file focused on one responsibility. Do not create speculative layers, empty folders, giant mixed-purpose files, or generic shared modules without a clear owner.

Use `lower_snake_case.dart` filenames and `UpperCamelCase` types. Keep cross-feature imports limited to documented public contracts/coordinators. No layer or feature may form a dependency cycle.

## 5. Design system and UI isolation

Read [`DESIGN.md`](DESIGN.md) before implementing UI. Use centralized verified tokens and the shared `ThemeData`; do not scatter brand colors, typography, spacing scales, radii, or component dimensions. If a value is not verified, record it as a design decision instead of attributing it to the reference.

Do not put business rules in styling/layout or backend calls in UI. Reuse an existing shared component when it fits. Consider responsive behavior, safe areas, accessibility semantics, text scaling, contrast, reduced motion, and comfortable touch targets for each feature. Design changes must not alter business behavior; business changes must not require rewriting unrelated UI components.

## 6. Backend and privacy isolation

Hide Firebase and all external services behind contracts and adapters. Never put Firebase SDK calls in widgets or domain entities. Domain rules never depend on Firestore document shapes. Separate DTOs/serialization from domain entities when appropriate and map explicitly at the boundary. Handle network, permission, authentication, and unavailable-service errors at the correct boundary. Keep configuration and credentials out of business logic. Never hardcode secrets or invent backend configuration. Test workflows with fake repositories without requiring a live Firebase project.

Treat server-side authorization/security rules as mandatory for remote access; client checks alone are not a security boundary. Do not claim an alert, call, location share, evidence action, or deletion succeeded without verified outcome.

## 7. Required feature/review checklist

Every feature implementation and code review must verify:

- [ ] Domain rules are testable without Flutter or Firebase.
- [ ] Application workflows are testable with fake dependencies.
- [ ] Repository implementations and data mappings are tested separately where relevant.
- [ ] UI widgets use injected or overridden Riverpod providers.
- [ ] Relevant loading, success, empty, error, cancellation, and recovery states are handled.
- [ ] Imports follow the permitted dependency direction; no prohibited imports or cycles exist.
- [ ] Every widget class, including private/helper/State classes, has its own Dart file.
- [ ] Design values use verified centralized tokens and UI accessibility/responsiveness are considered.
- [ ] Existing tests pass; Dart formatting, configured static analysis, and `dart run tool/check_architecture.dart` are clean.
- [ ] No Firebase IDs, credentials, private keys, secrets, or real user data were added.

Run `dart format` on changed Dart files, `flutter analyze`, and `dart run tool/check_architecture.dart`. The architecture checker parses Dart ASTs and checks widget-class-per-file and documented import-boundary rules. It does not verify business-logic placement, runtime service locators, all possible external package aliases, or semantic feature ownership; review those manually. Do not claim checks beyond what the script actually verifies.

## 8. Architecture change policy

Do not silently change this architecture to make a feature easier. A proposed exception or structural change must document:

1. Why the existing architecture is insufficient.
2. Alternatives considered.
3. Effects on existing layers and features.
4. Tests and documentation that must change.

Record approved decisions in `ARCHITECTURE.md` before relying on the exception. Keep this file as the mandatory coding contract.

## 9. Git safety

Inspect Git status and the diff before editing or committing when a Git repository exists. Preserve unrelated work. Never reset, clean, rewrite shared history, force-push, or discard changes without explicit authorization. Stage only files related to an authorized change. Do not commit generated credentials, secrets, private data, or build artifacts.
