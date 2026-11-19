
# ADR 001 — Flutter Monorepo and Microfrontends

## Context

DrivR is a Flutter proof of concept designed to explore
modular application architecture and microfrontend boundaries.

## Decision

We adopted a Dart workspace orchestrated by Melos, with:

- A Shell App responsible for navigation and composition.
- Catalog, Booking and Account as feature packages.
- Shared Core and Design System packages.
- Explicit public contracts between modules.

The Shell coordinates cross-feature navigation through
callbacks and go_router.

## Consequences

### Benefits

- Independent feature development and testing.
- Explicit module boundaries.
- Shared dependencies and tooling.
- Reduced coupling between business domains.

### Trade-offs

- Modules are integrated at compile time.
- MFEs cannot be independently deployed.
- Changes to packages require a new application build.

## Alternatives considered

A single Flutter package with feature-based folders was
simpler, but would not demonstrate package-level isolation.
