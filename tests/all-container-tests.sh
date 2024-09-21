#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: all_container_tests.sh
# Description: Script for all run tests for Oracle DB Free
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

./test_container.sh "gvenzl/oracle-free:23.5-full-faststart-$getArch"
./test_container.sh "gvenzl/oracle-free:23.5-faststart-$getArch"
./test_container.sh "gvenzl/oracle-free:23.5-slim-faststart-$getArch"

./test_container.sh "gvenzl/oracle-free:23.5-full-$getArch"
./test_container.sh "gvenzl/oracle-free:23.5-$getArch"
./test_container.sh "gvenzl/oracle-free:23.5-slim-$getArch"

#./test_container.sh "gvenzl/oracle-free:23.4-full-faststart"
#./test_container.sh "gvenzl/oracle-free:23.4-faststart"
#./test_container.sh "gvenzl/oracle-free:23.4-slim-faststart"

#./test_container.sh "gvenzl/oracle-free:23.4-full"
#./test_container.sh "gvenzl/oracle-free:23.4"
#./test_container.sh "gvenzl/oracle-free:23.4-slim"

#./test_container.sh "gvenzl/oracle-free:23.3-full-faststart"
#./test_container.sh "gvenzl/oracle-free:23.3-faststart"
#./test_container.sh "gvenzl/oracle-free:23.3-slim-faststart"

#./test_container.sh "gvenzl/oracle-free:23.3-full"
#./test_container.sh "gvenzl/oracle-free:23.3"
#./test_container.sh "gvenzl/oracle-free:23.3-slim"

#./test_container.sh "gvenzl/oracle-free:23.2-full-faststart"
#./test_container.sh "gvenzl/oracle-free:23.2-faststart"
#./test_container.sh "gvenzl/oracle-free:23.2-slim-faststart"

#./test_container.sh "gvenzl/oracle-free:23.2-full"
#./test_container.sh "gvenzl/oracle-free:23.2"
#./test_container.sh "gvenzl/oracle-free:23.2-slim"
