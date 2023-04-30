#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: upload_images.sh
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

# Log into Docker Hub before anything else so that one does not have to
# wait for the backup to be finished)
echo "Login to Docker Hub:"
podman login docker.io

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

# Upload images

echo ""
echo "Starting upload..."
echo ""

# Upload 23c FULL images
echo "Upload 23.2-full-faststart"
podman push localhost/gvenzl/oracle-free:23.2-full-faststart     docker.io/gvenzl/oracle-free:23.2-full-faststart
echo "Upload 23-full-faststart"
podman push localhost/gvenzl/oracle-free:23-full-faststart       docker.io/gvenzl/oracle-free:23-full-faststart
echo "Upload full-faststart"
podman push localhost/gvenzl/oracle-free:full-faststart            docker.io/gvenzl/oracle-free:full-faststart

echo "Upload 23.2-full"
podman push localhost/gvenzl/oracle-free:23.2-full               docker.io/gvenzl/oracle-free:23.2-full
echo "Upload 23-full"
podman push localhost/gvenzl/oracle-free:23-full                 docker.io/gvenzl/oracle-free:23-full
echo "Upload full"
podman push localhost/gvenzl/oracle-free:full                      docker.io/gvenzl/oracle-free:full


# Upload 23c images
echo "Upload 23.2-faststart"
podman push localhost/gvenzl/oracle-free:23.2-faststart          docker.io/gvenzl/oracle-free:23.2-faststart
echo "Upload 23-faststart"
podman push localhost/gvenzl/oracle-free:23-faststart            docker.io/gvenzl/oracle-free:23-faststart

echo "Upload 23.2"
podman push localhost/gvenzl/oracle-free:23.2                    docker.io/gvenzl/oracle-free:23.2
echo "Upload 23"
podman push localhost/gvenzl/oracle-free:23                      docker.io/gvenzl/oracle-free:23


# Upload 23c SLIM images
echo "Upload 23.2-slim-faststart"
podman push localhost/gvenzl/oracle-free:23.2-slim-faststart     docker.io/gvenzl/oracle-free:23.2-slim-faststart
echo "Upload 23-slim-faststart"
podman push localhost/gvenzl/oracle-free:23-slim-faststart       docker.io/gvenzl/oracle-free:23-slim-faststart
echo "Upload slim-faststart"
podman push localhost/gvenzl/oracle-free:slim-faststart            docker.io/gvenzl/oracle-free:slim-faststart

echo "Upload 23.2-slim"
podman push localhost/gvenzl/oracle-free:23.2-slim               docker.io/gvenzl/oracle-free:23.2-slim
echo "Upload 23-slim"
podman push localhost/gvenzl/oracle-free:23-slim                 docker.io/gvenzl/oracle-free:23-slim
echo "Upload slim"
podman push localhost/gvenzl/oracle-free:slim                      docker.io/gvenzl/oracle-free:slim


# Upload latest
echo "Upload latest-faststart"
podman push localhost/gvenzl/oracle-free:latest-faststart          docker.io/gvenzl/oracle-free:latest-faststart
echo "Upload latest"
podman push localhost/gvenzl/oracle-free:latest                    docker.io/gvenzl/oracle-free:latest
