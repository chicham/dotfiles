---
name: gh-issues
description: "Create GitHub issues with structured bodies and wire dependency relationships (blocked_by / sub-issues) via the GitHub REST API. Use when the user wants to file multiple related issues, plan a multi-step implementation, or convert a proposal into tracked issues."
argument-hint: plan|create|link|sub-link [args...]
allowed-tools: Bash(gh *), Bash(jq *), Bash(yq *), Bash(cat *), Bash(printf *), Read, Write
---

# gh-issues — Create issues correctly with dependency wiring

GitHub now natively supports **issue dependencies** (`blocked_by` / `blocking`) and **sub-issues** (parent / child). The `gh issue create` CLI does **not** wire these for you. You must call the REST API after creating the issues.

## Why this skill exists

Mistakes I made before this skill existed:
- Created 8 issues with cross-references like "Depends on #67" written into the body **as text**, with no machine-readable dependency.
- Tried `gh api -f issue_id=...` (string) — got `422 Invalid property /issue_id: not of type integer`.
- Confused the issue **number** (per-repo, e.g. `65`) with the issue internal **id** (global integer, e.g. `4408661826`). The REST endpoint takes the **id**.

This skill prevents those.

## Quick reference

| What | API | Method | Path | Body |
|---|---|---|---|---|
| Add `blocked_by` | REST | `POST` | `/repos/{owner}/{repo}/issues/{number}/dependencies/blocked_by` | `{"issue_id": <id>}` |
| Remove `blocked_by` | REST | `DELETE` | `/repos/{owner}/{repo}/issues/{number}/dependencies/blocked_by/{id}` | — |
| Add sub-issue | GraphQL | mutation | `addSubIssue` | `{issueId, subIssueId}` (node IDs) |
| Get internal id from number | REST | `GET` | `/repos/{owner}/{repo}/issues/{number}` | response `.id` |
| Get node id from number | REST | `GET` | `/repos/{owner}/{repo}/issues/{number}` | response `.node_id` |

Required header for dependency endpoints: `X-GitHub-Api-Version: 2026-03-10`.

## Bash helpers (copy into your session)

```bash
# Resolve an issue NUMBER (e.g. 65) to its internal numeric id (e.g. 4408661826)
gh_issue_id() {
  local repo="$1" num="$2"
  gh api "repos/$repo/issues/$num" --jq .id
}

# Resolve to the GraphQL node id (e.g. I_kwDOONt0aM8AAAABBsbXQg) — used for sub-issues
gh_issue_node_id() {
  local repo="$1" num="$2"
  gh api "repos/$repo/issues/$num" --jq .node_id
}

# Mark issue $blocked as blocked_by issue $blocker. Both are issue NUMBERS.
gh_block() {
  local repo="$1" blocked="$2" blocker="$3"
  local blocker_id; blocker_id=$(gh_issue_id "$repo" "$blocker")
  gh api -X POST "repos/$repo/issues/$blocked/dependencies/blocked_by" \
    -H "X-GitHub-Api-Version: 2026-03-10" \
    -F "issue_id=$blocker_id" --jq '.issue_dependencies_summary'
}

# Make issue $child a sub-issue of $parent. Issue NUMBERS.
gh_subissue() {
  local repo="$1" parent="$2" child="$3"
  local p c
  p=$(gh_issue_node_id "$repo" "$parent")
  c=$(gh_issue_node_id "$repo" "$child")
  gh api graphql -f query='
    mutation($parent:ID!, $child:ID!) {
      addSubIssue(input:{issueId:$parent, subIssueId:$child}) {
        subIssue { number title }
      }
    }' -f parent="$p" -f child="$c"
}
```

**Critical syntax rules:**
- `gh api -F` (uppercase) coerces values to typed JSON (integer here). `-f` (lowercase) sends strings — REST rejects with 422.
- For GraphQL, `-f` is correct (variables are strings in the query string).
- The `issue_id` body field is the **internal `.id`**, never the per-repo `.number`.

## Workflow: `plan` → `create` → `link`

When a user asks for "create N issues for these changes" — this is the routine.

### 1. `plan` — write the issue spec to a file first

Don't open the API yet. Write each issue as a YAML/JSON record into a temp file. This makes the plan inspectable, lets you fix titles before they're public, and keeps issue numbers reproducible if you have to retry.

Example `/tmp/issues.yaml`:

```yaml
- key: A          # local handle, not a GitHub field
  title: "chore: clean up stale references"
  body_file: /tmp/issue-body-A.md
  labels: [chore]
  blocked_by: []  # local handles of blockers
- key: 0
  title: "ci: hermetic bats test suite"
  body_file: /tmp/issue-body-0.md
  labels: [ci]
  blocked_by: [A]
- key: 6
  title: "feat(packages): add gh to core brews"
  body_file: /tmp/issue-body-6.md
  labels: [enhancement]
  blocked_by: [0]
```

Confirm the plan with the user before creating.

### 2. `create` — file each issue, capture the number

```bash
REPO="owner/repo"
declare -A KEY_TO_NUMBER

for key in $(yq -r '.[].key' /tmp/issues.yaml); do
  title=$(yq -r ".[] | select(.key==\"$key\") | .title" /tmp/issues.yaml)
  body_file=$(yq -r ".[] | select(.key==\"$key\") | .body_file" /tmp/issues.yaml)
  labels=$(yq -r ".[] | select(.key==\"$key\") | .labels | join(\",\")" /tmp/issues.yaml)

  # Verify labels exist before creating — gh rejects unknown labels
  for l in ${labels//,/ }; do
    gh label list --repo "$REPO" --json name --jq '.[].name' | grep -qx "$l" \
      || { echo "Unknown label: $l on $REPO"; exit 1; }
  done

  url=$(gh issue create --repo "$REPO" --title "$title" --body-file "$body_file" \
        ${labels:+--label "$labels"})
  num=${url##*/}
  KEY_TO_NUMBER[$key]=$num
  echo "$key -> #$num"
done
```

### 3. `link` — wire dependencies after all issues exist

```bash
for key in $(yq -r '.[].key' /tmp/issues.yaml); do
  blocked=${KEY_TO_NUMBER[$key]}
  for blocker_key in $(yq -r ".[] | select(.key==\"$key\") | .blocked_by[]" /tmp/issues.yaml); do
    blocker=${KEY_TO_NUMBER[$blocker_key]}
    gh_block "$REPO" "$blocked" "$blocker"
  done
done
```

## Common mistakes — read before each use

1. **"Depends on #N" in the issue body is not a dependency.** It's a hyperlink. GitHub does not enforce ordering. Always use the API.
2. **`gh api -f issue_id=123`** sends the string `"123"` and fails with 422. Use `-F`.
3. **Don't use the issue number** as `issue_id`. Use `.id` from `GET /repos/.../issues/N`.
4. **Don't create issues in the wrong order then try to fix later.** GitHub assigns numbers monotonically; numbers in issue bodies become wrong if you re-create. Fix the plan, not the issues.
5. **Labels are not auto-created.** `gh issue create --label foo` fails if `foo` doesn't exist. Verify or create labels first (`gh label create`).
6. **Don't put long bodies inline with `--body "$(cat <<EOF ...`)"**.  Heredoc inside `$(...)` mangles backticks and `$` escapes. Write the body to a file and use `--body-file`.
7. **Sub-issues vs blocked-by:** Sub-issues are a hierarchy (parent contains children, shown as a checklist on the parent). Blocked-by is a lateral DAG (independent issues with ordering). For multi-step implementation plans, **prefer sub-issues** if there is a natural epic; **use blocked-by** for "X must finish before Y can start" without a parent.

## Confirming the wiring worked

```bash
# Check from either side
gh api repos/$REPO/issues/$N --jq '.issue_dependencies_summary'
# {"blocked_by":1,"total_blocked_by":1,"blocking":0,"total_blocking":0}

# List the actual blockers
gh api repos/$REPO/issues/$N/dependencies/blocked_by --jq '.[] | {number, title}'
```

## When the user says "create issues for these changes"

1. **Pause and write the plan to a file** — never go straight to `gh issue create`.
2. **Show the user the plan list** (titles + dependencies) and ask for confirmation. Issues on a public repo are visible immediately and not easy to clean up.
3. **Verify all labels exist** in the target repo before any creation call.
4. **Create issues sequentially** (so issue numbers are predictable in case you need to reference them in later bodies).
5. **Wire dependencies in a separate pass** with `gh_block` / `gh_subissue` after every issue has a number.
6. **Verify the wiring** with `issue_dependencies_summary` on each blocked issue.

## Out of scope (use other tools)

- Modifying issues after creation (use `gh issue edit`).
- Bulk closing / state changes (use `gh issue close`).
- Project board / milestone wiring (separate API surface, not in this skill yet).
