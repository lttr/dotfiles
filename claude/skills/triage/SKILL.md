---
name: triage
description: This skill should be used when the user wants to triage an issue, review a specification, or assess requirements completeness. Trigger when user mentions "triage", "review this spec", "is this requirement complete", "what questions should I ask", or provides a description/acceptance criteria that needs evaluation before implementation. The skill analyzes input against the codebase and project documentation to surface implicit requirements and generate clarifying questions.
---

# Triage

Analyze requirements, issues, or specifications for completeness. Explore the codebase to understand context, then generate targeted questions to fill gaps before implementation begins.

## Workflow

### 1. Receive and Parse Input

The user provides input as plain text - typically:
- Issue descriptions
- Acceptance criteria
- Feature requests
- Bug reports with reproduction steps
- Stakeholder comments or requirements

Extract and identify:
- **Goal**: What is being requested or solved
- **Scope**: What parts of the system are affected
- **Constraints**: Any mentioned limitations or requirements
- **Acceptance criteria**: How success will be measured

### 2. Explore Codebase and Documentation

#### Codebase

Use the Explore agent to understand:
- Project structure and architecture
- Relevant existing code that would be modified
- Patterns and conventions used in the codebase
- Related features or similar implementations
- Test coverage and testing patterns

#### Documentation

Search for relevant documentation that may contain implicit requirements:
- `docs/`, `documentation/`, `wiki/` directories
- `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`
- API specs (`openapi.yaml`, `swagger.json`)
- ADRs (Architecture Decision Records)
- Inline documentation and code comments

Look for:
- **Business rules** that the ticket assumes but doesn't state
- **Existing constraints** documented elsewhere
- **Related features** that may have dependencies
- **Domain terminology** that clarifies ambiguous terms
- **Edge cases** already documented for similar features

This context is essential for asking relevant technical questions and surfacing implicit assumptions.

### 3. Assess Completeness

Evaluate the input against these dimensions:

| Dimension | Questions to Consider |
|-----------|----------------------|
| **Problem clarity** | Is the problem/goal clearly stated? Why is this needed? |
| **Scope definition** | What's in scope? What's explicitly out of scope? |
| **User impact** | Who benefits? What user journey is affected? |
| **Acceptance criteria** | How do we know when it's done? What are success metrics? |
| **Edge cases** | What happens in error states? Empty states? Boundaries? |
| **Technical scope** | Which components/files are affected? API changes? |
| **Dependencies** | Blocked by anything? Needs coordination with other work? |
| **Non-functional** | Performance requirements? Security considerations? |
| **Data** | Schema changes? Migration needed? Data implications? |
| **UX/UI** | Designs provided? Interaction patterns defined? |

Rate overall completeness: **Ready** / **Mostly Ready** / **Needs Clarification** / **Underspecified**

### 4. Generate Questions

Produce a prioritized list of questions organized by:

1. **Blockers** - Questions that must be answered before any work can begin
2. **Scope clarification** - Questions that define boundaries
3. **Technical decisions** - Questions about implementation approach
4. **Nice to know** - Questions that would help but aren't blocking

Format questions to be:
- Specific and actionable
- Tied to a concrete decision or gap
- Easy to answer (yes/no or short response when possible)

## Output Format

```markdown
## Triage Summary

**Input**: [1-sentence summary of what was provided]
**Completeness**: [Ready | Mostly Ready | Needs Clarification | Underspecified]

### Understanding

[2-3 sentences capturing the core request and affected areas based on codebase exploration]

### What's Clear
- [Bullet points of well-defined aspects]

### Implicit Requirements (from docs)
- [Requirements found in documentation that the ticket assumes but doesn't state]
- [Business rules, constraints, or edge cases documented elsewhere]

### Gaps Identified
- [Bullet points of missing or ambiguous information]

### Questions

#### Blockers
1. [Question] — [Why this blocks progress]

#### Scope Clarification
1. [Question]

#### Technical Decisions
1. [Question]

#### Nice to Know
1. [Question]
```

## Tips

- Don't ask questions the codebase or docs already answer - explore first
- Surface implicit requirements from docs - tickets often assume documented knowledge
- Prioritize ruthlessly - 3 critical questions > 10 nice-to-haves
- Frame questions to unblock decisions, not gather trivia
- If input is very sparse, ask for more context before full analysis
- When docs contradict the ticket, flag it as a blocker question
