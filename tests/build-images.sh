#!/bin/bash
# Since: May, 2024
# Author: gvenzl
# Name: build-images.sh
# Description: Build test scripts for Oracle DB Free $VERSION
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

CURRENT_DIR=${PWD}
VERSION=${1}

cd ../

echo "TEST: Building ${VERSION} FULL image"
./buildContainerImage.sh -i -v ${VERSION} -f
echo "DONE: Building ${VERSION} FULL image"

echo "TEST: Building ${VERSION} FULL FASTSTART image"
./buildContainerImage.sh -i -v ${VERSION} -f -x
echo "DONE: Building ${VERSION} FULL FASTSTART image"

echo "TEST: Building ${VERSION} REGULAR image"
./buildContainerImage.sh -i -v ${VERSION}
echo "DONE: Building ${VERSION} REGULAR image"

echo "TEST: Building ${VERSION} REGULAR FASTSTART image"
./buildContainerImage.sh -i -v ${VERSION} -x
echo "DONE: Building ${VERSION} REGULAR FASTSTART image"

echo "TEST: Building ${VERSION} SLIM image"
./buildContainerImage.sh -i -v ${VERSION} -s
echo "DONE: Building ${VERSION} SLIM image"

echo "TEST: Building ${VERSION} SLIM FASTSTART image"
./buildContainerImage.sh -i -v ${VERSION} -s -x
echo "DONE: Building ${VERSION} SLIM FASTSTART image"

cd "${CURRENT_DIR}"
