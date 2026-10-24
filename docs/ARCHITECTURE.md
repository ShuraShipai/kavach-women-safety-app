# Kavach Flutter Architecture

## Status and decisions

This document is the project architecture contract. The application uses Flutter/Dart, feature-first layered modules, Riverpod for dependency injection and reactive state, and GoRouter for navigation. The supported product target is adaptive iOS and Android; minimum OS versions remain undecided.

Firebase and other external services are not configured. Add integrations only for an approved requirement and only after project-owned configuration is supplied. Never invent Firebase IDs, credentials, or service behavior.

## Layer responsibilities

- **Presentation:** Screens, widgets, rendering, accessibility, transient UI state, and forwarding user actions. It consumes application state and actions through Riverpod providers. It contains no business rules or infrastructure calls.
- **Application:** Riverpod providers, use cases, workflow orchestration, and coordination of domain contracts. It contains no widget code and does not import concrete data or infrastructure implementations.
- **Domain:** Pure Dart business rules, entities/value objects, and repository or service contracts owned by the feature. It is independent of Flutter, Riverpod, Firebase, and infrastructure.
- **Data:** Repository implementations, DTOs, mapping, serialization, persistence policy, and data-source ports needed by repository implementations. Implementations satisfy contracts from the domain or application layer.
- **Infrastructure:** Concrete Firebase, platform API, location, notification, permission, network, and other external-service adapters. Adapters implement ports declared in an inner layer and translate external details at the boundary.

A layer may be omitted when it has no real responsibility. Do not add empty or speculative layers. Keep contracts in the innermost layer that owns their meaning. Firebase-specific document models and SDK calls stay outside the domain.

## Permitted dependency direction

Dependencies point inward. The only outward imports are in the app composition root, which connects the pieces at startup and configures routing; it must not contain business decisions.

```text
Presentation ──> Application ──> Domain
                     ▲              ▲
                     │              │
              app composition       ├──── Data ──> data-source ports
                     │              │                  ▲
                     └──> Data      └──── Infrastructure ──> external SDKs/APIs
                          Infrastructure
```

More precisely:

- Presentation may import its feature's application providers and public domain types needed to render state. It must never import `data/`, `infrastructure/`, Firebase, database, HTTP, or platform-service packages.
- Application may import domain contracts and Riverpod. It must never import presentation, concrete repositories, Firebase SDKs, or other backend implementations.
- Domain imports only Dart SDK and deliberately approved pure-Dart packages. It must not import Flutter, Riverpod, Firebase, presentation, data, or infrastructure.
- Data may import domain contracts and its own data-source ports. It must not import presentation or concrete infrastructure adapters.
- Infrastructure may import the inner-layer ports it implements and the external SDK it adapts. It must not import presentation.
- `app/` is the composition root: `app_providers.dart` may import application provider declarations plus data/infrastructure implementations to supply Riverpod overrides; `app_router.dart` may import feature presentation entry widgets. Keep those imports limited to wiring.
- A feature may not import another feature's internal implementation. Cross-feature work uses an explicit domain/application contract or a deliberate application-level coordinator.
- No circular dependencies between layers or features.

### Import examples

Allowed:

```dart
// features/trusted_contacts/application/contact_providers.dart
import 'package:kavach/features/trusted_contacts/domain/contact_repository.dart';

// features/trusted_contacts/data/contact_repository_impl.dart
import 'package:kavach/features/trusted_contacts/domain/contact_repository.dart';

// app/app_providers.dart (composition root only)
import 'package:kavach/features/trusted_contacts/application/contact_providers.dart';
import 'package:kavach/features/trusted_contacts/data/contact_repository_impl.dart';
```

Forbidden:

```dart
// A widget importing Firebase or a concrete repository.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kavach/features/trusted_contacts/data/contact_repository_impl.dart';

// Domain importing UI/state/backend frameworks.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
```

## Organization

Create only folders needed by implemented responsibilities. Keep each feature's code close to that feature.

```text
lib/
  main.dart
  app/
    app.dart
    app_router.dart
    app_providers.dart       # composition root, when wiring is needed
  core/
    design_system/
      tokens/
      theme/
      widgets/                # only genuinely shared widgets
    errors/                  # shared error types only when justified
    platform/                # shared platform adapters only when justified
  features/
    <feature>/
      presentation/
      application/
      domain/
      data/
      infrastructure/        # only for concrete external adapters

test/
  core/
  features/
```

Do not create placeholder features or layers. Feature folders may omit unused layers. Put shared code in `core/` only when it is truly shared and has no feature-specific dependency. Every file must have a clear responsibility.

## Riverpod and workflows

Riverpod is mandatory for application dependency injection and reactive feature state. Declare providers by feature and responsibility, normally in `application/`; providers expose domain contracts and workflow state, not concrete backend types. Compose concrete implementations in `app/app_providers.dart` through provider overrides when needed. Widgets read providers and send user actions to application notifiers/use cases.

Choose providers, notifiers, or asynchronous providers according to the state/workflow. Keep business decisions out of widget `build()` methods. Keep transient presentation-only state local to the UI. Use immutable state, explicit loading/success/empty/failure outcomes, and recoverable error handling where relevant. Do not use global containers, service locators, mutable singletons, or hidden dependencies. Do not add a competing state-management library. Adopt code generation only when justified; document its build_runner workflow before use.

## Routing

Define GoRouter routes centrally in `app/app_router.dart` with stable paths and names. Routes point to feature presentation entry widgets. Redirects may depend only on explicit application state and contain no business rules. Pass small identifiers/arguments through routes; load feature data through providers.

## Data, infrastructure, and Firebase

Define repository contracts in the owning feature's domain. Data implementations satisfy those contracts and map DTOs to domain models. Keep external SDK calls, platform APIs, and provider-specific models in infrastructure/data boundaries. Put credentials and generated platform configuration outside business logic and never fabricate them. Enforce remote access with server-side authorization/security rules; client checks are not a security boundary.

All workflows must be testable with fake implementations of repository/service contracts and without live Firebase. Distinguish requested, attempted, sent, delivered, acknowledged, and responded outcomes wherever the service exposes those distinctions; never claim an unverified result.

## Design system

Read [`DESIGN.md`](DESIGN.md) before implementing UI. Centralize verified visual values under `core/design_system/tokens/` and map them through the shared theme. Do not claim unverified colors, typography, spacing, radii, or component states came from the design reference. Shared widgets belong in `core/design_system/widgets/` only when genuinely reused. Every widget class, including helper and private widget classes, must be declared in its own Dart file.

## Testing and architecture review

Test domain rules independently of Flutter/Firebase; test application workflows with fake contracts; test data mappings/repositories separately; and test UI by injecting or overriding Riverpod providers. Cover relevant loading, success, empty, error, cancellation, and recovery paths. Keep tests deterministic and avoid live production services.

For every feature and review, use the checklist in [`RULES.md`](RULES.md). Run formatting, configured lints, Flutter analysis, and `dart run tool/check_architecture.dart`. The architecture checker parses Dart ASTs to check widget-class-per-file and documented import-boundary rules. It does not prove business logic placement, absence of runtime service locators, or every possible third-party integration; those remain review responsibilities.
