#!/bin/sh

ROOT_DIR=$( cd "$(dirname "$0")" ; pwd -P )

source $ROOT_DIR/src/napDeployment.sh
source $ROOT_DIR/src/dockerShortcuts.sh
source $ROOT_DIR/src/gitShortcuts.sh
source $ROOT_DIR/src/kubeShortcuts.sh