# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code)

## Git and GitHub Workflow

### Core Principles
- Maintain a clean, linear history through disciplined branching and rebasing
- Follow atomic commit practices with descriptive messages
- Enforce code quality through pre-commit hooks and CI/CD pipelines
- **Never skip pre-commit hooks**

### Branch Management Strategy

#### Branch Naming Convention
- Feature branches: `feature/issue-number-brief-description` (e.g., `feature/123-user-authentication`)
- Bug fixes: `fix/issue-number-brief-description` (e.g., `fix/456-login-validation`)
- Hotfixes: `hotfix/issue-number-brief-description` (e.g., `hotfix/789-security-patch`)
- Chores: `chore/brief-description` (e.g., `chore/update-dependencies`)

#### Branch Protection Rules
- **NEVER** commit directly to `main` or `master` branch
- Always create feature branches from the latest `main`
- Delete feature branches after successful merge
- Use branch protection rules to enforce PR reviews

### Development Workflow (GitHub Flow)

#### 1. Issue Creation
- Create a detailed issue before starting any work
- Use issue templates when available
- Include:
  - Clear problem statement
  - Acceptance criteria
  - Technical requirements
  - Labels for categorization (bug, feature, enhancement, etc.)

#### 2. Branch Creation and Development
```bash
# Always start from main
git checkout main
git pull origin main --rebase

# Create and switch to feature branch
git checkout -b feature/123-brief-description
```

#### 3. Commit Guidelines
- **Atomic commits**: One logical change per commit
- **Conventional Commits** format when specified:
  ```
  type(scope): description

  [optional body]

  [optional footer(s)]
  ```
- Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Examples:
  - `feat(auth): add OAuth2 integration`
  - `fix(api): resolve null pointer exception in user service`
  - `docs(readme): update installation instructions`

#### 4. Code Quality Enforcement
- **Pre-commit hooks**: NEVER skip or bypass pre-commit checks
- **ALWAYS examine the `.pre-commit-config.yaml` file** at the project root to understand the specific hooks and rules configured for that project
- **Follow the exact rules** defined in the project's pre-commit configuration
- **Ensure all code changes comply** with the configured linters, formatters, and validators
- **Never commit code that would fail pre-commit hooks** - fix issues first
- Common pre-commit checks may include:
  - Code formatting (prettier, black, gofmt)
  - Linting (eslint, pylint, golint)
  - Security scanning (bandit, semgrep)
  - Commit message validation
  - File size and binary file checks

#### 5. Pushing and Pull Request Creation
```bash
# Push feature branch
git push origin feature/123-brief-description

# Create PR with mandatory format
# PR title MUST start with: "Fixes #issue-number: Brief description of changes"
```

#### 6. Pull Request Requirements
- **Mandatory title format**: "Fixes #issue-number: Brief description"
- **Must link to an issue**: Every PR must reference an existing issue
- **Template compliance**: Fill out PR template completely
- **Description requirements**:
  - Summary of changes
  - Testing performed
  - Breaking changes (if any)
  - Screenshots/demos for UI changes
- **Review requirements**:
  - At least one approving review
  - All CI checks passing
  - No merge conflicts

### Git Operations Best Practices

#### Keeping History Linear
```bash
# When pulling changes, always rebase
git pull origin main --rebase

# Interactive rebase to clean up commits before PR
git rebase -i main

# Squash commits if needed to maintain clean history
```

#### Handling Merge Conflicts
1. Fetch latest changes: `git fetch origin`
2. Rebase onto main: `git rebase origin/main`
3. Resolve conflicts in IDE
4. Stage resolved files: `git add .`
5. Continue rebase: `git rebase --continue`
6. Force push (safely): `git push origin feature-branch --force-with-lease`

#### Commit Message Best Practices
- Use imperative mood ("Add feature" not "Added feature")
- Keep subject line under 50 characters
- Capitalize subject line
- No period at end of subject line
- Separate subject and body with blank line
- Wrap body at 72 characters
- Explain what and why, not how

### Code Review Process

#### Before Requesting Review
- [ ] All tests pass locally
- [ ] Pre-commit hooks pass
- [ ] Code is self-documented with clear variable/function names
- [ ] Complex logic has comments explaining the "why"
- [ ] No debugging code or console.log statements
- [ ] Documentation updated if needed

#### Responding to Review Feedback
- Address all feedback before requesting re-review
- Use "Request changes" resolution to track fixes
- Add comments explaining your approach when needed
- Thank reviewers for their time and feedback

### Security and Compliance

#### Sensitive Information
- **NEVER** commit secrets, API keys, or passwords
- Use environment variables or secret management systems
- Scan for leaked secrets in pre-commit hooks
- Use `.gitignore` to prevent sensitive files from being tracked

#### Dependency Management
- Keep dependencies up to date
- Use lock files (package-lock.json, Pipfile.lock, go.sum)
- Audit dependencies for vulnerabilities regularly
- Document dependency changes in commit messages

### Emergency Procedures

#### Hotfix Process
1. Create hotfix branch from main
2. Make minimal necessary changes
3. Create emergency PR with expedited review (still must use "Fixes #issue-number" format)
4. Deploy immediately after merge
5. Create follow-up issue for proper fix if needed

#### Rollback Process
1. Identify problematic commit
2. Create revert commit: `git revert <commit-hash>`
3. Create emergency PR for revert
4. Document incident and lessons learned

### Tool Usage and Search Guidelines

#### Code Search and Navigation
- **Prefer ripgrep (`rg`)** for code search over grep - faster and more intuitive
- **Use eza** (aliased to `ls`) for displaying files and directories with better formatting
- **Search strategy**:
  - **For semantic searches** (variables, classes, functions, syntax tree elements): Use Tree-sitter MCP tools for precise AST-based analysis
  - **For pattern searches** (text patterns, strings, comments): Use `rg pattern` for simple text searches
  - Use `rg -t js pattern` to search specific file types
  - Use `rg -A 5 -B 5 pattern` for context around matches
  - Use `rg --files | rg pattern` to search file names

#### Semantic vs Pattern Search Guidelines
- **Use Tree-sitter MCP tools when searching for**:
  - Function definitions, class declarations, variable usage
  - Import/export statements and dependencies
  - Code structure and syntax tree elements
  - Symbol references and relationships
  - Complex code analysis requiring understanding of language semantics
- **Use ripgrep/text search tools when searching for**:
  - String literals, comments, documentation
  - Simple text patterns across files
  - Configuration values, URLs, file paths
  - TODO/FIXME comments and debugging statements

#### File and Directory Operations
```bash
# Use eza for better file listing
eza -la                    # detailed list with icons
eza -T                     # tree view
eza -la --git              # show git status

# Ripgrep examples
rg "function.*auth"        # find function definitions
rg -i "todo|fixme"         # case-insensitive search for todos
rg "import.*react" -t tsx  # search imports in TypeScript files
rg "console\.log" --files-with-matches  # find files with console.log
```

#### Search Best Practices
- Start with broad searches, then narrow down with filters
- Use file type filters (`-t`) to focus on relevant code
- Use `--files-with-matches` when you only need file names
- Combine tools: use `eza` to explore structure, `rg` to find code

### Automation and Tools

#### Required Tools Integration
- CI/CD pipeline status checks
- Automated testing (unit, integration, e2e)
- Code coverage reporting
- Security scanning (SAST, dependency scanning)
- Performance testing for critical paths

#### Additional Memories
- Never try to add or commit the .git or .venv directories. They are not meant to be committed
- For manual tools (lint, typecheck, test runners), ask the user to run them rather than executing automatically

This workflow ensures code quality, security, and maintainability while promoting collaboration and knowledge sharing through systematic code review processes.

## API Design Guidelines

These guidelines help create delightful developer experiences when building libraries, frameworks, or clean codebases. They focus on user-centric design principles for any software development context.

### Core Principles

#### Design end-to-end workflows, not individual functions and classes

- **Workflows come first, features second.** Every feature should exist to support a specific workflow, not provide capabilities "just in case"
- **Start with use cases.** Begin design discussions with code examples showing canonical workflows
- **Ask: "Do users really need to configure this parameter?"** Default answer should be "no" unless workflow evidence suggests otherwise
- **Every design review should prominently feature end-to-end workflow examples**

#### Carefully weigh whether new features should be included

- **It's okay to say no.** Every feature has maintenance, documentation, and cognitive costs
- **Broadly useful over niche.** Features should serve the majority of users, not specialized verticals
- **Proven best practices only.** Avoid bleeding-edge techniques that haven't achieved broad adoption
- **Find natural integration points.** Extend existing APIs rather than creating new ones when possible

### Minimize Cognitive Load

#### Automate everything that can be automated
- Make sensible defaults that reflect best practices
- Don't expose options that aren't important or don't match real use cases

#### Design simple and consistent workflows
- **No API should deal with internal implementation details.** APIs should let users talk about their problem, not your implementation
- **Introduce as few new concepts as possible.** Ideally one universal mental model underlying your system
- **Interchangeable objects should have identical APIs.** Enable easy swapping without code changes
- **Limit function signatures to 6-7 arguments maximum**
- **Best practices should be baked in.** The simplest usage should be the best practice

#### Naming and Type Guidelines
- **Use standard types over custom types.** Prefer built-in language types over specialized objects
- **Explicit, single-level configuration.** Avoid nested configuration dictionaries
- **Clear argument names.** Meaning should be obvious without implementation knowledge
- **Follow established conventions.** Use recognized terms and be consistent with domain standards
- **Use descriptive but concise names.** Avoid overly long names and overly generic ones

### Balance Expressivity vs. User-Friendliness

#### Simple use cases should be simple, advanced use cases should be possible
- **Don't increase cognitive load of common cases for niche ones**
- **Provide extension paths** for advanced users (inheritance, composition, plugins)
- **It's okay for advanced use cases to require custom implementation**

#### Keep APIs modular
- **Complex objects via composing simple objects.** Balance between complex signatures on fewer objects vs. more objects with simpler signatures
- **Classes for state/side-effects, functions for stateless operations**
- **Strict compartmentalization.** Don't mix concerns across API boundaries

### Documentation and Error Handling

#### Anticipate and prevent user errors
- **Catch errors early with validation**
- **Track common mistakes** and address them proactively
- **Consider automated fallbacks** instead of errors when appropriate

#### Provide excellent error messages
Good error messages should answer:
- What happened, in what context?
- What did the software expect?
- How can the user fix it?

Example of a good error message:
```
ValueError: You are passing a target array of shape (600, 1) while using loss 'categorical_crossentropy'.
'categorical_crossentropy' expects targets to be binary matrices (1s and 0s) of shape (samples, classes).
If your targets are integer classes, convert them via:

    from utils import to_categorical
    y_binary = to_categorical(y_int)

Alternatively, use 'sparse_categorical_crossentropy' which expects integer targets.
```

#### Write comprehensive documentation
- **Show, don't tell.** Use code examples for workflows and features
- **Assume minimal context.** Introduce specialized terms before using them
- **All documentation should include code examples**
- **Design deliberate user onboarding.** How will newcomers discover best practices?

#### Documentation structure
1. One-line description giving initial context
2. Detailed explanation of purpose and when to use
3. Reference materials if applicable
4. Arguments/parameters section
5. Examples demonstrating usage
6. Additional notes (edge cases, compatibility, further reading)

### Implementation Guidelines

#### Code Organization
- **Follow existing patterns.** Check neighboring files for conventions
- **Verify dependencies.** Check project files before assuming libraries exist
- **Match framework choice and naming conventions**
- **Follow security best practices.** Never expose or log secrets

#### Testing and Quality
- **Write tests for new features** following project conventions
- **Run linting and type checking** before considering work complete
- **Ensure code is self-documented** with clear names
- **Add comments explaining "why" for complex logic**
