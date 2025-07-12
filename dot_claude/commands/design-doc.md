---
description: "Create comprehensive design documents for technical features and projects"
allowed-tools: ["Read", "Write", "Grep", "WebFetch", "Bash", "mcp__github__create_issue", "mcp__github__create_pull_request", "mcp__github__get_issue", "mcp__github__get_pull_request", "mcp__github__update_issue", "mcp__github__update_pull_request", "mcp__github__search_code", "mcp__context7__resolve-library-id", "mcp__context7__get-library-docs"]
---

# Design Doc Writing Assistant

## Context

- Repository info: !`gh repo view --json name,owner -q '{"owner": .owner.login, "name": .name}'`
- File tree: !`eza -T --level=2`
- Existing issues: !`gh issue list --limit 10 --sort updated`

## Your task

Create a comprehensive design document for: $ARGUMENTS

Transform initial concepts into production-ready specifications through collaborative development.

**Think deeply about the problem and propose a detailed step-by-step implementation plan.**

## Approach:
1. **Explore deeply** - Ask clarifying questions about vision, use cases, constraints
2. **Develop concept** - Expand ideas, identify gaps, explore implications
3. **Design collaboratively** - Refine requirements, API design, technical approach
4. **Create actionable docs** - Detailed implementation guidance with step-by-step plan
5. **Validate completeness** - Ensure all development aspects covered

## Focus Areas:
- **Idea Development**: Vague concepts → concrete requirements
- **Technical Feasibility**: Identify challenges, propose solutions
- **Implementation Clarity**: Detailed developer guidance with clear steps
- **User Experience**: Serve real user needs
- **Future-proofing**: Evolution, scalability, maintenance

## Template:
```markdown
# [Feature Name] Design Doc
**Author:** | **Status:** Draft | **Updated:** [Date] | **Reviewers:**

## Problem & Scope
- **Problem Statement:** [User impact and why needed]
- **Goals:** [What you will achieve]
- **Non-Goals:** [What you won't address]

## Solution Overview
```mermaid
[Architecture diagram]
```

### API Design
```[language]
// Example usage patterns
```

### Key Components
[Core design, data flow]

### Alternatives Considered
**Option 1:** [Description] - *Rejected:* [reason]

## Implementation
### Architecture Details
[Detailed design, performance, extensibility]

### Work Breakdown
- **Phase 1:** [Description] - Size: [S/M/L/XL]
- **Dependencies:** [Teams/libraries needed]

### Cross-Cutting Concerns
- **Performance:** [Impact]
- **Testing:** [Strategy]
- **Documentation:** [User learning]

## Risks & Open Questions
- [Known risks and mitigation]
- [Unresolved questions]

## References
[Related docs, RFCs]
```

## Development Process:
1. **Idea Exploration** - Vision, use cases, constraints, success metrics
2. **Collaborative Design** - Requirements, APIs, alternatives, integration
3. **Implementation Planning** - Tasks, dependencies, testing, rollout

## Guidelines:
- Ask questions first, understand full scope
- Include concrete examples and realistic code samples
- Document decisions and reasoning
- Address edge cases and error scenarios
- Focus on developer experience and maintainability

Work iteratively to develop production-ready specifications.
