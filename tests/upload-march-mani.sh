#!/bin/bash
#
# Since: September, 2024
# Author: gvenzl
# Name: upload-march-mani.sh
# Description: Uploads multi-arch / multi-platform manifests to the registry
#
# Copyright 2024 Gerald Venzl
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

function upload() {

  echo "########################################################"
  echo "Uploading regular manifests to ${DESTINATION}"
  echo "########################################################"

  createAndPushManifest ${DESTINATION} "23.7-full"
  createAndPushManifest ${DESTINATION} "23.6-full"
  createAndPushManifest ${DESTINATION} "23-full"
  createAndPushManifest ${DESTINATION} "full"
  createAndPushManifest ${DESTINATION} "23.6"
  createAndPushManifest ${DESTINATION} "23.7"
  createAndPushManifest ${DESTINATION} "23"
  createAndPushManifest ${DESTINATION} "latest"
  createAndPushManifest ${DESTINATION} "23.7-slim"
  createAndPushManifest ${DESTINATION} "23.6-slim"
  createAndPushManifest ${DESTINATION} "23-slim"
  createAndPushManifest ${DESTINATION} "slim"
}

function uploadFastStart() {

  echo "########################################################"
  echo "Uploading faststart manifests to ${DESTINATION}"
  echo "########################################################"

  createAndPushManifest ${DESTINATION} "23.7-full-faststart"
  createAndPushManifest ${DESTINATION} "23.6-full-faststart"
  createAndPushManifest ${DESTINATION} "23-full-faststart"
  createAndPushManifest ${DESTINATION} "full-faststart"
  createAndPushManifest ${DESTINATION} "23.7-faststart"
  createAndPushManifest ${DESTINATION} "23.6-faststart"
  createAndPushManifest ${DESTINATION} "23-faststart"
  createAndPushManifest ${DESTINATION} "latest-faststart"
  createAndPushManifest ${DESTINATION} "23.7-slim-faststart"
  createAndPushManifest ${DESTINATION} "23.6-slim-faststart"
  createAndPushManifest ${DESTINATION} "23-slim-faststart"
  createAndPushManifest ${DESTINATION} "slim-faststart"
}

function usage() {
    cat << EOF

Usage: upload-march-mani.sh [-d | -g ] [-r] [-x] [-h]
Uploads multi-architecture manifests to the Container Registries.

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

FASTSTART_UPLOAD="N"
REGULAR_UPLOAD="N"
DESTINATION="docker.io"

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

# Log into Docker Hub before anything else so that one does not have to
# wait for the backup to be finished)
echo "Login to ${DESTINATION}:"
podman login ${DESTINATION}

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
