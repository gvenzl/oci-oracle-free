#!/bin/bash
#
# Since: December, 2024
# Author: gvenzl
# Name: disable-recyclebin.sh
# Description: A script to disable the database recyclebin.
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

echo "CONFIGURATION: Disabling the database recyclebin."

sqlplus -s / as sysdba << EOF

   -- Exit on any error
   WHENEVER SQLERROR EXIT SQL.SQLCODE

   ALTER SYSTEM SET RECYCLEBIN=OFF CONTAINER=ALL SCOPE=SPFILE;
   SHUTDOWN IMMEDIATE;
   STARTUP;

   exit;
EOF

echo "CONFIGURATION: Database recyclebin disabled."
