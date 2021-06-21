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
            printf "${logo}Bash into a kube pod"
            printf "\t$USAGE"
            return
            ;;
        esac
    done

    if [ -z $1 ] || [ -z $2 ]; then
        printf "Invalid args\n\t$USAGE"
        return
    fi

    kubectl exec -n $1 $2 -it -- /bin/sh; 
}