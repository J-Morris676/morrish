#!/bin/bash

function jenkinsRunUntilGreen {
    INTERVAL_TIME=60
    sourceEnvFile

    for i in "$@"
    do
        case $i in
            -bp=*|--buildPath=*)
            export BUILD_PATH=${i#*=}
            ;;
            -it=*|--intervalTime=*)
            export INTERVAL_TIME=${i#*=}
            ;;
            -h|--help)
            printf "${logo}Keeps running a Jenkins pipeline build until it goes green\n"
            printf "\t${blue}-bp,\t--buildPath${normal}\t\t\n\t\t\t\tThe full Jenkins path to the build\n"
            printf "\t${blue}-it,\t--intervalTime${normal}\t\t[default \"$INTERVAL_TIME\"]\n\t\t\t\tTime in seconds between each pipeline check\n"
            printf "\t${blue}-h,\t--help${normal}\n\t\t\t\tDisplays this help\n"
            return
            ;;
        esac
    done

    if ! command -v jq &> /dev/null
    then
        echo "${red}Error: jq is required to use this command, install it.${normal}"
        return 1
    fi

    if [ -z "$BUILD_PATH" ]; then
        printf "${red}--buildPath wasn't provided${normal}\n"
        return 1
    fi

    printf "Configuration:\n"
    printf '\tJenkins build path:\t%s\n' $BUILD_PATH
    printf "\tJenkins user:\t\t%s\n" $JENKINS_USER
    printf "\tJenkins token:\t\t%s\n" $(mask $JENKINS_TOKEN)
    printf "\tInterval time:\t\t%s\n" $INTERVAL_TIME
    
    for (( ATTEMPTS=1 ; ; ATTEMPTS=$((ATTEMPTS+1)) ))
    do
        LAST_BUILD_URL=$(curl -s --user $JENKINS_USER:$JENKINS_TOKEN "${BUILD_PATH}/api/json" | jq --raw-output '.lastBuild.url')
        LAST_BUILD_STATE=$(curl -s --user $JENKINS_USER:$JENKINS_TOKEN "${LAST_BUILD_URL}api/json")

        printf "${blue}Checking latest build state [Check $ATTEMPTS]...\n"
        printf "\tName:\t\t$(echo $LAST_BUILD_STATE | jq --raw-output '.fullDisplayName')\n"
        printf "\tIs building:\t$(echo $LAST_BUILD_STATE | jq --raw-output '.building')\n"
        printf "\tResult:\t\t$(echo $LAST_BUILD_STATE | jq --raw-output '.result')\n"
        printf "\tStart time:\t$(echo $LAST_BUILD_STATE | jq --raw-output '.timestamp')\n${normal}"

        if [ $(echo $LAST_BUILD_STATE | jq --raw-output '.result') = "FAILURE" ]; then
            curl -s -X POST --user $JENKINS_USER:$JENKINS_TOKEN "${BUILD_PATH}buildWithParameters"
        fi

        if [ $(echo $LAST_BUILD_STATE | jq --raw-output '.result') = "SUCCESS" ]; then
            return 0     
        fi

        sleep $INTERVAL_TIME
    done
}
