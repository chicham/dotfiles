#!/usr/bin/env bash
# land, sync and deploy end to end on a fresh scratch repo, with main immutable.
S=$1; R=$S/t/repo; A=$R/.workspaces/a; B=$R/.workspaces/b
pass=0; fail=0
d() { jj -R $R log --no-graph -r "$1" -T 'description.first_line() ++ "\n"'; }
c() { jj -R "$1" "${@:2}" >/dev/null 2>&1; }
check() { # description, actual, expected
  if [ "$2" = "$3" ]; then pass=$((pass+1)); echo "ok   $1"; else fail=$((fail+1)); echo "FAIL $1: got '$2', want '$3'"; fi
}

$S/setup.sh $S
jj -R $A land >/dev/null 2>&1; check "land a: exit" $? 0
check "land a: main" "$(d main)" "feat: a1"
jj -R $B land >/dev/null 2>&1; check "land stale b: exit" $? 0
check "land stale b: main" "$(d main)" "feat: b1"
check "land stale b: b1 on a1" "$(d 'description(substring:"feat: b1")-')" "feat: a1"

$S/setup.sh $S
c $R workspace add $R/.workspaces/c -r main; echo o > $R/.workspaces/c/o.txt; c $R/.workspaces/c commit -m 'feat: o1'; c $R workspace forget c; rm -rf $R/.workspaces/c
c $R new main -m 'feat: landed'; echo l > $R/l.txt; c $R bookmark set main -r @; c $R new main
jj -R $A sync >/dev/null 2>&1; check "sync: exit" $? 0
check "sync: my arm on main" "$(d 'description(substring:"feat: a1")-')" "feat: landed"
check "sync: orphan on main" "$(d 'description(substring:"feat: o1")-')" "feat: landed"
check "sync: owned arm untouched" "$(d 'description(substring:"feat: b1")-')" "init"
check "sync: no fetch" "$(jj -R $R op log --no-graph -n 10 -T 'description ++ "\n"' | grep -c fetch)" "0"
jj -R $B sync >/dev/null 2>&1
jj -R $A deploy --no-push >/dev/null 2>&1; check "deploy --no-push: exit" $? 0
check "deploy: wip parents" "$(d 'wip-' | sort | tr '\n' ',')" "feat: a1,feat: b1,feat: o1,"
jj -R $A deploy >/dev/null 2>&1; check "deploy push: exit" $? 0
check "deploy push: deploy has wip" "$(git -C $S/t/deploy.git log -1 --format=%s wip)" "chore: wip megamerge"

# An empty described scratch above wip does not block deploy; content above wip does.
c $R new wip -m 'wip: scratch'
jj -R $A deploy --no-push >/dev/null 2>&1; check "deploy: empty scratch above wip allowed" $? 0
echo s > $R/s.txt; jj -R $R status >/dev/null 2>&1
jj -R $A deploy --no-push >/dev/null 2>&1; check "deploy: content above wip refused" $? 1

# An orphan arm that conflicts with main stays on its old base, its own rebase reverted,
# and a peer's later operation is not reverted in its place.
$S/setup.sh $S
c $R workspace add $R/.workspaces/c -r main; echo o > $R/.workspaces/c/o.txt; echo O > $R/.workspaces/c/base.txt; c $R/.workspaces/c commit -m 'feat: o1'; c $R workspace forget c; rm -rf $R/.workspaces/c
echo A > $A/base.txt; c $A describe -m 'feat: a1 base'
jj -R $A land >/dev/null 2>&1; check "land with conflicting orphan: exit" $? 0
check "conflicting orphan left on old base" "$(d 'description(substring:"feat: o1")-')" "init"
check "no conflict left behind" "$(d 'conflicts()' | wc -l | tr -d ' ')" "0"
check "main still landed" "$(d main)" "feat: a1 base"

# A stale conflicted wip (3 parents) must not block its own rebuild: on such a merge the
# empty() revset misses wip although it has no content (the `empty` template is right).
$S/setup.sh $S
c $R workspace add $R/.workspaces/c -r main; echo c > $R/.workspaces/c/c.txt; c $R/.workspaces/c commit -m 'feat: c1'
echo A > $A/base.txt; c $A describe -m 'feat: a1 base'
echo B > $B/base.txt; c $B describe -m 'feat: b1 base'
jj -R $A deploy --no-push >/dev/null 2>&1; check "conflicting arms: deploy refuses" $? 1
check "stale wip is conflicted" "$(jj -R $R log --no-graph -r 'wip & conflicts()' -T '"y"')" "y"
check "precondition: empty() misses the conflicted wip" "$(jj -R $R log --no-graph -r 'wip & empty()' -T '"y"')" ""
# b fixes its arm with a NEW commit: wip still sits on the old tip, so it stays conflicted
c $B new; jj -R $B restore --from main root:base.txt >/dev/null 2>&1; c $B describe -m 'fix: b2 drop base change'
check "wip still conflicted before the rebuild" "$(jj -R $R log --no-graph -r 'wip & conflicts()' -T '"y"')" "y"
jj -R $A deploy --no-push >/dev/null 2>&1; check "deploy rebuilds a stale conflicted wip" $? 0
check "rebuilt wip is conflict-free" "$(jj -R $R log --no-graph -r 'wip & conflicts()' -T '"y"')" ""

# A repo whose main requires a pull request: the land is refused, `gh` is a stub.
$S/setup.sh $S
mkdir -p $S/fakebin; printf '#!/bin/sh\necho "${FAKE_GH_N:-0}"\n' > $S/fakebin/gh; chmod +x $S/fakebin/gh
c $R git remote set-url origin https://github.com/acme/widgets.git
export JJ_GH=$S/fakebin/gh
FAKE_GH_N=1 jj -R $A land >/dev/null 2>&1; check "land refused when main requires a PR" $? 1
check "refused land leaves main" "$(d main)" "init"
FAKE_GH_N=0 jj -R $A land >/dev/null 2>&1; check "land allowed when no PR rule (control)" $? 0
check "allowed land moved main" "$(d main)" "feat: a1"
$S/setup.sh $S
c $R git remote set-url origin https://github.com/acme/widgets.git
FAKE_GH_N=1 JJ_LAND_LOCAL=1 jj -R $A land >/dev/null 2>&1; check "JJ_LAND_LOCAL overrides the PR rule" $? 0
check "overridden land moved main" "$(d main)" "feat: a1"
msg=$(jj -R $A pr 'description(substring:"feat: a1")' 2>&1); check "pr on a landed commit: exit" $? 2
check "pr on a landed commit: explains" "$(grep -c 'landed with jj land' <<<"$msg")" "1"
msg=$(jj -R $A pr 'nonexistent_bookmark' 2>&1); check "pr on a bad revision: still errors" $? 1

# jj-stack joins the lines of a paragraph into one line of the PR body, so pr refuses an issue
# footer that shares its paragraph. jj-stack is a stub: the gate must decide before it runs.
$S/setup.sh $S
printf '#!/bin/sh\nexit 0\n' > $S/fakebin/jj-stack; chmod +x $S/fakebin/jj-stack
glued=$'feat: a1\n\nBody.\n\nCloses: #1\nCo-Authored-By: X <x@example.com>'
split=$'feat: a1\n\nBody.\n\nCloses: #1\n\nCo-Authored-By: X <x@example.com>'
c $A describe -r 'description(substring:"feat: a1")' -m "$glued"
msg=$(PATH=$S/fakebin:$PATH jj -R $A pr 'description(substring:"feat: a1")' 2>&1); check "pr footer glued to a trailer: exit" $? 1
check "pr footer glued to a trailer: names the gate" "$(grep -c 'issue footer sharing its paragraph' <<<"$msg")" "1"
c $A describe -r 'description(substring:"feat: a1")' -m "$split"
msg=$(PATH=$S/fakebin:$PATH jj -R $A pr 'description(substring:"feat: a1")' 2>&1)
check "pr footer in its own paragraph: gate passes (control)" "$(grep -c 'issue footer sharing its paragraph' <<<"$msg")" "0"

# mm_origin_forks(): arms forking off pushed history other than main, remote-only branches ignored.
$S/setup.sh $S
check "origin forks: none while arms sit on main" "$(d 'mm_origin_forks()')" ""
c $R new main -m 'feat: landed'; echo l > $R/l.txt; c $R bookmark set main -r @; c $R new main
check "origin forks: known-bad, arms left on the pushed base" "$(d 'mm_origin_forks()')" "init"
jj -R $A sync >/dev/null 2>&1; jj -R $B sync >/dev/null 2>&1
check "origin forks: none once the arms follow an unpushed main" "$(d 'mm_origin_forks()')" ""
c $R new 'main@origin' -m 'feat: remote-only'; c $R bookmark create rb -r @; c $R git push --bookmark rb --remote origin
c $R bookmark delete rb; c $R new main
check "origin forks: remote-only branch is ignored" "$(d 'mm_origin_forks()')" ""
check "origin forks: that branch is a real commit off pushed history" "$(d 'description(substring:"feat: remote-only")-')" "init"
c $R workspace add $R/.workspaces/f -r 'main@origin'; echo f > $R/.workspaces/f/f.txt; c $R/.workspaces/f commit -m 'feat: forked off origin'
check "origin forks: a local arm off main@origin is named" "$(d 'mm_origin_forks()')" "init"
check "origin forks: mm_stale already flags the same arm" "$(d 'mm_stale(description(substring:"feat: forked off origin"))')" "init"

# Two copies of one change: deploy refuses rather than merging both into wip.
$S/setup.sh $S
# The arm d1 is not under wip yet, so only d1 diverges and the wip bookmark stays whole.
c $A new main -m 'feat: d1'; echo d > $A/d.txt; c $A new
op=$(jj -R $A op log -n 1 --no-graph -T 'id.short() ++ "\n"')
c $A describe -r 'description(substring:"feat: d1")' -m 'feat: d1 v2'
c $A --at-op $op describe -r 'description(substring:"feat: d1")' -m 'feat: d1 v3'
check "divergent: two copies of d1" "$(d 'divergent() & mutable() & description(glob:"feat: d1*")' | sort | tr '\n' ',')" "feat: d1 v2,feat: d1 v3,"
why=$(jj -R $A deploy --no-push 2>&1 >/dev/null | head -1)
check "divergent: deploy refuses on the copies" "${why%%;*}" "deploy: divergent copies"

echo "pass=$pass fail=$fail"
