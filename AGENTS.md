# Kavach Agent Instructions

Before changing this project, inspect the current workspace and read `docs/ARCHITECTURE.md`, `docs/RULES.md`, and `docs/DESIGN.md`, plus the relevant `docs/PRD.md`, `docs/PHASES.md`, and `docs/MEMORY.md` sections.

`docs/RULES.md` is the mandatory coding contract. Follow its layer dependency rules, Riverpod requirement, privacy/backend boundaries, and one-widget-class-per-Dart-file rule. Use `docs/ARCHITECTURE.md` for folder ownership and allowed imports. Do not invent Firebase configuration. Preserve unrelated files and Git configuration; do not commit or push unless explicitly asked.

For Dart changes, run formatting, `flutter analyze`, and `dart run tool/check_architecture.dart`. The architecture checker covers its documented AST/import rules only; use the manual review checklist for the remaining architectural requirements.
