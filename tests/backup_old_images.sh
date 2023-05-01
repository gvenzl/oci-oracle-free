#!/bin/bash
#
# Since: April 2023
# Author: gvenzl
# Name: backup_old_images.sh
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

# Download images
echo "Backup latest"
podman pull docker.io/gvenzl/oracle-free:latest
podman tag  docker.io/gvenzl/oracle-free:latest docker.io/gvenzl/oracle-free:latest-backup
podman rmi  docker.io/gvenzl/oracle-free:latest

echo "Backup latest-faststart"
podman pull docker.io/gvenzl/oracle-free:latest-faststart
podman tag  docker.io/gvenzl/oracle-free:latest-faststart docker.io/gvenzl/oracle-free:latest-faststart-backup
podman rmi  docker.io/gvenzl/oracle-free:latest-faststart

# Backup 23c images
echo "Backup 23.2-full-faststart"
podman pull docker.io/gvenzl/oracle-free:23.2-full-faststart
podman tag  docker.io/gvenzl/oracle-free:23.2-full-faststart docker.io/gvenzl/oracle-free:23.2-full-faststart-backup
podman rmi  docker.io/gvenzl/oracle-free:23.2-full-faststart

echo "Backup 23.2-full"
podman pull docker.io/gvenzl/oracle-free:23.2-full
podman tag  docker.io/gvenzl/oracle-free:23.2-full docker.io/gvenzl/oracle-free:23.2-full-backup
podman rmi  docker.io/gvenzl/oracle-free:23.2-full

echo "Backup 23-full-faststart"
podman pull docker.io/gvenzl/oracle-free:23-full-faststart
podman tag  docker.io/gvenzl/oracle-free:23-full-faststart docker.io/gvenzl/oracle-free:23-full-faststart-backup
podman rmi  docker.io/gvenzl/oracle-free:23-full-faststart

echo "Backup 23-full"
podman pull docker.io/gvenzl/oracle-free:23-full
podman tag  docker.io/gvenzl/oracle-free:23-full docker.io/gvenzl/oracle-free:23-full-backup
podman rmi  docker.io/gvenzl/oracle-free:23-full

echo "Backup full-faststart"
podman pull docker.io/gvenzl/oracle-free:full-faststart
podman tag  docker.io/gvenzl/oracle-free:full-faststart docker.io/gvenzl/oracle-free:full-faststart-backup
podman rmi  docker.io/gvenzl/oracle-free:full-faststart

echo "Backup full"
podman pull docker.io/gvenzl/oracle-free:full
podman tag  docker.io/gvenzl/oracle-free:full docker.io/gvenzl/oracle-free:full-backup
podman rmi  docker.io/gvenzl/oracle-free:full

echo "Backup 23.2-faststart"
podman pull docker.io/gvenzl/oracle-free:23.2-faststart
podman tag  docker.io/gvenzl/oracle-free:23.2-faststart docker.io/gvenzl/oracle-free:23.2-faststart-backup
podman rmi  docker.io/gvenzl/oracle-free:23.2-faststart

echo "Backup 23.2"
podman pull docker.io/gvenzl/oracle-free:23.2
podman tag  docker.io/gvenzl/oracle-free:23.2 docker.io/gvenzl/oracle-free:23.2-backup
podman rmi  docker.io/gvenzl/oracle-free:23.2

echo "Backup 23-faststart"
podman pull docker.io/gvenzl/oracle-free:23-faststart
podman tag  docker.io/gvenzl/oracle-free:23-faststart docker.io/gvenzl/oracle-free:23-faststart-backup
podman rmi  docker.io/gvenzl/oracle-free:23-faststart

echo "Backup 23"
podman pull docker.io/gvenzl/oracle-free:23
podman tag  docker.io/gvenzl/oracle-free:23 docker.io/gvenzl/oracle-free:23-backup
podman rmi  docker.io/gvenzl/oracle-free:23

echo "Backup 23.2-slim-faststart"
podman pull docker.io/gvenzl/oracle-free:23.2-slim-faststart
podman tag  docker.io/gvenzl/oracle-free:23.2-slim-faststart docker.io/gvenzl/oracle-free:23.2-slim-faststart-backup
podman rmi  docker.io/gvenzl/oracle-free:23.2-slim-faststart

echo "Backup 23.2-slim"
podman pull docker.io/gvenzl/oracle-free:23.2-slim
podman tag  docker.io/gvenzl/oracle-free:23.2-slim docker.io/gvenzl/oracle-free:23.2-slim-backup
podman rmi  docker.io/gvenzl/oracle-free:23.2-slim

echo "Backup 23-slim-faststart"
podman pull docker.io/gvenzl/oracle-free:23-slim-faststart
podman tag  docker.io/gvenzl/oracle-free:23-slim-faststart docker.io/gvenzl/oracle-free:23-slim-faststart-backup
podman rmi  docker.io/gvenzl/oracle-free:23-slim-faststart

echo "Backup 23-slim"
podman pull docker.io/gvenzl/oracle-free:23-slim
podman tag  docker.io/gvenzl/oracle-free:23-slim docker.io/gvenzl/oracle-free:23-slim-backup
podman rmi  docker.io/gvenzl/oracle-free:23-slim

echo "Backup slim-faststart"
podman pull docker.io/gvenzl/oracle-free:slim-faststart
podman tag  docker.io/gvenzl/oracle-free:slim-faststart docker.io/gvenzl/oracle-free:slim-faststart-backup
podman rmi  docker.io/gvenzl/oracle-free:slim-faststart

echo "Backup slim"
podman pull docker.io/gvenzl/oracle-free:slim
podman tag  docker.io/gvenzl/oracle-free:slim docker.io/gvenzl/oracle-free:slim-backup
podman rmi  docker.io/gvenzl/oracle-free:slim
