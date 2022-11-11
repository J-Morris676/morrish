
function writeInitMongo {
tee /tmp/init-mongo.sh > /dev/null << END
mongo --ssl --sslAllowInvalidCertificates --sslPEMKeyFile /etc/mongodb/mongodb.pem avap_avap -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD  --authenticationDatabase admin <<EOF
db.createUser({
    user: "$MONGO_INITDB_ROOT_USERNAME",
    pwd: "$MONGO_INITDB_ROOT_PASSWORD",
    roles: [
        { role: "dbOwner", db: "overlay-engine" },
        { role: "dbOwner", db: "avap_avap" },
        { role: "dbOwner", db: "overlay-engine-integration-test-local"},
        { role: "root", db: "admin" }
    ],
    passwordDigestor:"server"
});
exit
EOF
END
}

function runMongoForNap {
    NAP_PATH="$HOME/dev/cava-nap"
    CREDENTIALS_RELATIVE_PATH="secrets/credentials.json"
    CONTAINER_NAME="localmongofornap"
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
            printf "\t${blue}-mu,\t--mongoUsername${normal}\t\t[default \"mongoUsername in cava-nap secrets/credentials.json\"]\n\t\t\t\tThe username of the initial user\n"
            printf "\t${blue}-mp,\t--mongoPassword${normal}\t\t[default \"mongoPassword in cava-nap secrets/credentials.json\"]\n\t\t\t\tThe password of the initial user\n"
            printf "\t${blue}-np,\t--nap-path${normal}\t\t[default \"$NAP_PATH\"]\n\t\t\t\tThe path of cava-nap on your local machine\n"
            printf "\t${blue}-f,\t--force${normal}\t\t[default \"$FORCE\"]\n\t\t\t\tWhether to replace an existing container if it exists\n"
            printf "\t${blue}-h,\t--help${normal}\n\t\t\t\tDisplays this help\n"
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
        printf "${red}mongoUsername in $CREDENTIALS_FILE doesn't exist or --mongoUsername wasn't provided${normal}\n"
        return 1
    fi

    if [ -z "$MONGO_INITDB_ROOT_PASSWORD" ]; then
        printf "${red}mongoPassword in $CREDENTIALS_FILE doesn't exist or --mongoPassword wasn't provided${normal}\n"
        return 1
    fi

    if docker ps -a | grep $CONTAINER_NAME > /dev/null; then
        if [ "$FORCE" = 'false' ]; then
            printf "${red}A container already exists, you can \"docker restart $CONTAINER_NAME\" or use --force to replace existing container${normal}\n"
            return 1
        fi
        
        docker rm $CONTAINER_NAME --force > /dev/null
    fi

    printf "Starting Mongo container...\n"
    printf "\tContainer name:\t\t$CONTAINER_NAME\n"
    printf "\tVolume name:\t\tmongo_data\n"
    printf "\tMongo version:\t\t4.0.9\n"
    printf "\tMongo username:\t\t$MONGO_INITDB_ROOT_USERNAME\n"
    printf "\tMongo password:\t\t$MONGO_INITDB_ROOT_PASSWORD\n"
    printf "\tMongo SSL certificate:\t$NAP_PATH/ssl/mongodb.pem\n"

    writeInitMongo

    CONTAINER_ID=$(docker run \
        --name=$CONTAINER_NAME \
        -d \
        -e "MONGO_INITDB_ROOT_USERNAME=$MONGO_INITDB_ROOT_USERNAME" \
        -e "MONGO_INITDB_ROOT_PASSWORD=$MONGO_INITDB_ROOT_PASSWORD" \
        -v $NAP_PATH/ssl/mongodb.pem:/etc/mongodb/mongodb.pem \
        -v /tmp/init-mongoa.sh:/docker-entrypoint-initdb.d/init-mongo.sh \
        -v mongo_data:/data/db \
        -p 27017:27017 \
        mongo:4.0.9 \
        --sslMode=requireSSL --sslPEMKeyFile=/etc/mongodb/mongodb.pem) &> /tmp/localnapmongologs
    
    if [ $? -ne 0 ]; then
        printf "${red}Failed to start container. Docker output:\n$(cat /tmp/localnapmongologs | sed 's/^/\t/')${normal}"
        return 1
    fi

    printf "${green}Container started successfully. Container ID: $CONTAINER_ID${normal}\n"
}