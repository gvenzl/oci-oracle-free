#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: all-build-tests.sh
# Description: Script for all build tests for Oracle DB Free
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

# In order of newest to latest
./build-image.sh "23.6"
./build-image.sh "23.5"
#./build-image.sh "23.4"
#./build-image.sh "23.3"
#./build-image.sh "23.2"
