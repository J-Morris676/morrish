#!/bin/sh

alias kc=kubectl
alias kubectrl=kubectl

# /bin/sh into given namespace and pod
function kubebash {
    USAGE="Usage: kubebash <namespace> <podname>"

    for i in "$@" 
    do
        case $i in
            -h|--help)
            if (locale | grep -e 'utf8' -e 'UTF-8') >/dev/null 2>&1; then logo="📖  "; else logo=""; fi
            echo "${logo}Bash into a kube pod"
            echo "\t$USAGE"
            return
            ;;
        esac
    done

    if [ -z $1 ] || [ -z $2 ]; then
        echo "Invalid args\n\t$USAGE"
        return
    fi

    kubectl exec -n $1 $2 -it -- /bin/sh; 
}