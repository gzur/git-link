function gl
    git rev-parse --is-inside-work-tree >/dev/null
    if test "$status" -gt 0
        return $status
    end
    set remote (git remote get-url --all origin)
    if string match -q -- "https*" $remote
        echo "Opening url "$remote
        open $remote
        return 0
    end
    set git_link (echo $remote | sed 's/\:/\//g' | sed 's/git@/https\:\/\//g' |  sed 's/\.git$//g')
    set arg $argv[1]
    switch (echo $arg) # gitlab subpage shenanigans
        case p pi pip pipe pipeline pipelines
            set git_link $git_link/pipelines
        case m mr mrs merge
            set git_link $git_link/merge_requests
        case d r docker reg registry
            set git_link $git_link/container_registry
        case u l url link
            echo $git_link | pbcopy # not very portable
            echo "Git remote \"$git_link\" copied to clipboard"
            return 0
        case a ar argo
            test -e values.yaml; or echo "Not positioned the root of a CKE fork" && return 1
            set argo_link https://(cat values.yaml | grep \&fqdn | awk '{print $3}')/admin/argocd/
            test "$argo_link"
            echo "Opening ArgoCD at $argo_link"
            open $argo_link
            return 0

        case '*'
            echo $git_link
    end
    echo "Opening gitlab url "$git_link
    open $git_link # not very portable - or maybe it is. I have no idea.
end
