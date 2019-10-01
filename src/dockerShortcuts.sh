#!/bin/sh

# Shells into docker container
function dockerbash {
    USAGE="Usage: dockerbash <container>"

    for i in "$@" 
    do
        case $i in
            -h|--help)
            if (locale | grep -e 'utf8' -e 'UTF-8') >/dev/null 2>&1; then logo="📖  "; else logo=""; fi
            echo "${logo}Bash into a Docker container"
            echo "\t$USAGE"
            return
            ;;
        esac
    done

  if [ -z $1 ]; then
      echo "Invalid args\n\t$USAGE"
      return
  fi

  docker exec -it -u root "$1" /bin/bash; 
}

# Runs Jenkins locally
function runjenkins {
  # TODO: Check localjenkins image exists, fallback to jenkins/jenkins
  docker run --name jenkins -d -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 localjenkins; 
}

# Remove dangling Docker volumes
function clearDockerVolumes { docker volume rm "$(docker volume ls -qf dangling=true)" }