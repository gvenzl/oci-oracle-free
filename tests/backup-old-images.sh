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

########################################
### Backup latest images
########################################
echo "Backup latest"
backupImage "docker.io" "latest-$(getArch)"

echo "Backup latest-faststart"
backupImage "docker.io" "latest-faststart-$(getArch)"



########################################
### Backup full images
########################################
echo "Backup 23-full-faststart"
backupImage "docker.io" "23-full-faststart-$(getArch)"

echo "Backup 23-full"
backupImage "docker.io" "23-full-$(getArch)"

echo "Backup full-faststart"
backupImage "docker.io" "full-faststart-$(getArch)"

echo "Backup full"
backupImage "docker.io" "full-$(getArch)"



########################################
### Backup regular images
########################################
echo "Backup 23-faststart"
backupImage "docker.io" "23-faststart-$(getArch)"

echo "Backup 23"
backupImage "docker.io" "23-$(getArch)"



########################################
### Backup slim images
########################################
echo "Backup 23-slim-faststart"
backupImage "docker.io" "23-slim-faststart-$(getArch)"

echo "Backup 23-slim"
backupImage "docker.io" "23-slim-$(getArch)"

echo "Backup slim-faststart"
backupImage "docker.io" "slim-faststart-$(getArch)"

echo "Backup slim"
backupImage "docker.io" "slim-$(getArch)"




########################################
### Backup 23.7 images
########################################
echo "Backup 23.7-full-faststart"
backupImage "docker.io" "23.7-full-faststart-$(getArch)"

echo "Backup 23.7-full"
backupImage "docker.io" "23.7-full-$(getArch)"

echo "Backup 23.7-faststart"
backupImage "docker.io" "23.7-faststart-$(getArch)"

echo "Backup 23.7"
backupImage "docker.io" "23.7-$(getArch)"

echo "Backup 23.7-slim-faststart"
backupImage "docker.io" "23.7-slim-faststart-$(getArch)"

echo "Backup 23.7-slim"
backupImage "docker.io" "23.7-slim-$(getArch)"




########################################
### Backup 23.6 images
########################################
echo "Backup 23.6-full-faststart"
backupImage "docker.io" "23.6-full-faststart-$(getArch)"

echo "Backup 23.6-full"
backupImage "docker.io" "23.6-full-$(getArch)"

echo "Backup 23.6-faststart"
backupImage "docker.io" "23.6-faststart-$(getArch)"

echo "Backup 23.6"
backupImage "docker.io" "23.6-$(getArch)"

echo "Backup 23.6-slim-faststart"
backupImage "docker.io" "23.6-slim-faststart-$(getArch)"

echo "Backup 23.6-slim"
backupImage "docker.io" "23.6-slim-$(getArch)"




########################################
### Backup 23.5 images
########################################
echo "Backup 23.5-full-faststart"
backupImage "docker.io" "23.5-full-faststart-$(getArch)"

echo "Backup 23.5-full"
backupImage "docker.io" "23.5-full-$(getArch)"

echo "Backup 23.5-faststart"
backupImage "docker.io" "23.5-faststart-$(getArch)"

echo "Backup 23.5"
backupImage "docker.io" "23.5-$(getArch)"

echo "Backup 23.5-slim-faststart"
backupImage "docker.io" "23.5-slim-faststart-$(getArch)"

echo "Backup 23.5-slim"
backupImage "docker.io" "23.5-slim-$(getArch)"



########################################
### Backup 23.4 images
########################################
echo "Backup 23.4-full-faststart"
backupImage "docker.io" "23.4-full-faststart"

echo "Backup 23.4-full"
backupImage "docker.io" "23.4-full"

echo "Backup 23.4-faststart"
backupImage "docker.io" "23.4-faststart"

echo "Backup 23.4"
backupImage "docker.io" "23.4"

echo "Backup 23.4-slim-faststart"
backupImage "docker.io" "23.4-slim-faststart"

echo "Backup 23.4-slim"
backupImage "docker.io" "23.4-slim"



########################################
### Backup 23.3 images
########################################
echo "Backup 23.3-full-faststart"
backupImage "docker.io" "23.3-full-faststart"

echo "Backup 23.3-full"
backupImage "docker.io" "23.3-full"

echo "Backup 23.3-faststart"
backupImage "docker.io" "23.3-faststart"

echo "Backup 23.3"
backupImage "docker.io" "23.3"

echo "Backup 23.3-slim-faststart"
backupImage "docker.io" "23.3-slim-faststart"

echo "Backup 23.3-slim"
backupImage "docker.io" "23.3-slim"



########################################
### Backup 23.2 images
########################################
echo "Backup 23.2-full-faststart"
backupImage "docker.io" "23.2-full-faststart"

echo "Backup 23.2-full"
backupImage "docker.io" "23.2-full"

echo "Backup 23.2-faststart"
backupImage "docker.io" "23.2-faststart"

echo "Backup 23.2"
backupImage "docker.io" "23.2"

echo "Backup 23.2-slim-faststart"
backupImage "docker.io" "23.2-slim-faststart"

echo "Backup 23.2-slim"
backupImage "docker.io" "23.2-slim"
