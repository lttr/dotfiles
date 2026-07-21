# GLOSSARY.md Format

A `GLOSSARY.md` is the ubiquitous language of a context: the canonical terms used inside it, each defined tightly with the aliases to avoid.

## Structure

```md
# {Context Name} Glossary

{One or two sentence description of what this context is and why it exists.}

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

## Single vs multi-glossary repos

**Single glossary (most repos):** One `GLOSSARY.md` at the repo root.

**Multiple glossaries:** A `CONTEXT-MAP.md` at the repo root lists the glossaries and where they live:

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/GLOSSARY.md) — receives and tracks customer orders
- [Billing](./src/billing/GLOSSARY.md) — generates invoices and processes payments
- [Fulfillment](./src/fulfillment/GLOSSARY.md) — manages warehouse picking and shipping

## Relationships

- **Ordering → Fulfillment**: Ordering emits `OrderPlaced` events; Fulfillment consumes them to start picking
- **Fulfillment → Billing**: Fulfillment emits `ShipmentDispatched` events; Billing consumes them to generate invoices
- **Ordering ↔ Billing**: Shared types for `CustomerId` and `Money`
```

The skill infers which structure applies:

- If `CONTEXT-MAP.md` exists, read it to find glossaries
- If only a root `GLOSSARY.md` exists, single glossary
- If neither exists, create a root `GLOSSARY.md` lazily when the first term is resolved

When multiple glossaries exist, infer which one the current topic relates to. If unclear, ask.

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if used extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.
