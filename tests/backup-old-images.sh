#!/bin/bash
#
# Since: April 2023
# Author: gvenzl
# Name: backup-old-images.sh
# Description: Backup current images on Docker Hub
#
# Copyright 2023 Gerald Venzl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Exit on errors
# Great explanation on https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

source ./functions.sh

# Download images
echo "Backup latest"
podman pull docker.io/gvenzl/oracle-free:latest-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:latest-$(getArch) docker.io/gvenzl/oracle-free:latest-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:latest-$(getArch)

echo "Backup latest-faststart"
podman pull docker.io/gvenzl/oracle-free:latest-faststart-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:latest-faststart-$(getArch) docker.io/gvenzl/oracle-free:latest-faststart-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:latest-faststart-$(getArch)




# Backup images
echo "Backup 23.5-full-faststart"
podman pull docker.io/gvenzl/oracle-free:23.5-full-faststart-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23.5-full-faststart-$(getArch) docker.io/gvenzl/oracle-free:23.5-full-faststart-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23.5-full-faststart-$(getArch)

echo "Backup 23.5-full"
podman pull docker.io/gvenzl/oracle-free:23.5-full-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23.5-full-$(getArch) docker.io/gvenzl/oracle-free:23.5-full-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23.5-full-$(getArch)


# Backup images
#echo "Backup 23.4-full-faststart"
#podman pull docker.io/gvenzl/oracle-free:23.4-full-faststart
#podman tag  docker.io/gvenzl/oracle-free:23.4-full-faststart docker.io/gvenzl/oracle-free:23.4-full-faststart-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.4-full-faststart

#echo "Backup 23.4-full"
#podman pull docker.io/gvenzl/oracle-free:23.4-full
#podman tag  docker.io/gvenzl/oracle-free:23.4-full docker.io/gvenzl/oracle-free:23.4-full-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.4-full


#echo "Backup 23.3-full-faststart"
#podman pull docker.io/gvenzl/oracle-free:23.3-full-faststart
#podman tag  docker.io/gvenzl/oracle-free:23.3-full-faststart docker.io/gvenzl/oracle-free:23.3-full-faststart-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.3-full-faststart

#echo "Backup 23.3-full"
#podman pull docker.io/gvenzl/oracle-free:23.3-full
#podman tag  docker.io/gvenzl/oracle-free:23.3-full docker.io/gvenzl/oracle-free:23.3-full-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.3-full


#echo "Backup 23.2-full-faststart"
#podman pull docker.io/gvenzl/oracle-free:23.2-full-faststart
#podman tag  docker.io/gvenzl/oracle-free:23.2-full-faststart docker.io/gvenzl/oracle-free:23.2-full-faststart-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.2-full-faststart

#echo "Backup 23.2-full"
#podman pull docker.io/gvenzl/oracle-free:23.2-full
#podman tag  docker.io/gvenzl/oracle-free:23.2-full docker.io/gvenzl/oracle-free:23.2-full-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.2-full





echo "Backup 23-full-faststart"
podman pull docker.io/gvenzl/oracle-free:23-full-faststart-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23-full-faststart-$(getArch) docker.io/gvenzl/oracle-free:23-full-faststart-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23-full-faststart-$(getArch)

echo "Backup 23-full"
podman pull docker.io/gvenzl/oracle-free:23-full-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23-full-$(getArch) docker.io/gvenzl/oracle-free:23-full-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23-full-$(getArch)

echo "Backup full-faststart"
podman pull docker.io/gvenzl/oracle-free:full-faststart-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:full-faststart-$(getArch) docker.io/gvenzl/oracle-free:full-faststart-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:full-faststart-$(getArch)

echo "Backup full"
podman pull docker.io/gvenzl/oracle-free:full-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:full-$(getArch) docker.io/gvenzl/oracle-free:full-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:full-$(getArch)




echo "Backup 23.5-faststart"
podman pull docker.io/gvenzl/oracle-free:23.5-faststart-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23.5-faststart-$(getArch) docker.io/gvenzl/oracle-free:23.5-faststart-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23.5-faststart-$(getArch)

echo "Backup 23.5"
podman pull docker.io/gvenzl/oracle-free:23.5-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23.5-$(getArch) docker.io/gvenzl/oracle-free:23.5-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23.5-$(getArch)


echo "Backup 23.4-faststart"
#podman pull docker.io/gvenzl/oracle-free:23.4-faststart
#podman tag  docker.io/gvenzl/oracle-free:23.4-faststart docker.io/gvenzl/oracle-free:23.4-faststart-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.4-faststart

#echo "Backup 23.4"
#podman pull docker.io/gvenzl/oracle-free:23.4
#podman tag  docker.io/gvenzl/oracle-free:23.4 docker.io/gvenzl/oracle-free:23.4-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.4


#echo "Backup 23.3-faststart"
#podman pull docker.io/gvenzl/oracle-free:23.3-faststart
#podman tag  docker.io/gvenzl/oracle-free:23.3-faststart docker.io/gvenzl/oracle-free:23.3-faststart-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.3-faststart

#echo "Backup 23.3"
#podman pull docker.io/gvenzl/oracle-free:23.3
#podman tag  docker.io/gvenzl/oracle-free:23.3 docker.io/gvenzl/oracle-free:23.3-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.3


#echo "Backup 23.2-faststart"
#podman pull docker.io/gvenzl/oracle-free:23.2-faststart
#podman tag  docker.io/gvenzl/oracle-free:23.2-faststart docker.io/gvenzl/oracle-free:23.2-faststart-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.2-faststart

#echo "Backup 23.2"
#podman pull docker.io/gvenzl/oracle-free:23.2
#podman tag  docker.io/gvenzl/oracle-free:23.2 docker.io/gvenzl/oracle-free:23.2-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.2






echo "Backup 23-faststart"
podman pull docker.io/gvenzl/oracle-free:23-faststart-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23-faststart-$(getArch) docker.io/gvenzl/oracle-free:23-faststart-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23-faststart-$(getArch)

echo "Backup 23"
podman pull docker.io/gvenzl/oracle-free:23-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23-$(getArch) docker.io/gvenzl/oracle-free:23-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23-$(getArch)






echo "Backup 23.5-slim-faststart"
podman pull docker.io/gvenzl/oracle-free:23.5-slim-faststart-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23.5-slim-faststart-$(getArch) docker.io/gvenzl/oracle-free:23.5-slim-faststart-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23.5-slim-faststart-$(getArch)

echo "Backup 23.5-slim"
podman pull docker.io/gvenzl/oracle-free:23.5-slim-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23.5-slim-$(getArch) docker.io/gvenzl/oracle-free:23.5-slim-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23.5-slim-$(getArch)


#echo "Backup 23.4-slim-faststart"
#podman pull docker.io/gvenzl/oracle-free:23.4-slim-faststart
#podman tag  docker.io/gvenzl/oracle-free:23.4-slim-faststart docker.io/gvenzl/oracle-free:23.4-slim-faststart-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.4-slim-faststart

#echo "Backup 23.4-slim"
#podman pull docker.io/gvenzl/oracle-free:23.4-slim
#podman tag  docker.io/gvenzl/oracle-free:23.4-slim docker.io/gvenzl/oracle-free:23.4-slim-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.4-slim


#echo "Backup 23.3-slim-faststart"
#podman pull docker.io/gvenzl/oracle-free:23.3-slim-faststart
#podman tag  docker.io/gvenzl/oracle-free:23.3-slim-faststart docker.io/gvenzl/oracle-free:23.3-slim-faststart-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.3-slim-faststart

#echo "Backup 23.3-slim"
#podman pull docker.io/gvenzl/oracle-free:23.3-slim
#podman tag  docker.io/gvenzl/oracle-free:23.3-slim docker.io/gvenzl/oracle-free:23.3-slim-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.3-slim


#echo "Backup 23.2-slim-faststart"
#podman pull docker.io/gvenzl/oracle-free:23.2-slim-faststart
#podman tag  docker.io/gvenzl/oracle-free:23.2-slim-faststart docker.io/gvenzl/oracle-free:23.2-slim-faststart-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.2-slim-faststart

#echo "Backup 23.2-slim"
#podman pull docker.io/gvenzl/oracle-free:23.2-slim
#podman tag  docker.io/gvenzl/oracle-free:23.2-slim docker.io/gvenzl/oracle-free:23.2-slim-backup
#podman rmi  docker.io/gvenzl/oracle-free:23.2-slim






echo "Backup 23-slim-faststart"
podman pull docker.io/gvenzl/oracle-free:23-slim-faststart-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23-slim-faststart-$(getArch) docker.io/gvenzl/oracle-free:23-slim-faststart-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23-slim-faststart-$(getArch)

echo "Backup 23-slim"
podman pull docker.io/gvenzl/oracle-free:23-slim-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:23-slim-$(getArch) docker.io/gvenzl/oracle-free:23-slim-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:23-slim-$(getArch)

echo "Backup slim-faststart"
podman pull docker.io/gvenzl/oracle-free:slim-faststart-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:slim-faststart-$(getArch) docker.io/gvenzl/oracle-free:slim-faststart-$(getArch)-backup
podman rmi  docker.io/gvenzl/oracle-free:slim-faststart-$(getArch)

echo "Backup slim"
podman pull docker.io/gvenzl/oracle-free:slim-$(getArch)
podman tag  docker.io/gvenzl/oracle-free:slim-$(getArch) docker.io/gvenzl/oracle-free:slim-backup
podman rmi  docker.io/gvenzl/oracle-free:slim-$(getArch)
