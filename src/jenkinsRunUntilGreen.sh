#!/bin/bash

function jenkinsRunUntilGreen {
    INTERVAL_TIME=60
    sourceEnvFile

    for i in "$@"
    do
        case $i in
            -bp=*|--buildUrl=*)
            export BUILD_URL=${i#*=}
            ;;
            -it=*|--intervalTime=*)
            export INTERVAL_TIME=${i#*=}
            ;;
            -ju=*|--jenkinsUser=*)
            export JENKINS_USER=${i#*=}
            ;;
            -jt=*|--jenkinsToken=*)
            export JENKINS_TOKEN=${i#*=}
            ;;
            -h|--help)
            printf "${logo}Keeps running a Jenkins pipeline build until it goes green\n"
            printf "\t${blue}-bp,\t--buildUrl${normal}\t\t\n\t\t\t\tThe full Jenkins path to the build\n"
            printf "\t${blue}-it,\t--intervalTime${normal}\t\t[default \"$INTERVAL_TIME\"]\n\t\t\t\tTime in seconds between each pipeline check\n"
            printf "\t${blue}-ju,\t--jenkinsUser${normal}\t\t\n\t\t\t\tThe Jenkins username to use for auth\n"
            printf "\t${blue}-jt,\t--jenkinsToken${normal}\t\t\n\t\t\t\tThe Jenkins API token to use for auth, can be generated in the user configuration settings\n"
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

    if [ -z "$BUILD_URL" ]; then
        printf "${red}--buildUrl wasn't provided, please provide the full build url to the Jenkins job${normal}\n"
        return 1
    fi

    if [ -z "$JENKINS_USER" ]; then
        printf "${red}--jenkinsUser wasn't provided or isn't set as envvar JENKINS_USER${normal}\n"
        return 1
    fi

    if [ -z "$JENKINS_TOKEN" ]; then
        printf "${red}--jenkinsToken wasn't provided or isn't set as envvar JENKINS_USER${normal}\n"
        return 1
    fi

    printf "Configuration:\n"
    printf '\tJenkins build path:\t%s\n' $BUILD_URL
    printf "\tJenkins user:\t\t%s\n" $JENKINS_USER
    printf "\tJenkins token:\t\t%s\n" $(mask $JENKINS_TOKEN)
    printf "\tInterval time:\t\t%s\n" $INTERVAL_TIME
    
    for (( ATTEMPTS=1 ; ; ATTEMPTS=$((ATTEMPTS+1)) ))
    do
        BUILD_JSON_RESPONSE_CODE=$(curl \
            --write-out '%{http_code}' \
            --silent \
            --user $JENKINS_USER:$JENKINS_TOKEN \
            --output /tmp/jenkinsresponse \
            "${BUILD_URL}/api/json"
        )

        if [[ "$BUILD_JSON_RESPONSE_CODE" -ne 200 ]] ; then
            printf "${red}Failed fetching Jenkins build json:\n%s${normal}" "$(< /tmp/jenkinsresponse)"
            return 1
        fi

        LAST_BUILD_URL=$(cat /tmp/jenkinsresponse | jq --raw-output '.lastBuild.url')

        LAST_BUILD_RESPONSE_CODE=$(curl \
            --write-out '%{http_code}' \
            --silent \
            --user $JENKINS_USER:$JENKINS_TOKEN \
            --output /tmp/jenkinsresponse \
            "${LAST_BUILD_URL}api/json"
        )

        if [[ "$LAST_BUILD_RESPONSE_CODE" -ne 200 ]] ; then
            printf "${red}Failed fetching latest Jenkins build json:\n%s${normal}" "$(< /tmp/jenkinsresponse)"
            return 1
        fi

        LAST_BUILD_STATE=$(cat /tmp/jenkinsresponse)

        printf "${blue}Checking latest build state [Check $ATTEMPTS]...\n"
        printf "\tName:\t\t$(printf '%s' $LAST_BUILD_STATE | jq --raw-output '.fullDisplayName')\n"
        printf "\tIs building:\t$(printf '%s' $LAST_BUILD_STATE | jq --raw-output '.building')\n"
        printf "\tResult:\t\t$(printf '%s' $LAST_BUILD_STATE | jq --raw-output '.result')\n"
        printf "\tStart time:\t$(printf '%s' $LAST_BUILD_STATE | jq --raw-output '.timestamp')\n${normal}"

        if [ $(printf '%s' $LAST_BUILD_STATE | jq --raw-output '.result') = "FAILURE" ]; then
            curl -s -X POST --user $JENKINS_USER:$JENKINS_TOKEN "${BUILD_URL}buildWithParameters"
        fi

        if [ $(printf '%s' $LAST_BUILD_STATE | jq --raw-output '.result') = "SUCCESS" ]; then
            return 0     
        fi

        sleep $INTERVAL_TIME
    done
}
