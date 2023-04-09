#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: buildContainerImage.sh
# Description: Build a Container image for Oracle Database Free
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

VERSION="23.2"
FLAVOR="REGULAR"
IMAGE_NAME="gvenzl/oracle-free"
SKIP_CHECKSUM="false"
FASTSTART="false"
BASE_IMAGE=""

function usage() {
    cat << EOF

Usage: buildContainerImage.sh [-f | -r | -s] [-x] [-v version] [-i] [-o] [container build option]
Builds a container image for Oracle Database Free.

Parameters:
   -f: creates a 'full' image
   -r: creates a regular image (default)
   -s: creates a 'slim' image
   -x: creates a 'faststart' image
   -v: version of Oracle Database Free to build
       Choose one of: 23.2
   -i: ignores checksum test
   -o: passes on container build option

* select only one flavor: -f, -r, or -s

Apache License, Version 2.0

Copyright (c) 2023 Gerald Venzl

EOF

}

while getopts "hfnsv:io:x" optname; do
  case "${optname}" in
    "h")
      usage
      exit 0;
      ;;
    "v")
      VERSION="${OPTARG}"
      ;;
    "f")
      FLAVOR="FULL"
      ;;
    "r")
      FLAVOR="REGULAR"
      ;;
    "s")
      FLAVOR="SLIM"
      ;;
    "i")
      SKIP_CHECKSUM="true"
      ;;
    "o")
      eval "BUILD_OPTS=(${OPTARG})"
      ;;
    "x")
      FASTSTART="true"
      ;;
    "?")
      usage;
      exit 1;
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options inside buildContainerImage.sh"
      ;;
  esac;
done;

# Checking SHASUM
if [ "${SKIP_CHECKSUM}" == "false" ]; then

  echo "BUILDER: verifying checksum of rpm file - please wait..."

  SHASUM_RET=$(shasum -a 256 oracle*free*"${VERSION%%.*}"*.rpm)

  if [[ ( "${VERSION}" == "23.2"  &&  "${SHASUM_RET%% *}" != "63b6c0ec9464682cfd9814e7e2a5d533139e5c6aeb9d3e7997a5f976d6677ca6" ) ]]; then
    echo "BUILDER: WARNING! SHA sum of RPM does not match with what's expected!"
    echo "BUILDER: WARNING! Verify that the .rpm file is not corrupt!"
  fi;

  echo "BUILDER: checksum verification done"
else
  echo "BUILDER: checksum verification ignored"
fi;

# Set Dockerfile name
DOCKER_FILE="Dockerfile.${VERSION//./}"

# Give image base tag
IMAGE_NAME="${IMAGE_NAME}:${VERSION}"

# Add image flavor to the tag (regular has no tag)
if [ "${FLAVOR}" != "REGULAR" ]; then
  IMAGE_NAME="${IMAGE_NAME}-${FLAVOR,,}"
fi;

# Add faststart tag to image and set Dockerfile
if [ "${FASTSTART}" == "true" ]; then
  BASE_IMAGE="${IMAGE_NAME}"
  IMAGE_NAME="${IMAGE_NAME}-faststart"
  DOCKER_FILE="Dockerfile.faststart"
fi;

echo "BUILDER: building image $IMAGE_NAME"

BUILD_START_TMS=$(date '+%s')

buildah bud -f "$DOCKER_FILE" -t "${IMAGE_NAME}" --build-arg BUILD_MODE="${FLAVOR}" --build-arg BASE_IMAGE="${BASE_IMAGE}"

BUILD_END_TMS=$(date '+%s')
BUILD_DURATION=$(( BUILD_END_TMS - BUILD_START_TMS ))

echo "Build of container image ${IMAGE_NAME} completed in ${BUILD_DURATION} seconds."
