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

git config --global alias.tug pull # Because I'm 5