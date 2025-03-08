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

source ./functions.sh

FASTSTART_UPLOAD="N"
REGULAR_UPLOAD="N"
DESTINATION="docker.io"

function usage() {
    cat << EOF

Usage: upload-images.sh [-d | -g ] [-r] [-x] [-h]
Uploads images to Container Registries.

Parameters:
   -d: Upload to Docker.io (default)
   -g: Upload to GitHub GHCR.io
   -r: Upload regular images
   -x: Upload 'faststart' images
   -h: Shows this help

* select only one destination: -d or -g

Apache License, Version 2.0

Copyright (c) 2024 Gerald Venzl

EOF

}

function upload() {

  TAG=${1}

  echo "Upload ${TAG}"
  podman push "localhost/gvenzl/oracle-free:${TAG}" "${DESTINATION}/gvenzl/oracle-free:${TAG}"
  echo ""

}


function uploadFastStart() {

  echo ""
  echo "Uploading FASTSTART images..."
  echo ""

  # Start from old to new, as packages will be sorted by last update/upload time descending


  # Upload FULL images
  #upload "23.2-full-faststart"
  #upload "23.3-full-faststart"
  #upload "23.4-full-faststart"
  #upload "23.5-full-faststart-$(getArch)"
  upload "23.6-full-faststart-$(getArch)"
  upload "23.7-full-faststart-$(getArch)"
  upload "23-full-faststart-$(getArch)"
  upload "full-faststart-$(getArch)"

  # Upload REGULAR images
  #upload "23.2-faststart"
  #upload "23.3-faststart"
  #upload "23.4-faststart"
  #upload "23.5-faststart-$(getArch)"
  upload "23.6-faststart-$(getArch)"
  upload "23.7-faststart-$(getArch)"
  upload "23-faststart-$(getArch)"

  # Upload SLIM images
  #upload "23.2-slim-faststart"
  #upload "23.3-slim-faststart"
  #upload "23.4-slim-faststart"
  #upload "23.5-slim-faststart-$(getArch)"
  upload "23.6-slim-faststart-$(getArch)"
  upload "23.7-slim-faststart-$(getArch)"
  upload "23-slim-faststart-$(getArch)"
  upload "slim-faststart-$(getArch)"

  # Upload latest
  upload "latest-faststart-$(getArch)"
}

function uploadRegular() {

  echo ""
  echo "Uploading REGULAR images..."
  echo ""

  # Start from old to new, as packages will be sorted by last update/upload time descending

  # Upload FULL images
  #upload "23.2-full"
  #upload "23.3-full"
  #upload "23.4-full"
  #upload "23.5-full-$(getArch)"
  upload "23.6-full-$(getArch)"
  upload "23.7-full-$(getArch)"
  upload "23-full-$(getArch)"
  upload "full-$(getArch)"

  # Upload REGULAR images
  #upload "23.2"
  #upload "23.3"
  #upload "23.4"
  #upload "23.5-$(getArch)"
  upload "23.6-$(getArch)"
  upload "23.7-$(getArch)"
  upload "23-$(getArch)"

  # Upload SLIM images
  #upload "23.2-slim"
  #upload "23.3-slim"
  #upload "23.4-slim"
  #upload "23.5-slim-$(getArch)"
  upload "23.6-slim-$(getArch)"
  upload "23.7-slim-$(getArch)"
  upload "23-slim-$(getArch)"
  upload "slim-$(getArch)"

  # Upload latest
  upload "latest-$(getArch)"
}

while getopts "xrdgh" optname; do
  case "${optname}" in
    "x") FASTSTART_UPLOAD="Y" ;;
    "r") REGULAR_UPLOAD="Y" ;;
    "d") DESTINATION="docker.io" ;;
    "g") DESTINATION="ghcr.io" ;;
    "h")
      usage
      exit 0;
      ;;
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
./all-tag-images.sh

# Backup images
read -r -p "Do you want to backup the old images? [Y/n]: " response
# Default --> "Y"
response=${response:-Y}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  ./backup-old-images.sh
fi;

# Upload images

echo ""
echo "Starting upload..."
echo ""

if [[ "$FASTSTART_UPLOAD" == "Y" ]]; then
  uploadFastStart;
fi;

if [[ "$REGULAR_UPLOAD" == "Y" ]]; then
  uploadRegular;
fi;

echo ""
echo "Done uploading"
echo ""
