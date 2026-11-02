#!/bin/zsh
# git link: open the web page of the current repo's origin remote.
#
#   git link        the repo
#   git link b      the current branch
#   git link m      merge/pull requests (on a branch: the ones from this branch)
#   git link p      alias of m
#   git link a      CI: GitHub Actions, GitLab pipelines
#   git link d      container registry
#   git link l      copy the repo URL to the clipboard
#   git link u      print the URL, open nothing
#   git link -h     this help
#
# GIT_LINK_NO_OPEN=1 prints the URL instead of opening it (for tests).

script=${0:A}   # in a function, $0 is the function name
usage() { sed -n '2,13s/^# \{0,1\}//p' "$script"; }

case $1 in
  -h|--help|help) usage; exit 0 ;;
  ''|b|m|p|a|d|l|u) ;;
  *) print -u2 "git link: unknown option '$1'"; usage >&2; exit 2 ;;
esac

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { print -u2 "git link: not in a git repo"; exit 1; }
remote=$(git remote get-url origin 2>/dev/null) || { print -u2 "git link: no origin remote"; exit 1; }

# Normalise every remote form to https://host/path without credentials or .git:
#   git@host:group/repo.git  ssh://git@host[:port]/group/repo.git  https://user:pw@host/group/repo.git
case $remote in
  https://*@*|http://*@*)
    url="${remote%%//*}//${remote#*@}" ;;          # drop user:token@
  https://*|http://*)
    url=$remote ;;
  ssh://*)
    url=${remote#ssh://}; url=${url#*@}
    hostport=${url%%/*}
    url="https://${hostport%%:*}/${url#*/}" ;;     # drop an ssh port
  *@*:*)
    url=${remote#*@}
    url="https://${url%%:*}/${url#*:}" ;;
  *)
    print -u2 "git link: cannot read remote '$remote'"; exit 1 ;;
esac
url=${url%.git}
url=${url%/}

host=${${url#https://}%%/*}
if [[ $host == github.com ]]; then forge=github; else forge=gitlab; fi

branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
# URL-encode the branch for query strings; a / in a branch path is fine.
enc=${branch//\//%2F}

case $1 in
  b)
    [[ -n $branch ]] || { print -u2 "git link: detached HEAD, no branch"; exit 1; }
    if [[ $forge == github ]]; then url=$url/tree/$branch; else url=$url/-/tree/$branch; fi ;;
  m|p)
    if [[ $forge == github ]]; then
      url=$url/pulls
      [[ -n $branch ]] && url="$url?q=is%3Apr+head%3A$enc"
    else
      url=$url/-/merge_requests
      [[ -n $branch ]] && url="$url?scope=all&state=all&source_branch=$enc"
    fi ;;
  a)
    if [[ $forge == github ]]; then url=$url/actions; else url=$url/-/pipelines; fi ;;
  d)
    if [[ $forge == github ]]; then url=$url/packages; else url=$url/container_registry; fi ;;
  l)
    print -n -- $url | pbcopy
    print "Git remote \"$url\" copied to clipboard"
    exit 0 ;;
  u)
    print -- $url
    exit 0 ;;
esac

if [[ -n $GIT_LINK_NO_OPEN ]]; then
  print -- $url
else
  print "Opening $url"
  open $url
fi
