#!/usr/bin/env bash
S=$1
R=$S/t/repo
A=$R/.workspaces/a
B=$R/.workspaces/b
pass=0
fail=0
g() { # expected (0=allow, ask, 2=block) description command
  local out err code got want
  err=$(mktemp)
  out=$(jq -n --arg c "$3" '{tool_name:"Bash",tool_input:{command:$c}}' | fish -c jj-megamerge-guard 2> "$err")
  code=$?
  if [ "$code" = 2 ]; then got=block; elif grep -q '"ask"' <<< "$out"; then got=ask; else got=allow; fi
  case "$1" in 0) want=allow ;; 2) want=block ;; *) want=$1 ;; esac
  if [ "$got" = "$want" ]; then
    pass=$((pass + 1))
    r=ok
  else
    fail=$((fail + 1))
    r=FAIL
  fi
  printf '%-4s got=%-5s want=%-5s  %s\n' $r $got $want "$2"
  { [ "$r" = FAIL ] || [ -n "${VERBOSE:-}" ]; } && {
    cat "$err"
    printf '%s\n' "$out"
  } | sed 's/^/       /'
  rm -f "$err"
}
c() { jj -R "$1" "${@:2}" > /dev/null 2>&1; }
fresh() { $S/setup.sh $S; }

fresh
echo "== clean graph"
g 0 "commit in workspace a" "jj -R $A commit -m 'feat: a2'"
g 0 "commit paths are filesets, not revisions" "jj -R $A commit -m 'feat: a2' base.txt"
g 0 "commit paths before -m" "jj -R $A commit base.txt 'glob:*.txt' -m 'feat: a2'"
g 0 "new in workspace a (default parent)" "jj -R $A new"
g 0 "new main (fresh arm)" "jj -R $A new main"
g 0 "non-jj command" "ls -la"
g 0 "jj new inside a message is not a command" "echo 'jj -R $A new wip x y'"
g 0 "redirection does not look like a parent" "jj -R $A new 2>&1"
g 0 "read-only jj" "jj -R $A log -r 'wip'"
g 2 "missing -R" "jj commit -m x"
g 2 "relative -R" "jj -R repo commit -m x"
g 2 "commit in repo root" "jj -R $R commit -m x"
g 2 "new main in repo root" "jj -R $R new main"
g 0 "workspace add from repo root (first workspace)" "jj -R $R workspace add $R/.workspaces/x -r main"
g 0 "new with two parents (deploy and commit catch the merge)" "jj -R $A new 'description(substring:\"feat: a1\")' 'description(substring:\"feat: b1\")'"
g 0 "new on main and wip (never blocked)" "jj -R $A new main wip"
g 0 "new wip (scratch edit across arms)" "jj -R $A new wip"
g 2 "new -B" "jj -R $A new -B 'description(substring:\"feat: a1\")'"
g 2 "new -A main (rebases every arm)" "jj -R $A new -A main"
g 2 "new --insert-after=main" "jj -R $A new --insert-after=main"
g 2 "new --after on a tip" "jj -R $A new --after 'description(substring:\"feat: b1\")'"
g 2 "squash -A main" "jj -R $A squash -A main -m x"
g 2 "rebase -r @ -A main" "jj -R $A rebase -r @ -A main"
g 2 "rebase --insert-after=main" "jj -R $A rebase -r @ --insert-after=main"
g 2 "rebase -Amain (attached)" "jj -R $A rebase -r @ -Amain"
g 2 "rebase -A on a revset resolving to main" "jj -R $A rebase -r @ -A 'bookmarks(exact:\"main\")'"
g 2 "rebase -A main without -R" "jj rebase -r @ -A main"
g 2 "rebase -A on my own arm commit (-A never allowed)" "jj -R $A rebase -r @ -A 'description(substring:\"feat: a1\")'"
g 0 "describe -m mentioning -A main is not a flag" "jj -R $A describe -m 'docs: explain -A main'"
g 0 "jj start passes the guard (jj itself has no such command)" "jj -R $A start -m x"
g 0 "jj stack passes the guard (jj itself has no such command)" "jj -R $A stack 'description(substring:\"feat: a1\")'"
g 2 "compound: second segment bad" "cd /tmp && jj -R $R commit -m x"
g 2 "redirect 2>&1 does not hide a root commit" "jj -R $R commit -m x 2>&1"
g 2 "redirect > /dev/null does not hide a root commit" "jj -R $R commit -m x > /dev/null"
g 2 "attached redirect does not hide a root commit" "jj -R $R commit -m x 2>/dev/null"
g 0 "new main with 2>&1 passes" "jj -R $A new main 2>&1"
g 2 "unresolvable revset fails closed" "jj -R $A describe -r \$H -m x"
g 0 "new on an unresolvable revset is left to jj" "jj -R $A new \$H"
g 0 "deliberate stack on b's tip" "jj -R $A new 'description(substring:\"feat: b1\")'"

echo "== scratch @ on wip"
c $A new wip
g 0 "new above the scratch (never blocked)" "jj -R $A new"
g 2 "commit the scratch" "jj -R $A commit -m 'fix: x'"
g 2 "describe the scratch (it never becomes a commit)" "jj -R $A describe -m 'fix: x'"
g 0 "back to my arm" "jj -R $A new 'description(substring:\"feat: a1\")'"
g 0 "new main from the scratch" "jj -R $A new main"
fresh

echo "== allowlist"
g 0 "log with flags" "jj -R $A log -r 'arm_tips()' --no-graph -T description"
g 0 "diff --git" "jj -R $A --no-pager diff --git"
g 0 "op log" "jj -R $A op log -n 5"
g 0 "file show" "jj -R $A file show -r main base.txt"
g 0 "describe my @" "jj -R $A describe -m 'feat: a2'"
g 2 "describe main (not mine)" "jj -R $A describe -r main -m x"
g 2 "describe with -m before the rev checks the rev" "jj -R $A describe -m x main"
g 2 "unknown global option" "jj --config ui.color=never -R $A log"
g 0 "sync runs" "jj -R $A sync"
g 0 "two runs in one command" "jj -R $A squash -u && jj -R $A sync"
g 2 "allowed then blocked: block wins" "jj -R $A sync && jj -R $A new -A main"
g 0 "deploy --no-push runs" "jj -R $A deploy --no-push"
g 0 "squash runs" "jj -R $A squash -u"
g 0 "abandon runs" "jj -R $A abandon @"
g 0 "bookmark set runs" "jj -R $A bookmark set feat -r @"
g 0 "git fetch runs" "jj -R $A git fetch"
g 0 "push a named bookmark runs" "jj -R $A git push --bookmark wip --remote deploy"
g 0 "push main runs when no arm forks" "jj -R $A git push -b main"
g 2 "bare git push" "jj -R $A git push"
g 2 "git push --all" "jj -R $A git push --all"
g 2 "git push -r" "jj -R $A git push -r @"
g 2 "split -i" "jj -R $A split -i"
g 2 "abandon --ignore-immutable" "jj -R $A abandon main --ignore-immutable"
g 0 "op abandon is not a megamerge rule" "jj -R $A op abandon ..@-"
g 0 "other subcommands run" "jj -R $A duplicate @"

echo "== mid-arm: a has a2 on top of a1"
echo a2 > $A/a2.txt
c $A commit -m 'feat: a2'
g 0 "new on mid-arm commit (describe catches the fork)" "jj -R $B new 'description(substring:\"feat: a1\")'"
c $B new 'description(substring:"feat: a1")'
g 2 "describe on a fork from a mid-arm commit" "jj -R $B describe -m 'feat: b2'"
g 0 "new on a's tip" "jj -R $B new 'description(substring:\"feat: a2\")'"

echo "== stale base: main advances"
fresh
c $R new main -m 'feat: landed'
echo l > $R/l.txt
c $R bookmark set main -r @
c $R new main
g 2 "commit on stale arm" "jj -R $A commit -m 'feat: a2'"
g 0 "new on stale arm" "jj -R $A new"
g 2 "describe on stale arm" "jj -R $A describe -m 'feat: a2'"
c $A rebase -s 'roots(main..@)' -o main
g 0 "after rebasing own arm" "jj -R $A commit -m 'feat: a2'"

echo "== merge inside arm"
fresh
c $A new 'description(substring:"feat: a1")' 'description(substring:"feat: b1")' -m 'feat: merged'
g 2 "commit on arm containing merge" "jj -R $A commit -m x"
g 2 "describe on arm containing merge" "jj -R $A describe -m x"

echo "== conflict inside arm"
fresh
echo x > $A/base.txt
c $A commit -m 'feat: a2 edits base'
c $A new 'description(substring:"feat: a1")' -m 'feat: a3 edits base'
echo y > $A/base.txt
c $A new
c $A rebase -r 'description(substring:"feat: a3 edits base")' -o 'description(substring:"feat: a2 edits base")'
c $A new 'description(substring:"feat: a3 edits base")'
g 0 "new on a conflicted commit (recovery)" "jj -R $A new 'description(substring:\"feat: a3 edits base\")'"
g 2 "commit on conflicted arm" "jj -R $A commit -m x"
g 2 "describe on conflicted arm" "jj -R $A describe -m x"

echo "== someone stacked on my tip, then I extend"
fresh
c $B new 'description(substring:"feat: a1")'
echo b2 > $B/b2.txt
c $B commit -m 'feat: b2 on a1'
g 2 "commit on a (b stacked on a1)" "jj -R $A commit -m 'feat: a2'"
g 2 "describe on a (b stacked on a1)" "jj -R $A describe -m 'feat: a2'"
g 0 "commit on b (deliberate stack)" "jj -R $B commit -m 'feat: b3'"

echo "== fork: two arms share a non-tip base"
fresh
c $A new main -m 'feat: shared'
echo s > $A/s.txt
c $A new -m 'feat: a-on-shared'
echo q > $A/q.txt
c $A new
c $B new 'description(substring:"feat: shared")' -m 'feat: b-on-shared'
echo r > $B/r.txt
c $B new
g 2 "commit on b forked from a's mid commit" "jj -R $B commit -m x"

echo "== push main while an arm forks inside unpushed main"
fresh
c $R new main -m 'feat: X'
echo x > $R/x.txt
c $R bookmark set main -r @
c $R new main
c $B rebase -s 'roots(chain(@))' -o main
c $R new main -m 'feat: Y'
echo y > $R/y.txt
c $R bookmark set main -r @
c $R new main
g 2 "push main blocked (b forks from unpushed X)" "jj -R $A git push --bookmark main"
g 0 "push wip still runs" "jj -R $A git push --bookmark wip --remote deploy"

echo "== an arm left out of wip"
fresh
echo b2 > $B/b2.txt
c $B commit -m 'feat: b2'
g 2 "commit in a blocked while b2 is outside wip" "jj -R $A commit -m 'feat: a2'"
g 0 "describe in a runs while b2 is outside wip (not a's fault)" "jj -R $A describe -m 'feat: a2'"
g 0 "new main runs while b2 is outside wip" "jj -R $A new main"
g 0 "b extends its own arm" "jj -R $B new"
g 0 "b stacks on its own tip" "jj -R $B new 'description(substring:\"feat: b2\")'"
g 2 "push wip blocked while b2 is outside it" "jj -R $A git push --bookmark wip --remote deploy"
g 2 "push wip by -b blocked too" "jj -R $A git push -b wip --remote deploy"
g 0 "push of another bookmark is not gated on wip" "jj -R $A git push -b main"
c $A deploy --no-push
g 0 "commit in a runs once wip holds b2" "jj -R $A commit -m 'feat: a2'"
g 0 "push wip runs once it holds every arm" "jj -R $A git push --bookmark wip --remote deploy"
echo u > $B/u.txt
c $B status # the guard reads the graph as last snapshotted
g 2 "push wip blocked while b has undescribed work" "jj -R $A git push --bookmark wip --remote deploy"

echo "== repo root: commands that touch no working copy (orphan arm o1; a, b are owned; d is idle)"
fresh
c $R workspace add $R/.workspaces/o -r main
echo o > $R/.workspaces/o/o.txt
c $R/.workspaces/o commit -m 'feat: o1'
c $R workspace forget o
rm -rf $R/.workspaces/o
c $R workspace add $R/.workspaces/d -r main
echo dirty > $B/dirty.txt
c $B status # snapshots b, so its working copy is no longer empty
O='description(substring:"feat: o1")'
A1='description(substring:"feat: a1")'
g 0 "root: rebase an orphan arm onto main" "jj -R $R rebase -s '$O' -o main"
g 0 "root: rebase -r an orphan arm" "jj -R $R rebase -r '$O' -o main"
g 2 "root: rebase an owned arm" "jj -R $R rebase -s '$A1' -o main"
g 2 "root: rebase main" "jj -R $R rebase -s main -o 'description(substring:\"feat: a1\")'"
g 2 "root: rebase wip" "jj -R $R rebase -s wip -o main"
g 2 "root: rebase without a destination" "jj -R $R rebase -s '$O'"
g 2 "root: rebase -b (branch roots are not checked)" "jj -R $R rebase -b '$O' -o main"
g 2 "root: rebase no revision" "jj -R $R rebase -o main"
g 2 "root: rebase nothing matches" "jj -R $R rebase -s 'description(substring:\"feat: nope\")' -o main"
g 2 "root: rebase orphan with --ignore-immutable" "jj -R $R rebase -s '$O' -o main --ignore-immutable"
g 2 "root: rebase orphan -A main" "jj -R $R rebase -s '$O' -A main"
g 0 "root: abandon an orphan arm" "jj -R $R abandon '$O'"
g 0 "root: abandon -r an orphan arm" "jj -R $R abandon -r '$O'"
g 2 "root: abandon an owned arm" "jj -R $R abandon '$A1'"
g 2 "root: abandon with no revision (would take the root @)" "jj -R $R abandon"
g 0 "root: bookmark create on a topic name" "jj -R $R bookmark create topic -r '$O'"
g 0 "root: bookmark set a topic name" "jj -R $R bookmark set topic -r '$O'"
g 0 "root: bookmark delete a topic name" "jj -R $R bookmark delete topic"
g 2 "root: bookmark set main" "jj -R $R bookmark set main -r '$O'"
g 2 "root: bookmark delete wip" "jj -R $R bookmark delete wip"
g 2 "root: bookmark delete by glob" "jj -R $R bookmark delete 'glob:*'"
g 2 "root: bookmark set with no name" "jj -R $R bookmark set -r '$O'"
g 2 "root: bookmark move --allow-backwards" "jj -R $R bookmark set topic -r '$O' --allow-backwards"
g 0 "root: workspace forget an idle workspace" "jj -R $R workspace forget d"
g 2 "root: workspace forget one with uncommitted edits" "jj -R $R workspace forget b"
g 2 "root: workspace forget default" "jj -R $R workspace forget default"
g 2 "root: workspace forget with no name" "jj -R $R workspace forget"
g 2 "root: describe stays blocked" "jj -R $R describe -r '$O' -m x"
g 2 "root: squash stays blocked" "jj -R $R squash -r '$O' -u"
g 2 "root: restore stays blocked" "jj -R $R restore"
g 2 "root: edit stays blocked" "jj -R $R edit '$O'"
g 2 "root: land stays blocked" "jj -R $R land"
g 2 "root: git push stays blocked" "jj -R $R git push --bookmark main"

echo "== main is immutable: jj itself refuses rewrites (the guard stays out of it)"
fresh
# an unpushed local main commit, so trunk() alone would not protect it
c $R new main -m 'feat: X'
echo x > $R/x.txt
c $R bookmark set main -r @
c $R new main
c $A rebase -s 'roots(chain(@))' -o main
im() { # description, jj args...: jj must refuse with an immutability error
  local out
  out=$(jj -R "$A" "${@:2}" 2>&1)
  if [ $? -ne 0 ] && grep -qi immutable <<< "$out"; then
    pass=$((pass + 1))
    r=ok
  else
    fail=$((fail + 1))
    r=FAIL
  fi
  printf '%-4s jj refuses  %s\n' $r "$1"
  [ "$r" = FAIL ] && printf '%s\n' "$out" | sed 's/^/       /'
}
g 0 "guard runs for squash (jj refuses it later)" "jj -R $A squash --into main -u"
im "squash into main" squash --into main -u
im "squash -r first arm commit (into main)" squash -r 'roots(chain(@))' -u
im "rebase -r main" rebase -r main -o 'description(substring:"feat: a1")'
im "describe main" describe -r main -m x
im "abandon main" abandon main
im "edit main" edit main
c $A new 'description(substring:"feat: a1")'
echo z > $A/z.txt
out=$(jj -R "$A" squash -u 2>&1) && {
  pass=$((pass + 1))
  echo "ok   squash inside my arm still works"
} || {
  fail=$((fail + 1))
  echo "FAIL squash inside my arm: $out"
}

echo "pass=$pass fail=$fail"
