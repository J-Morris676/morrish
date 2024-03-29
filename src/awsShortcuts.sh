#!/bin/sh

function createS3Bucket {
    USAGE="Usage: createS3Bucket <bucketName> [--localstack]"
    LOCALSTACK=false

    for i in "$@"
    do
        case $i in
            -ls|--localstack)
            LOCALSTACK=true
            ;;
            -h|--help)
            printf "${logo}Create an S3 bucket optionally specifying whether to create one in localstack, ${USAGE}\n"
            printf "${blue}\t-ls,\t--localstack\t\t[default \"false\"]\n\t\t\t\t${normal}Whether to point at localstack url (http://localhost:4566)\n"
            return
            ;;
        esac
    done

    if [ -z $1 ]; then
        printf "Invalid args\n\t$USAGE"
        return
    fi

    if [ "$LOCALSTACK" = true ]; then
        aws --endpoint-url=http://localhost:4566 s3api create-bucket --bucket $1
    else
        aws s3api create-bucket --bucket $1
    fi
}

function listS3Objects {
    USAGE="Usage: listS3Objects <bucketName> [--localstack]"
    LOCALSTACK=false

    for i in "$@"
    do
        case $i in
            -ls|--localstack)
            LOCALSTACK=true
            ;;
            -h|--help)
            printf "${logo}List items in an bucket optionally specifying whether to look at localstack, ${USAGE}\n"
            printf "${blue}\t-ls,\t--localstack\t\t[default \"false\"]\n\t\t\t\t${normal}Whether to point at localstack url (http://localhost:4566)\n"
            return
            ;;
        esac
    done

    if [ -z $1 ]; then
        printf "Invalid args\n\t$USAGE"
        return
    fi

    if [ "$LOCALSTACK" = true ]; then
        aws --endpoint-url=http://localhost:4566 s3api list-objects-v2 --bucket $1
    else
        aws s3api list-objects-v2 --bucket $1
    fi
}

function listS3Buckets {
    USAGE="Usage: listS3Buckets [--localstack]"
    LOCALSTACK=false

    for i in "$@"
    do
        case $i in
            -ls|--localstack)
            LOCALSTACK=true
            ;;
            -h|--help)
            printf "${logo}List items in an bucket optionally specifying whether to look at localstack, ${USAGE}\n"
            printf "${blue}\t-ls,\t--localstack\t\t[default \"false\"]\n\t\t\t\t${normal}Whether to point at localstack url (http://localhost:4566)\n"
            return
            ;;
        esac
    done

    if [ "$LOCALSTACK" = true ]; then
        aws --endpoint-url=http://localhost:4566 s3api list-buckets
    else
        aws s3api list-buckets
    fi
}