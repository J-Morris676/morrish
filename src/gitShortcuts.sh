#!/bin/sh

function commit { git commit -m "$1"; }
function commitall { git commit -am "$1"; }
function graph { git log --graph --oneline --all }

git config --global alias.tug pull # Because I'm 5