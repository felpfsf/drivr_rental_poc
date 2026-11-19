
# ADR 002 — Shared Server-Driven UI Engine

## Context

Catalog and Account require dynamic UI composition without
duplicating parsing, rendering and component registration.

## Decision

We created an independent sdui_engine package providing:

- Recursive JSON parsing.
- Schema version compatibility.
- Component registry and validation.
- Recursive widget rendering.
- Action resolution through callbacks.
- Fallback and debug diagnostics.

Each MFE registers its own domain-specific components
and permitted actions.

## Consequences

### Benefits

- Shared SDUI infrastructure.
- Domain isolation.
- Extensible component registration.
- Dynamic content without recompiling the application.

### Trade-offs

- Only pre-registered components can be rendered.
- New widget types require an application update.
- The current schema does not support arbitrary stateful forms.
- SDUI does not replace business rules.

## Alternatives considered

Embedding separate renderers in each MFE was initially
simpler but introduced duplicated infrastructure.
