mongo --ssl --sslAllowInvalidCertificates --sslPEMKeyFile /etc/mongodb/mongodb.pem overlay-engine -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD  --authenticationDatabase admin <<EOF
db.createUser({
    user: "$MONGO_INITDB_ROOT_USERNAME",
    pwd: "$MONGO_INITDB_ROOT_PASSWORD",
    roles: [
        { role: "dbOwner", db: "overlay-engine" }
    ],
    passwordDigestor:"server"
});
exit
EOF