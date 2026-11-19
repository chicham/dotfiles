#!/usr/bin/env bash
# Fresh scratch repo for the megamerge tests: $1/t/{remote.git,deploy.git,repo}, main pushed,
# `chore: wip megamerge` merging the arms of workspaces a and b (one commit each).
set -e
S=$1; T=$S/t; rm -rf $T; mkdir -p $T; cd $T
git init -q --bare remote.git; git init -q --bare deploy.git
# Signing is off from the first commit: the user's signer (1Password) would prompt and stall the run.
jj --config signing.behavior=drop git init repo >/dev/null 2>&1; R=$T/repo
jj -R $R config set --repo signing.behavior drop
jj -R $R config set --repo signing.sign-all false
c() { jj -R "$1" "${@:2}" >/dev/null 2>&1; }
cd $R; echo base > base.txt; c $R commit -m init; c $R bookmark create main -r @-
c $R git remote add origin $T/remote.git; c $R git remote add deploy $T/deploy.git
jj -R $R git push --bookmark main --remote origin >/dev/null 2>&1
c $R new main -m 'chore: wip megamerge'; c $R bookmark create wip -r @
mkdir -p $R/.workspaces; c $R workspace add $R/.workspaces/a -r main; c $R workspace add $R/.workspaces/b -r main
c $R new main   # root @ off wip
echo a1 > $R/.workspaces/a/a.txt; c $R/.workspaces/a commit -m 'feat: a1'
echo b1 > $R/.workspaces/b/b.txt; c $R/.workspaces/b commit -m 'feat: b1'
# Every arm merged into wip, as the guard requires before new work.
c $R/.workspaces/a deploy --no-push
