#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: upload_images_github.sh
# Description: Upload images to the GitHub registry
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
echo "Login to GitHub Container Registry:"
podman login ghcr.io

# Start from old to new, as packages will be sorted by last update/upload time descending

# Upload images

# Upload 23 FULL images
echo "Upload 23.4-full-faststart"
podman push localhost/gvenzl/oracle-free:23.4-full-faststart     ghcr.io/gvenzl/oracle-free:23.4-full-faststart
echo "Upload 23.3-full-faststart"
podman push localhost/gvenzl/oracle-free:23.3-full-faststart     ghcr.io/gvenzl/oracle-free:23.3-full-faststart
echo "Upload 23.2-full-faststart"
podman push localhost/gvenzl/oracle-free:23.2-full-faststart     ghcr.io/gvenzl/oracle-free:23.2-full-faststart
echo "Upload 23-full-faststart"
podman push localhost/gvenzl/oracle-free:23-full-faststart       ghcr.io/gvenzl/oracle-free:23-full-faststart
echo "Upload full-faststart"
podman push localhost/gvenzl/oracle-free:full-faststart          ghcr.io/gvenzl/oracle-free:full-faststart

echo "Upload 23.4-full"
podman push localhost/gvenzl/oracle-free:23.4-full               ghcr.io/gvenzl/oracle-free:23.4-full
echo "Upload 23.3-full"
podman push localhost/gvenzl/oracle-free:23.3-full               ghcr.io/gvenzl/oracle-free:23.3-full
echo "Upload 23.2-full"
podman push localhost/gvenzl/oracle-free:23.2-full               ghcr.io/gvenzl/oracle-free:23.2-full
echo "Upload 23-full"
podman push localhost/gvenzl/oracle-free:23-full                 ghcr.io/gvenzl/oracle-free:23-full
echo "Upload full"
podman push localhost/gvenzl/oracle-free:full                    ghcr.io/gvenzl/oracle-free:full


#Upload 23 images
echo "Upload 23.4-faststart"
podman push localhost/gvenzl/oracle-free:23.4-faststart          ghcr.io/gvenzl/oracle-free:23.4-faststart
echo "Upload 23.3-faststart"
podman push localhost/gvenzl/oracle-free:23.3-faststart          ghcr.io/gvenzl/oracle-free:23.3-faststart
echo "Upload 23.2-faststart"
podman push localhost/gvenzl/oracle-free:23.2-faststart          ghcr.io/gvenzl/oracle-free:23.2-faststart
echo "Upload 23-faststart"
podman push localhost/gvenzl/oracle-free:23-faststart            ghcr.io/gvenzl/oracle-free:23-faststart

echo "Upload 23.4"
podman push localhost/gvenzl/oracle-free:23.4                    ghcr.io/gvenzl/oracle-free:23.4
echo "Upload 23.3"
podman push localhost/gvenzl/oracle-free:23.3                    ghcr.io/gvenzl/oracle-free:23.3
echo "Upload 23.2"
podman push localhost/gvenzl/oracle-free:23.2                    ghcr.io/gvenzl/oracle-free:23.2
echo "Upload 23"
podman push localhost/gvenzl/oracle-free:23                      ghcr.io/gvenzl/oracle-free:23


# Upload 23 SLIM images
echo "Upload 23.4-slim-faststart"
podman push localhost/gvenzl/oracle-free:23.4-slim-faststart     ghcr.io/gvenzl/oracle-free:23.4-slim-faststart
echo "Upload 23.3-slim-faststart"
podman push localhost/gvenzl/oracle-free:23.3-slim-faststart     ghcr.io/gvenzl/oracle-free:23.3-slim-faststart
echo "Upload 23.2-slim-faststart"
podman push localhost/gvenzl/oracle-free:23.2-slim-faststart     ghcr.io/gvenzl/oracle-free:23.2-slim-faststart
echo "Upload 23-slim-faststart"
podman push localhost/gvenzl/oracle-free:23-slim-faststart       ghcr.io/gvenzl/oracle-free:23-slim-faststart
echo "Upload slim-faststart"
podman push localhost/gvenzl/oracle-free:slim-faststart          ghcr.io/gvenzl/oracle-free:slim-faststart

echo "Upload 23.4-slim"
podman push localhost/gvenzl/oracle-free:23.3-slim               ghcr.io/gvenzl/oracle-free:23.4-slim
echo "Upload 23.3-slim"
podman push localhost/gvenzl/oracle-free:23.3-slim               ghcr.io/gvenzl/oracle-free:23.3-slim
echo "Upload 23.2-slim"
podman push localhost/gvenzl/oracle-free:23.2-slim               ghcr.io/gvenzl/oracle-free:23.2-slim
echo "Upload 23-slim"
podman push localhost/gvenzl/oracle-free:23-slim                 ghcr.io/gvenzl/oracle-free:23-slim
echo "Upload slim"
podman push localhost/gvenzl/oracle-free:slim                    ghcr.io/gvenzl/oracle-free:slim



# Upload latest
echo "Upload latest-faststart"
podman push localhost/gvenzl/oracle-free:latest-faststart        ghcr.io/gvenzl/oracle-free:latest-faststart
echo "Upload latest"
podman push localhost/gvenzl/oracle-free:latest                  ghcr.io/gvenzl/oracle-free:latest
