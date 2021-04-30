#!/bin/sh

git rev-parse --is-inside-work-tree >/dev/null
if [[ $? > 0 ]]
then
    exit $?
fi
git_url=$(git remote get-url --all origin | sed -r 's/git@([a-z]+\.[a-z]+)\:(.*).git/https\:\/\/\1\/\2/g')
#gitlab_url=$(git remote get-url --all origin | sed 's/git@gitlab.com\:/https\:\/\/gitlab.com\//g' | sed 's/\.git$//g')
case "$1" in
    p|pi|pip|pipe|pipeline|pipelines)
        git_url=$git_url/pipelines
        ;;
    m|mr|mrs|merge)
        git_url=$git_url/merge_requests
        ;;
    r|docker|reg|registry)
        git_url=$git_url/container_registry
        ;;
    *)
esac
echo "Opening git url "$git_url
open $git_url
