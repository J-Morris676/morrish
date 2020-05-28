
function runMongoForNap {
    CREDENTIALS_FILE="$HOME/dev/cava-nap/secrets/credentials.json"

    for i in "$@"
    do
        case $i in
            -mu=*|--mongoUsername=*)
            export MONGO_INITDB_ROOT_USERNAME=${i#*=}
            ;;
            -mp=*|--mongoPassword=*)
            export MONGO_INITDB_ROOT_PASSWORD=${i#*=}
            ;;
            -c=*|--credentials=*)
            export CREDENTIALS_FILE=${i#*=}
            ;;
            -h|--help)
            printf "${logo}Runs a Mongo suitable for NAP in a Docker container, requires a username and password that the app will use for auth\n"
            printf "\t${T_BLUE}-mu,\t--mongoUsername${T_RESET}\t\t[default \"mongoUsername in $CREDENTIALS_FILE\"]\n\t\t\t\tThe username of the initial user\n"
            printf "\t${T_BLUE}-mp,\t--mongoPassword${T_RESET}\t\t[default \"mongoPassword in $CREDENTIALS_FILE\"]\n\t\t\t\tThe password of the initial user\n"
            printf "\t${T_BLUE}-c,\t--credentials${T_RESET}\t\t[default \"$CREDENTIALS_FILE\"]\n\t\t\t\tThe credentials file for NAP to grab creds from\n"
            printf "\t${T_BLUE}-h,\t--help${T_RESET}\n\t\t\t\tDisplays this help\n"
            return
            ;;
        esac
    done

    if [[ -z "$MONGO_INITDB_ROOT_USERNAME" || -z "$MONGO_INITDB_ROOT_PASSWORD" ]] && [[ -f "$CREDENTIALS_FILE" ]]; then
        MONGO_INITDB_ROOT_USERNAME=$(grep mongoUsername $CREDENTIALS_FILE | cut -d '"' -f4)
        MONGO_INITDB_ROOT_PASSWORD=$(grep mongoPassword $CREDENTIALS_FILE | cut -d '"' -f4)
    fi

    if [ -z "$MONGO_INITDB_ROOT_USERNAME" ]; then
        echo "mongoUsername in $CREDENTIALS_FILE doesn't exist or --mongoUsername wasn't provided"
        return
    fi

    if [ -z "$MONGO_INITDB_ROOT_PASSWORD" ]; then
        echo "mongoPassword in $CREDENTIALS_FILE doesn't exist or --mongoPassword wasn't provided"
        return
    fi

    echo "Starting Mongo container using username $MONGO_INITDB_ROOT_USERNAME and password $MONGO_INITDB_ROOT_PASSWORD"
    docker run \
        --name="localmongofornap" \
        --rm \
        -d \
        -e "MONGO_INITDB_ROOT_USERNAME=$MONGO_INITDB_ROOT_USERNAME" \
        -e "MONGO_INITDB_ROOT_PASSWORD=$MONGO_INITDB_ROOT_PASSWORD" \
        -v ~/dev/cava-nap/ssl/mongodb.pem:/etc/mongodb/mongodb.pem \
        -v $ROOT_DIR/src/mounted-files/init-mongo.sh:/docker-entrypoint-initdb.d/init-mongo.sh \
        -p 27017:27017 \
        mongo:4.0.9 \
        --sslMode=requireSSL --sslPEMKeyFile=/etc/mongodb/mongodb.pem
}