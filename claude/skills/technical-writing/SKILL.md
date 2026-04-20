---
name: technical-writing
description: Use when writing or editing technical prose — tech specs, design docs, programmer articles, developer docs, RFCs, ADRs, incident writeups. Do NOT use for code comments, commit messages, or casual chat.
---

# Technical Writing

## 1. Inverted pyramid — lede first

Open every document and section with the conclusion. Support afterward. No warm-up, no restating the section title.

Buried:

> Session cookies currently expire after 24 hours, causing frequent mobile logouts. We evaluated refresh tokens, extended sessions, and device-bound credentials. We recommend refresh tokens with a 30-day rolling window.

Lede first:

> We're replacing 24-hour session cookies with 30-day rolling refresh tokens to fix frequent mobile logouts. Rejected alternatives (extended sessions, device-bound credentials) are discussed below.

## 2. Active voice — name the agent

Who does what is load-bearing. Reach for passive only when the agent is genuinely unknown or the object is the deliberate topic.

Passive:

> When a request is received, the payload is validated against the schema. If validation fails, a 400 is returned and the error is logged.

Active:

> The handler validates each request against the schema. On failure, it returns a 400 and writes the error to the audit log.

## 3. Accessible terms early — concept before jargon

Plain-English first, term in parentheses after. Spell out acronyms on first use.

Jargon-first:

> We use CRDTs in the collaborative editor. Conflict-free replicated data types let clients apply changes locally and merge without a coordinator, removing the round-trip latency of the old WebSocket approach.

Accessible-first:

> The collaborative editor lets clients apply changes locally and merge without a coordinator, removing the round-trip latency of the old WebSocket approach. The mechanism is a data-structure family called CRDTs (conflict-free replicated data types).
