#!/bin/zsh
git rev-parse --is-inside-work-tree >/dev/null
if [[  $? -gt 0 ]]; then
    exit 1;
fi
local remote=$(git remote get-url --all origin)
if [[ "https" =~ ${remote} ]] then

    echo "Found https remote, opening repo at $remote";
    open $remote;
    exit 0;
fi
local git_link=$(echo $remote | sed 's/\:/\//g' | sed 's/git@/https\:\/\//g' |  sed 's/\.git$//g')    
case $1 in # gitlab subpage shenanigans
    a)
        git_link=$git_link/actions;
        ;;
    p)
        git_link=$git_link/pulls
        ;;
    d)
        git_link=$git_link/container_registry
        ;;
    l)
        echo $git_link | pbcopy # not very portable
        echo "Git remote \"$git_link\" copied to clipboard"
        return 0
        ;;
    '*')
        echo $git_link
        ;;
esac
echo "Opening repo at "$git_link
open $git_link # not very portable - or maybe it is. I have no idea.



