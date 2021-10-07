#!/bin/sh

function commit { git commit -m "$1"; }
function commitall { git commit -am "$1"; }
function graph { git log --graph --oneline --all }
function movetag { 
    if [ -z "$1" ]
    then
        echo "Error: Please specify a tag name: movetag <tagName>"
        return 1
    fi

    TAG_NAME=$1
    
    git tag -d $TAG_NAME # Delete local tag
    git push origin :refs/tags/$TAG_NAME # Delete origin tag 
    git tag $TAG_NAME # Tag local
    git push origin $TAG_NAME # Push tag to origin
}

function squashAndRebase { 
    BASE_BRANCH="master"

    for i in "$@"
    do
        case $i in
            -bb=*|--base-branch=*)
            export BASE_BRANCH=${i#*=}
            ;;
            -cm=*|--commit-message=*)
            export COMMIT_MESSAGE=${i#*=}
            ;;
            -h|--help)
            printf "${logo}Resets index to provided base-branch, squashing all commits into a single one provided with commit-message\n"
            printf "\t${T_BLUE}-bb,\t--base-branch${T_RESET}\t\t[default \"master\"]\n\t\t\t\t\tThe base branch to reset index to\n"
            printf "\t${T_BLUE}-cm,\t--commit-message${T_RESET}\tThe commit message of the newly squashed commit\n"
            return
            ;;
        esac
    done

    if [ -z "$COMMIT_MESSAGE" ]
    then
        echo "Error: Please specify a commit message: squashAndRebase --commit-message=\"My changes\""
        return 1
    fi

    CURRENT_BRANCH=$(git branch --show-current)
    echo "Rebasing '$CURRENT_BRANCH' against '$BASE_BRANCH' and squashing commits with message '$COMMIT_MESSAGE'"

    git reset $(git merge-base $BASE_BRANCH $CURRENT_BRANCH)
    git add -A
    git commit -m $COMMIT_MESSAGE
}

git config --global alias.tug pull # Because I'm 5