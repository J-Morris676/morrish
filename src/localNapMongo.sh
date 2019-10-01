
function runMongoForNap {
    MONGO_INITDB_ROOT_USERNAME=$(grep mongoUsername ~/dev/nap/credentials.json | cut -d '"' -f4)
    MONGO_INITDB_ROOT_PASSWORD=$(grep mongoPassword ~/dev/nap/credentials.json | cut -d '"' -f4)

    for i in "$@" 
    do
        case $i in
            -mu=*|--mongoUsername=*)
            export MONGO_INITDB_ROOT_USERNAME=${i#*=}
            ;;
            -mp=*|--mongoPassword=*)
            export MONGO_INITDB_ROOT_PASSWORD=${i#*=}
            ;;
            -h|--help)
            if (locale | grep -e 'utf8' -e 'UTF-8') >/dev/null 2>&1; then logo="📖  "; else logo=""; fi
            printf "${logo}Runs a Mongo suitable for NAP in a Docker container, requires a username and password that the app will use for auth\n"
            printf "\t${T_BLUE}-mu,\t--mongoUsername${T_RESET}\t\t[default \"mongoUsername in ~/dev/nap/credentials.json\"]\n\t\t\t\tThe username of the initial user\n"
            printf "\t${T_BLUE}-mp,\t--mongoPassword${T_RESET}\t\t[default \"mongoPassword in ~/dev/nap/credentials.json\"]\n\t\t\t\tThe password of the initial user\n"
            printf "\t${T_BLUE}-h,\t--help${T_RESET}\n\t\t\t\tDisplays this help\n"
            exit 0
            ;;
        esac
    done

    if [ -z $MONGO_INITDB_ROOT_USERNAME ]; then
        echo "mongoUsername in ~/dev/nap/credentials.json doesn't exist or --mongoUsername wasn't provided"
        return
    fi

    if [ -z $MONGO_INITDB_ROOT_PASSWORD]; then
        echo "mongoPassword in ~/dev/nap/credentials.json doesn't exist or --mongoPassword wasn't provided"
        return
    fi

    docker run \
        --name="localmongofornap" \
        -d \
        -e "MONGO_INITDB_ROOT_USERNAME=$MONGO_INITDB_ROOT_USERNAME" \
        -e "MONGO_INITDB_ROOT_PASSWORD=$MONGO_INITDB_ROOT_PASSWORD" \
        -v ~/dev/nap/ssl/mongodb.pem:/etc/mongodb/mongodb.pem \
        -v $ROOT_DIR/mounted-files/init-mongo.sh:/docker-entrypoint-initdb.d/init-mongo.sh \
        -p 27017:27017 \
        mongo:4.0.9 \
        --sslMode=requireSSL --sslPEMKeyFile=/etc/mongodb/mongodb.pem 
}