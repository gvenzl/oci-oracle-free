#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: tag_images_23.sh
# Description: Tag all 23 images
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

# Tag 23.5 images
podman tag gvenzl/oracle-free:23.5-full           gvenzl/oracle-free:23-full
podman tag gvenzl/oracle-free:23.5-full           gvenzl/oracle-free:full
podman tag gvenzl/oracle-free:23.5-full-faststart gvenzl/oracle-free:23-full-faststart
podman tag gvenzl/oracle-free:23.5-full-faststart gvenzl/oracle-free:full-faststart

podman tag gvenzl/oracle-free:23.5                gvenzl/oracle-free:23
podman tag gvenzl/oracle-free:23.5-faststart      gvenzl/oracle-free:23-faststart

podman tag gvenzl/oracle-free:23.5-slim           gvenzl/oracle-free:23-slim
podman tag gvenzl/oracle-free:23.5-slim           gvenzl/oracle-free:slim
podman tag gvenzl/oracle-free:23.5-slim-faststart gvenzl/oracle-free:23-slim-faststart
podman tag gvenzl/oracle-free:23.5-slim-faststart gvenzl/oracle-free:slim-faststart
