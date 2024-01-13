#!/bin/bash
set -e

readonly FLATCAR_TMP_PATH=/tmp/flatcar_production_vagrant.box
readonly FLATCAR_BOX_EXISTS=$(vagrant box list | grep flatcar)

if [ -z "$FLATCAR_BOX_EXISTS" ]
then
    wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_vagrant.box -O $FLATCAR_TMP_PATH
    vagrant box add flatcar $FLATCAR_TMP_PATH
fi

vagrant up --provider virtualbox
