#!/bin/zsh
# Tests for git-link.zsh. Run: ./test.zsh  (opens nothing)
here=${0:A:h}
tool=$here/git-link.zsh
export GIT_LINK_NO_OPEN=1
fails=0
tmp=$(mktemp -d)
trap 'rm -rf $tmp' EXIT
cd $tmp && git init -q -b feature/x-1 r && cd r && git commit -q --allow-empty -m init

check() {  # check <remote> <arg> <expected>
  git remote remove origin 2>/dev/null; git remote add origin "$1"
  got=$(zsh $tool $2 2>&1)
  if [[ $got == "$3" ]]; then print "ok    $1 $2"; else print "FAIL  $1 $2\n      want $3\n      got  $got"; fails=$((fails+1)); fi
}

check git@git.vastdata.com:vice/polaris.git ''  https://git.vastdata.com/vice/polaris
check git@git.vastdata.com:vice/polaris.git m   "https://git.vastdata.com/vice/polaris/-/merge_requests?scope=all&state=all&source_branch=feature%2Fx-1"
check git@git.vastdata.com:vice/polaris.git p   "https://git.vastdata.com/vice/polaris/-/merge_requests?scope=all&state=all&source_branch=feature%2Fx-1"
check git@git.vastdata.com:vice/polaris.git b   https://git.vastdata.com/vice/polaris/-/tree/feature/x-1
check git@git.vastdata.com:vice/polaris.git a   https://git.vastdata.com/vice/polaris/-/pipelines
check git@github.com:gzur/git-link.git      m   "https://github.com/gzur/git-link/pulls?q=is%3Apr+head%3Afeature%2Fx-1"
check git@github.com:gzur/git-link.git      a   https://github.com/gzur/git-link/actions
check git@github.com:gzur/git-link.git      b   https://github.com/gzur/git-link/tree/feature/x-1
check https://user:tok@github.com/gzur/git-link.git '' https://github.com/gzur/git-link
check https://github.com/gzur/git-link       u   https://github.com/gzur/git-link
check ssh://git@git.vastdata.com:2222/vice/polaris.git '' https://git.vastdata.com/vice/polaris

# An unknown option prints help and opens nothing.
got=$(zsh $tool --bogus 2>&1); code=$?
if [[ $code == 2 && $got == *"unknown option"* && $got != *http* ]]; then print "ok    unknown option"; else print "FAIL  unknown option ($code): $got"; fails=$((fails+1)); fi
got=$(zsh $tool --help 2>&1); code=$?
if [[ $code == 0 && $got == *"git link m"* ]]; then print "ok    --help"; else print "FAIL  --help ($code)"; fails=$((fails+1)); fi

print "$fails failure(s)"
exit $((fails > 0))
