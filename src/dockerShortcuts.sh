#!/bin/sh

# Shells into docker container
function dockerbash {
    USAGE="Usage: dockerbash <container>"

    for i in "$@"
    do
        case $i in
            -h|--help)
            printf "${logo}Bash into a running Docker container, $USAGE\n"
            return
            ;;
        esac
    done

  if [ -z $1 ]; then
      printf "${red}Invalid args\n\t$USAGE${normal}\n"
      return
  fi

  docker exec -it -u root "$1" /bin/bash;
}

function dockerRunImage {
  USAGE="Usage: dockerRunImage <image>"

  for i in "$@"
  do
      case $i in
          -h|--help)
          printf "${logo}Runs a docker image, $USAGE\n"
          return
          ;;
      esac
  done

  if [ -z $1 ]; then
      printf "${red}Invalid args\n\t$USAGE${normal}\n"
      return
  fi

  docker run -it $1 sh
}

# Runs Jenkins locally
function runjenkins {
  # TODO: Check localjenkins image exists, fallback to jenkins/jenkins
  docker run --name jenkins -d -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 localjenkins;
}

# Remove dangling Docker volumes
function clearDockerVolumes {
    for i in "$@"
    do
        case $i in
            -h|--help)
            printf "${logo}Clear out your dangling Docker volumes"
            return
            ;;
        esac
    done

  danglers="$(docker volume ls -qf dangling=true)"

  if [ -z $danglers ]; then
    printf "You don't have any dangling volumes"
    return
  fi

  docker volume rm $danglers
}