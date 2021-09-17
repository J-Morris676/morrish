mongo --ssl --sslAllowInvalidCertificates --sslPEMKeyFile /etc/mongodb/mongodb.pem avap_avap -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD  --authenticationDatabase admin <<EOF
db.createUser({
    user: "$MONGO_INITDB_ROOT_USERNAME",
    pwd: "$MONGO_INITDB_ROOT_PASSWORD",
    roles: [
        { role: "dbOwner", db: "overlay-engine" },
        { role: "dbOwner", db: "avap_avap" },
        { role: "dbOwner", db: "overlay-engine-integration-test-local"}
    ],
    passwordDigestor:"server"
});
exit
EOF