# Named env commands for deploying NAP to Kube because I'm lazy
# Note: These are being implemented into NAP :-)

NAP_HOME="$HOME/dev/nap"
function deployNap() {
  local namespace=morris
  local username=admin
  local password=password
  local napImage='897562121255.dkr.ecr.eu-west-2.amazonaws.com/ad-tech-nap:nap-master'
  local nodeEnv='integration-test'
  local cluster='ad-tech-nap-testing'
  local role='arn:aws:iam::897562121255:role/kubernetes-admin'

  for i in "$@" 
  do
    case $i in
        -n=*|--namespace=*)
        local namespace=${i#*=}
        ;;
        -u=*|--username=*)
        local username=${i#*=}
        ;;
        -p=*|--password=*)
        local password=${i#*=}
        ;;
        -i=*|--napImage=*)
        local napImage=${i#*=}
        ;;
        -ne=*|--nodeEnv=*)
        local nodeEnv=${i#*=}
        ;;
        -c=*|--cluster=*)
        local cluster=${i#*=}
        ;;
        -r=*|--role=*)
        local role=${i#*=}
        ;;
    esac
  done

  $NAP_HOME/deploy/deploy.sh $namespace $username $password $napImage $nodeEnv $cluster $role
}

function runIntegrationTests() {
  local namespace=morris
  local intTestImage='897562121255.dkr.ecr.eu-west-2.amazonaws.com/ad-tech-nap:nap-dev-master'
  for i in "$@" 
  do
    case $i in
        -n=*|--namespace=*)
        local namespace=${i#*=}
        ;;
        -i=*|--intTestImage=*)
        local intTestImage=${i#*=}
        ;;
    esac
  done
  
  $NAP_HOME/deploy/run-int-k8s.sh $namespace $intTestImage
}

function teardownNapDeployment() {
  local namespace=morris
  local cluster='ad-tech-nap-testing'
  for i in "$@" 
  do
    case $i in
        -n=*|--namespace=*)
        echo ${i#*=}
        local namespace=${i#*=}
        ;;
        -c=*|--cluster=*)
        local cluster=${i#*=}
        ;;
    esac
  done

  $NAP_HOME/deploy/teardown.sh $namespace $cluster
}