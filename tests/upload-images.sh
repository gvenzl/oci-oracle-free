#!/bin/bash
#
# Since: April, 2023
# Author: gvenzl
# Name: upload-images.sh
# Description: Upload images to registry
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

source ./function.sh

FASTSTART_UPLOAD="N"
REGULAR_UPLOAD="N"
DESTINATION="docker.io"

while getopts "xrdg" optname; do
  case "${optname}" in
    "x") FASTSTART_UPLOAD="Y" ;;
    "r") REGULAR_UPLOAD="Y" ;;
    "d") DESTINATION="docker.io" ;;
    "g") DESTINATION="ghcr.io" ;;
    "?")
      echo "Invalid option";
      exit 1;
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options inside upload_images.sh"
      ;;
  esac;
done;

echo "Uploading to ${DESTINATION}"

# Log into Docker Hub before anything else so that one does not have to
# wait for the backup to be finished)
echo "Login to ${DESTINATION}:"
podman login ${DESTINATION}

# Ensure all tags are in place
./all_tag_images.sh

# Backup images
read -r -p "Do you want to backup the old images? [Y/n]: " response
# Default --> "Y"
response=${response:-Y}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  ./backup_old_images.sh
fi;

# Start from old to new, as packages will be sorted by last update/upload time descending

function uploadFastStart() {

  echo ""
  echo "Uploading FASTSTART images..."
  echo ""

  # Upload FULL images
  #echo "Upload 23.2-full-faststart"
  #podman push localhost/gvenzl/oracle-free:23.2-full-faststart             ${DESTINATION}/gvenzl/oracle-free:23.2-full-faststart
  #echo "Upload 23.3-full-faststart"
  #podman push localhost/gvenzl/oracle-free:23.3-full-faststart             ${DESTINATION}/gvenzl/oracle-free:23.3-full-faststart
  #echo "Upload 23.4-full-faststart"
  #podman push localhost/gvenzl/oracle-free:23.4-full-faststart             ${DESTINATION}/gvenzl/oracle-free:23.4-full-faststart
  echo "Upload 23.5-full-faststart-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23.5-full-faststart-$(getArch)     ${DESTINATION}/gvenzl/oracle-free:23.5-full-faststart-$(getArch)
  echo "Upload 23-full-faststart-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23-full-faststart-$(getArch)       ${DESTINATION}/gvenzl/oracle-free:23-full-faststart-$(getArch)
  echo "Upload full-faststart-$(getArch)"
  podman push localhost/gvenzl/oracle-free:full-faststart-$(getArch)          ${DESTINATION}/gvenzl/oracle-free:full-faststart-$(getArch)

  # Upload REGULAR images
  #echo "Upload 23.2-faststart"
  #podman push localhost/gvenzl/oracle-free:23.2-faststart                  ${DESTINATION}/gvenzl/oracle-free:23.2-faststart
  #echo "Upload 23.3-faststart"
  #podman push localhost/gvenzl/oracle-free:23.3-faststart                  ${DESTINATION}/gvenzl/oracle-free:23.3-faststart
  #echo "Upload 23.4-faststart"
  #podman push localhost/gvenzl/oracle-free:23.4-faststart                  ${DESTINATION}/gvenzl/oracle-free:23.4-faststart
  echo "Upload 23.5-faststart-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23.5-faststart-$(getArch)          ${DESTINATION}/gvenzl/oracle-free:23.5-faststart-$(getArch)
  echo "Upload 23-faststart-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23-faststart-$(getArch)            ${DESTINATION}/gvenzl/oracle-free:23-faststart-$(getArch)

  # Upload SLIM images
  #echo "Upload 23.2-slim-faststart"
  #podman push localhost/gvenzl/oracle-free:23.2-slim-faststart             ${DESTINATION}/gvenzl/oracle-free:23.2-slim-faststart
  #echo "Upload 23.3-slim-faststart"
  #podman push localhost/gvenzl/oracle-free:23.3-slim-faststart             ${DESTINATION}/gvenzl/oracle-free:23.3-slim-faststart
  #echo "Upload 23.4-slim-faststart"
  #podman push localhost/gvenzl/oracle-free:23.4-slim-faststart             ${DESTINATION}/gvenzl/oracle-free:23.4-slim-faststart
  echo "Upload 23.5-slim-faststart-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23.5-slim-faststart-$(getArch)     ${DESTINATION}/gvenzl/oracle-free:23.5-slim-faststart-$(getArch)
  echo "Upload 23-slim-faststart-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23-slim-faststart-$(getArch)       ${DESTINATION}/gvenzl/oracle-free:23-slim-faststart-$(getArch)
  echo "Upload slim-faststart-$(getArch)"
  podman push localhost/gvenzl/oracle-free:slim-faststart-$(getArch)          ${DESTINATION}/gvenzl/oracle-free:slim-faststart-$(getArch)

  # Upload latest
  echo "Upload latest-faststart-$(getArch)"
  podman push localhost/gvenzl/oracle-free:latest-faststart-$(getArch)        ${DESTINATION}/gvenzl/oracle-free:latest-faststart-$(getArch)
}

function upload() {

  echo ""
  echo "Uploading REGULAR images..."
  echo ""

  # Upload FULL images
  #echo "Upload 23.2-full"
  #podman push localhost/gvenzl/oracle-free:23.2-full                       ${DESTINATION}/gvenzl/oracle-free:23.2-full
  #echo "Upload 23.3-full"
  #podman push localhost/gvenzl/oracle-free:23.3-full                       ${DESTINATION}/gvenzl/oracle-free:23.3-full
  #echo "Upload 23.4-full"
  #podman push localhost/gvenzl/oracle-free:23.4-full                       ${DESTINATION}/gvenzl/oracle-free:23.4-full
  echo "Upload 23.5-full-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23.5-full-$(getArch)               ${DESTINATION}/gvenzl/oracle-free:23.5-full-$(getArch)
  echo "Upload 23-full-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23-full-$(getArch)                 ${DESTINATION}/gvenzl/oracle-free:23-full-$(getArch)
  echo "Upload full-$(getArch)"
  podman push localhost/gvenzl/oracle-free:full-$(getArch)                    ${DESTINATION}/gvenzl/oracle-free:full-$(getArch)

  # Upload REGULAR images
  #echo "Upload 23.2"
  #podman push localhost/gvenzl/oracle-free:23.2                            ${DESTINATION}/gvenzl/oracle-free:23.2
  #echo "Upload 23.3"
  #podman push localhost/gvenzl/oracle-free:23.3                            ${DESTINATION}/gvenzl/oracle-free:23.3
  #echo "Upload 23.4"
  #podman push localhost/gvenzl/oracle-free:23.4                            ${DESTINATION}/gvenzl/oracle-free:23.4
  echo "Upload 23.5-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23.5-$(getArch)                    ${DESTINATION}/gvenzl/oracle-free:23.5-$(getArch)
  echo "Upload 23-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23-$(getArch)                      ${DESTINATION}/gvenzl/oracle-free:23-$(getArch)

  # Upload SLIM images
  #echo "Upload 23.2-slim"
  #podman push localhost/gvenzl/oracle-free:23.2-slim                       ${DESTINATION}/gvenzl/oracle-free:23.2-slim
  #echo "Upload 23.3-slim"
  #podman push localhost/gvenzl/oracle-free:23.3-slim                       ${DESTINATION}/gvenzl/oracle-free:23.3-slim
  #echo "Upload 23.4-slim"
  #podman push localhost/gvenzl/oracle-free:23.4-slim                       ${DESTINATION}/gvenzl/oracle-free:23.4-slim
  echo "Upload 23.5-slim-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23.5-slim-$(getArch)               ${DESTINATION}/gvenzl/oracle-free:23.5-slim-$(getArch)
  echo "Upload 23-slim-$(getArch)"
  podman push localhost/gvenzl/oracle-free:23-slim-$(getArch)                 ${DESTINATION}/gvenzl/oracle-free:23-slim-$(getArch)
  echo "Upload slim-$(getArch)"
  podman push localhost/gvenzl/oracle-free:slim-$(getArch)                    ${DESTINATION}/gvenzl/oracle-free:slim-$(getArch)

  # Upload latest
  echo "Upload latest"
  podman push localhost/gvenzl/oracle-free:latest-$(getArch)                  ${DESTINATION}/gvenzl/oracle-free:latest-$(getArch)
}

# Upload images

echo ""
echo "Starting upload..."
echo ""

if [[ "$FASTSTART_UPLOAD" == "Y" ]]; then
  uploadFastStart;
fi;

if [[ "$REGULAR_UPLOAD" == "Y" ]]; then
  upload;
fi;

echo ""
echo "Done uploading"
echo ""
