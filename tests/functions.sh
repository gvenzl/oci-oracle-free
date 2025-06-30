#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: functions.sh
# Description: Helper functions for test scripts
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

# Function: getArch
# Returns the architecture of the current build environment

function getArch {

  ENV_ARCH=$(uname -m)
  if [ "${ENV_ARCH}" == "x86_64" ]; then
    echo "amd64";
  elif [[ "${ENV_ARCH}" == "aarch64" || "${ENV_ARCH}" == "arm64" ]]; then
    echo "arm64";
  fi;
}

# Function: checkDB
# Checks whether the Oracle DB is up and running.
#
# Parameters:
# CONTAINER_NAME: The name of the podman container

function checkDB {

  CONTAINER_NAME="${1}"

  tries=0
  max_tries=30        # 5 minute timeout for tests on slower build machines
  sleep_time_secs=10

  # Wait until container is ready
  while [ ${tries} -lt ${max_tries} ]; do
    # Sleep until DB is up and running
    sleep ${sleep_time_secs};

    # Is the database ready for use?

    if podman logs ${CONTAINER_NAME} | grep 'DATABASE IS READY TO USE' >/dev/null; then
      return 0;
    fi;

    ((tries++))

  done;

  return 1;
}

# Function: tear_down_container
# Tears down a container
#
# Parameters:
# CONTAINER_NAME: The container name

function tear_down_container {

  echo "Tearing down container";
  echo "";
  podman kill "${1}" >/dev/null
  podman rm -f "${1}" >/dev/null
}

# Function: runContainerTest
# Runs a container (podman run) test
#
# Parameters:
# TEST_NAME: The test name
# CONTAINER_NAME: The container name
# IMAGE: The image to start the container from

function runContainerTest {
  TEST_NAME="${1}"
  CONTAINER_NAME="${2}"
  IMAGE="${3}"
  APP_USER_CMD=""
  APP_USER_PASSWORD_CMD=""
  ORA_PWD_CMD="${ORA_PWD_CMD:--e ORACLE_PASSWORD=LetsTest1}"
  ORACLE_DATABASE_CMD=""
  VOLUME_CMD=""

  if [ -n "${APP_USER:-}" ]; then
    APP_USER_CMD="-e APP_USER=${APP_USER}"
  fi;

  if [ -n "${APP_USER_PASSWORD:-}" ]; then
    APP_USER_PASSWORD_CMD="-e APP_USER_PASSWORD=${APP_USER_PASSWORD}"
  fi;

  if [ -n "${ORACLE_DATABASE:-}" ]; then
    ORACLE_DATABASE_CMD="-e ORACLE_DATABASE=${ORACLE_DATABASE}"
  fi;

  if [ -n "${CONTAINER_VOLUME:-}" ]; then
    VOLUME_CMD="-v ${CONTAINER_VOLUME}"
  fi;

  echo "TEST ${TEST_NAME}: Started"
  echo ""

  TEST_START_TMS=$(date '+%s')

  # Run and start container
  podman run -d --name ${CONTAINER_NAME} ${ORA_PWD_CMD} ${APP_USER_CMD} ${APP_USER_PASSWORD_CMD} ${ORACLE_DATABASE_CMD} ${VOLUME_CMD} ${IMAGE} >/dev/null

  # Check whether Oracle DB came up successfully
  if checkDB "${CONTAINER_NAME}"; then
    # Only tear down container if $NO_TEAR_DOWN has NOT been specified
    if [ -z "${NO_TEAR_DOWN:-}" ]; then

      TEST_END_TMS=$(date '+%s')
      TEST_DURATION=$(( TEST_END_TMS - TEST_START_TMS ))

      echo "TEST ${TEST_NAME}: OK (${TEST_DURATION} sec)";
      echo "";
      tear_down_container "${CONTAINER_NAME}"
    fi;

    return 0;

  # Test failed
  else
    # Print logs of failed test
    podman logs "${CONTAINER_NAME}";

    echo "";
    echo "TEST ${TEST_NAME}: FAILED!";
    echo "";
    tear_down_container "${CONTAINER_NAME}"

    exit 1;

  fi;
}

# Function: createManifest
# Creates a multi-arch manifest
#
# Parameters:
# DESTINATION: The container registry destination of the images
# TAG: The tag to create the multi-arch manifest for

function createManifest() {

  DESTINATION="${1}"
  TAG="${2}"

  echo "Creating manifest: ${DESTINATION}/gvenzl/oracle-free:${TAG}"

  buildah manifest rm "${DESTINATION}/gvenzl/oracle-free:${TAG}" || echo "Manifest does not exist."

  buildah manifest create \
    --annotation org.opencontainers.image.title="Oracle Database Free Container images" \
    --annotation org.opencontainers.image.description="Oracle Database Free for everyone!" \
    --annotation org.opencontainers.image.authors="Gerald Venzl" \
    --annotation org.opencontainers.image.source="https://github.com/gvenzl/oci-oracle-free" \
    --annotation org.opencontainers.image.licenses="Apache-2.0" \
    --annotation org.opencontainers.image.documentation="https://github.com/gvenzl/oci-oracle-free/blob/main/README.md" \
    "${DESTINATION}/gvenzl/oracle-free:${TAG}" \
    "${DESTINATION}/gvenzl/oracle-free:${TAG}-amd64" \
    "${DESTINATION}/gvenzl/oracle-free:${TAG}-arm64"
}

# Function: pushManifest
# Pushes a multi-arch manifest
#
# Parameters:
# DESTINATION: The container registry destination of the images
# TAG: The tag to create the multi-arch manifest for

function pushManifest() {

  DESTINATION="${1}"
  TAG="${2}"

  echo "Pushing manifest: ${DESTINATION}/gvenzl/oracle-free:${TAG}"

  buildah manifest push "${DESTINATION}/gvenzl/oracle-free:${TAG}" "docker://${DESTINATION}/gvenzl/oracle-free:${TAG}"
}

# Function: createAndPushManifest
# Creates and pushes a multi-arch manifest
#
# Parameters:
# DESTINATION: The container registry destination of the images
# TAG: The tag to create the multi-arch manifest for

function createAndPushManifest() {

  DESTINATION="${1}"
  TAG="${2}"

  createManifest "${DESTINATION}" "${TAG}"
  pushManifest "${DESTINATION}" "${TAG}"
}

# Function: backupImage
# Backs up an image from the container registry
#
# Parameters:
# DESTINATION: The container registry destination of the images
# TAG: The tag to create the multi-arch manifest for

function backupImage() {

  DESTINATION="${1}"
  TAG="${2}"

  podman pull ${DESTINATION}/gvenzl/oracle-free:${TAG}
  podman tag  ${DESTINATION}/gvenzl/oracle-free:${TAG} ${DESTINATION}/gvenzl/oracle-free:${TAG}-backup
  podman rmi  ${DESTINATION}/gvenzl/oracle-free:${TAG}
}
