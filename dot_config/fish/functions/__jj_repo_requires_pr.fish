function __jj_repo_requires_pr --description 'Succeed only when GitHub says main requires a pull request'
    # Shared by land.fish. $argv is the `-R <workspace>` pair (or nothing).
    # Reads the repository rulesets that apply to main (`gh api .../rules/branches/main`).
    # Fails, meaning "not known to require one", whenever any step cannot answer: no `gh`,
    # no GitHub `origin`, no network, no access. Classic branch protection is not visible
    # through this endpoint without admin rights, so it is not detected.
    # $JJ_GH names the gh binary (default: gh on PATH); fish's own startup reorders PATH,
    # so a test cannot shadow gh by PATH alone.
    set -l gh gh
    set -q JJ_GH; and set gh $JJ_GH
    command -q $gh; or return 1
    set -l url (jj $argv git remote list 2>/dev/null | string replace -rf '^origin\s+(\S+)$' '$1')
    set -l slug (string match -r 'github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?$' -- $url)
    or return 1
    set -l n ($gh api repos/$slug[2]/$slug[3]/rules/branches/main \
        --jq '[.[] | select(.type == "pull_request")] | length' 2>/dev/null)
    or return 1
    test "$n" -gt 0
end
