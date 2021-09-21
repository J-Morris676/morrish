# Lists directory sizes, largest first.
function listDirectoryAndFileSizes {
    WHERE=${1:-"."}

    find $WHERE -maxdepth 1 -type d -mindepth 1 -exec du -hs {} \; | sort -rh
}

function probeVideo { 
    if ! command -v ffprobe &> /dev/null
    then
        echo "ffprobe could not be found, install it."
        return 1
    fi

    if [ -z "$1" ]
    then
        echo "Error: Please specify a video file: probeVideo <filepath>"
        return 1
    fi

    ffprobe -v error -show_format -show_streams $1
}