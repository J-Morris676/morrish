# Lists directory sizes, largest first.
function listDirectoryAndFileSizes {
    WHERE=${1:-"."}

    find $WHERE -maxdepth 1 -type d -mindepth 1 -exec du -hs {} \; | sort -rh
}