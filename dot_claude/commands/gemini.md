---
description: "Delegate large codebase analysis to Gemini CLI when context limits are exceeded"
allowed-tools: [Bash(gemini:*)]
---

!`gemini --all_files --prompt "Perform a comprehensive analysis of this repository. Extract and identify: 1) Overall project purpose and goals, 2) Core architecture and key components, 3) Main entry points and critical files, 4) Dependencies and technology stack, 5) Directory structure and organization patterns, 6) Key algorithms or business logic, 7) Configuration files and their purposes, 8) Testing approach and coverage, 9) Build/deployment processes, 10) Any notable patterns or architectural decisions. Provide a detailed technical summary that would help another developer quickly understand this codebase."`

# Repository Analysis and Summary

Based on the comprehensive codebase analysis above, provide detailed insights about the repository structure, critical components, and architectural decisions. Use this contextual information to answer questions about:

- **Project Overview**: Main purpose, goals, and scope
- **Architecture**: Core design patterns, module relationships, and data flow
- **Key Components**: Critical files, entry points, and core functionality
- **Technology Stack**: Programming languages, frameworks, libraries, and tools
- **Configuration**: Environment setup, build processes, and deployment
- **Testing Strategy**: Test coverage, testing frameworks, and quality assurance
- **Development Workflow**: Build processes, CI/CD, and development practices

## Usage Instructions

This command first analyzes the entire repository structure and content, then uses that analysis to provide informed responses about the codebase. The initial analysis provides comprehensive context about the project's architecture, components, and implementation details.

## When to Use

- Understanding unfamiliar codebases
- Architectural reviews and documentation
- Onboarding new team members
- Planning major refactoring efforts
- Security audits requiring full project context
- Performance analysis across the entire application

The analysis focuses on extracting actionable insights and technical understanding rather than surface-level descriptions.
