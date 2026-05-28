# BOUNDED-CONTEXT.md Format

A `BOUNDED-CONTEXT.md` describes one bounded context: its purpose, where its boundary lies, how it integrates with anything outside, and the ubiquitous language used inside it.

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is responsible for.}

## Boundary

{What's inside this context, and — more importantly — what's deliberately outside. Mention external systems integrated with (Stripe, SendGrid, etc.) and concepts you've chosen not to model.}

## Integration

{How this context exchanges data with other bounded contexts or external systems. One bullet per integration point. Omit or leave as "None" if there's nothing to integrate with yet.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Single vs multi-context repos

**Single context (most repos):** One `BOUNDED-CONTEXT.md` at the repo root. Keep Boundary and Integration minimal — usually a line or two each — since there are no sibling contexts to relate to. The Language section is the meat.

**Multiple contexts:** A `BOUNDED-CONTEXT-MAP.md` at the repo root lists the contexts, where they live, and how they relate:

```md
# Bounded Context Map

## Contexts

- [Ordering](./src/ordering/BOUNDED-CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/BOUNDED-CONTEXT.md) — generates invoices and processes payments
- [Fulfillment](./src/fulfillment/BOUNDED-CONTEXT.md) — manages warehouse picking and shipping

## Relationships

- **Ordering → Fulfillment**: Ordering emits `OrderPlaced` events; Fulfillment consumes them to start picking
- **Fulfillment → Billing**: Fulfillment emits `ShipmentDispatched` events; Billing consumes them to generate invoices
- **Ordering ↔ Billing**: Shared types for `CustomerId` and `Money`
```

The skill infers which structure applies:

- If `BOUNDED-CONTEXT-MAP.md` exists, read it to find contexts
- If only a root `BOUNDED-CONTEXT.md` exists, single context
- If neither exists, create a root `BOUNDED-CONTEXT.md` lazily when the first term is resolved

When multiple contexts exist, infer which one the current topic relates to. If unclear, ask.

## Rules for the Language section

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **Flag conflicts explicitly.** If a term is used ambiguously, call it out in "Flagged ambiguities" with a clear resolution.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Show relationships.** Use bold term names and express cardinality where obvious.
- **Only include terms specific to this context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if used extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.
- **Write an example dialogue.** A conversation between a dev and a domain expert that demonstrates how the terms interact naturally and clarifies boundaries between related concepts.
