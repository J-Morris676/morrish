# Shells into docker container
function dockerbash { docker exec -it -u root "$1" /bin/bash; }

# Runs Jenkins locally
function runjenkins {
  # TODO: Check localjenkins image exists, fallback to jenkins/jenkins
  docker run --name jenkins -d -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 localjenkins; 
}