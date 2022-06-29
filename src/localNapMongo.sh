
function runMongoForNap {
    NAP_PATH="$HOME/dev/cava-nap"
    CREDENTIALS_RELATIVE_PATH="secrets/credentials.json"
    FORCE=false

    for i in "$@"
    do
        case $i in
            -mu=*|--mongoUsername=*)
            export MONGO_INITDB_ROOT_USERNAME=${i#*=}
            ;;
            -mp=*|--mongoPassword=*)
            export MONGO_INITDB_ROOT_PASSWORD=${i#*=}
            ;;
            -np=*|--nap-path=*)
            export NAP_PATH=${i#*=}
            ;;
            -f|--force)
            FORCE=true
            ;;
            -h|--help)
            printf "${logo}Runs a Mongo suitable for NAP in a Docker container, requires a username and password that the app will use for auth\n"
            printf "\t${T_BLUE}-mu,\t--mongoUsername${T_RESET}\t\t[default \"mongoUsername in cava-nap secrets/credentials.json\"]\n\t\t\t\tThe username of the initial user\n"
            printf "\t${T_BLUE}-mp,\t--mongoPassword${T_RESET}\t\t[default \"mongoPassword in cava-nap secrets/credentials.json\"]\n\t\t\t\tThe password of the initial user\n"
            printf "\t${T_BLUE}-np,\t--nap-path${T_RESET}\t\t[default \"$NAP_PATH\"]\n\t\t\t\tThe path of cava-nap on your local machine\n"
            printf "\t${T_BLUE}-f,\t--force${T_RESET}\t\t[default \"$FORCE\"]\n\t\t\t\tWhether to replace an existing container if it exists\n"
            printf "\t${T_BLUE}-h,\t--help${T_RESET}\n\t\t\t\tDisplays this help\n"
            return
            ;;
        esac
    done

    CREDENTIALS_FILE="$NAP_PATH/$CREDENTIALS_RELATIVE_PATH"

    if [[ -z "$MONGO_INITDB_ROOT_USERNAME" || -z "$MONGO_INITDB_ROOT_PASSWORD" ]] && [[ -f "$CREDENTIALS_FILE" ]]; then
        MONGO_INITDB_ROOT_USERNAME=$(grep mongoUsername $CREDENTIALS_FILE | cut -d '"' -f4)
        MONGO_INITDB_ROOT_PASSWORD=$(grep mongoPassword $CREDENTIALS_FILE | cut -d '"' -f4)
    fi

    if [ -z "$MONGO_INITDB_ROOT_USERNAME" ]; then
        printf "mongoUsername in $CREDENTIALS_FILE doesn't exist or --mongoUsername wasn't provided"
        return
    fi

    if [ -z "$MONGO_INITDB_ROOT_PASSWORD" ]; then
        printf "mongoPassword in $CREDENTIALS_FILE doesn't exist or --mongoPassword wasn't provided"
        return
    fi

    if docker ps -a | grep 'localmongofornap' > /dev/null; then
        if [ "$FORCE" = 'false' ]; then
            printf "A container already exists, you can \"docker restart localmongofornap\" or use --force to replace existing container"
            return
        fi
        
        docker rm localmongofornap --force > /dev/null
    fi

    printf "Starting Mongo container:\n"
    printf "\tContainer name:\t\tlocalmongofornap\n"
    printf "\tVolume name:\t\tmongo_data\n"
    printf "\tMongo version:\t\t4.0.9\n"
    printf "\tMongo username:\t\t$MONGO_INITDB_ROOT_USERNAME\n"
    printf "\tMongo password:\t\t$MONGO_INITDB_ROOT_PASSWORD\n"
    printf "\tMongo SSL certificate:\t$NAP_PATH/ssl/mongodb.pem\n"
    docker run \
        --name="localmongofornap" \
        -d \
        -e "MONGO_INITDB_ROOT_USERNAME=$MONGO_INITDB_ROOT_USERNAME" \
        -e "MONGO_INITDB_ROOT_PASSWORD=$MONGO_INITDB_ROOT_PASSWORD" \
        -v $NAP_PATH/ssl/mongodb.pem:/etc/mongodb/mongodb.pem \
        -v $ROOT_DIR/src/mounted-files/init-mongo.sh:/docker-entrypoint-initdb.d/init-mongo.sh \
        -v mongo_data:/data/db \
        -p 27017:27017 \
        mongo:4.0.9 \
        --sslMode=requireSSL --sslPEMKeyFile=/etc/mongodb/mongodb.pem > /dev/null
}