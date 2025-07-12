---
description: "Generate a detailed, PR-ready Markdown implementation plan for a GitHub issue"
allowed-tools: ["mcp__github__get_issue", "mcp__github__get_issue_comments", "mcp__github__search_code", "Bash", "Read", "Grep"]
---

# Issue Implementation Plan Generator

## Your Task
Act as a senior engineer. Your only output is a single, comprehensive Markdown implementation plan for the given issue ($ARGUMENTS). The plan must be structured into one or more actionable Pull Requests.

## Process
1.  **Analyze:** Investigate the issue, comments, and codebase to determine the root cause.
2.  **Design:** Formulate a complete solution.
3.  **Deconstruct for PRs:** Logically group the work into one or more sequential Pull Requests. A simple issue might only need one PR.
4.  **Plan:** For each proposed PR, create a detailed, step-by-step implementation guide with code-level detail.
5.  **Report:** Generate the final Markdown report using the exact format below.

## 🚨 Critical: Output Format
- Your entire response MUST be a single Markdown block.
- Do NOT write any code, modify files, or add any text outside the report.

## Markdown Report Template
```markdown
# Implementation Plan: Issue #[issue_number] - [issue_title]

**Report Generated:** `date -u +"%Y-%m-%dT%H:%M:%SZ"`

## 1. Executive Summary

*   **Problem:** [Briefly describe the core problem and its user-facing impact.]
*   **Proposed Solution:** [Provide a high-level summary of the technical solution and how it will be broken down into Pull Requests.]

## 2. In-Depth Analysis

*   **Root Cause:** [Detailed explanation of the technical root cause.]
*   **Affected Components:** [List all files, classes, or modules affected.]
*   **Requirements & Constraints:** [List all requirements for the fix.]

## 3. Pull Request Implementation Plan

### Pull Request 1: [Title of the first PR, e.g., "Refactor Core Logic and Add Interfaces"]

*   **Objective:** [What is the specific goal of this Pull Request?]
*   **Step 1.1:** [Descriptive Title for Step 1]
    *   **File(s):** `path/to/file_to_modify.ext`
    *   **Function/Method:** `functionOrMethodToChange`
    *   **Details:** [Describe the change, e.g., "Add a null check."]
    *   **Code Guidance:**
        ```[language]
        // Provide a pseudo-code or an actual code snippet demonstrating the change.
        if (input == null) {
          throw new IllegalArgumentException("Input cannot be null.");
        }
        ```
    *   **Reasoning:** [Explain why this change is necessary.]
*   **Step 1.2:** [Descriptive Title for Step 2]
    *   ... (repeat structure)
*   **Testing for this PR:**
    *   [Outline the specific tests that must pass before this PR can be merged.]

### Pull Request 2: [Title of the second PR, e.g., "Update UI Components to Use New Interfaces"]

*   **Objective:** [What is the specific goal of this Pull Request?]
*   **Step 2.1:** ...
*   **(Repeat the structure for all subsequent Pull Requests. For simple issues, there will only be one PR section.)**

## 4. Overall Validation Strategy

*   **End-to-End Testing:** [Describe how to manually verify the complete solution after all PRs are merged.]
*   **Documentation:** [List any user-facing or internal documentation that needs to be updated.]

## 5. Risks and Mitigation

*   **Potential Risks:** [Identify any potential risks for the overall solution.]
*   **Mitigation Strategy:** [For each risk, describe the steps to mitigate it.]
```
