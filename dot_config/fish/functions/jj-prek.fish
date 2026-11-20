function jj-prek --description 'Run every prek hook on the content of each commit of a revset'
    # Usage: jj-prek [-R <workspace>] [--] [<revset>]
    #   alias: jj prek [<revset>] (default @); jj-push calls it on what a push would publish.
    #
    # Effect: `jj run` checks out each commit of <revset> into its own scratch working copy
    # under .jj/run/ and runs `prek run --all-files` there, from the checkout's root. No commit
    # is rewritten (--ignore-changes): hook fixes are reported, not applied.
    #
    # Isolation: each checkout gets its own throwaway git index (`git init` + `git add -A -f`; -f also stages committed
    # files a .gitignore matches, so hooks see the whole commit). On a hook failure the shell
    # stays alive (no `exec`) to print `git diff --stat`: what the hooks modified.
    # prek only works inside a git repository, and a checkout under .jj/ or a jj workspace has
    # no .git of its own: git walks up to the repo root's colocated .git and prek then checks
    # the root's files, passing a commit it never saw. The .git stays inside .jj/run/, which jj
    # never snapshots.
    #
    # prek comes from `uv run --no-sync --with prek`: the version the commit's own pyproject.toml
    # pins (what its venv would hold), else the latest release. --no-sync keeps uv from
    # installing the project's dependencies into each checkout.
    #
    # A commit without a prek config (prek.toml, .pre-commit-config.yaml or .yml) has no hooks
    # to fail and passes: prek itself would exit 2 on it, blocking every push of a hookless repo.
    #
    # Returns jj run's status: 0 when every hook passes on every commit (also for an empty
    # revset), non-zero otherwise, with the failing revision named on stderr.
    argparse 'R=' -- $argv
    or return 2
    set -l repo_args
    if set -q _flag_R
        set repo_args -R $_flag_R
    else if test -n "$JJ_WORKSPACE_ROOT"
        # `jj util exec` does not chdir into the -R target; this is how the alias knows it.
        set repo_args -R "$JJ_WORKSPACE_ROOT"
    end
    set -l rev @
    test -n "$argv[1]"; and set rev $argv[1]
    jj $repo_args run --ignore-changes --root -r $rev -- \
        sh -c '[ -e prek.toml ] || [ -e .pre-commit-config.yaml ] || [ -e .pre-commit-config.yml ] || exit 0
               git init -q && git add -A -f && uv run --no-sync --with prek prek run --all-files
               rc=$?
               [ $rc -eq 0 ] || git --no-pager diff --stat
               exit $rc'
end
