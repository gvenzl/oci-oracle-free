#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: healthcheck.sh
# Description: Checks the health of the database
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

# Check whether PDB is open
#  Either the PDB passed on as $ORACLE_DATABASE or the default "FREEPDB1"
DATABASE=${1:-${ORACLE_DATABASE:-FREEPDB1}}

db_status=$(sqlplus -s / << EOF
   set heading off;
   set pagesize 0;
   SELECT 'READY'
    FROM (
      SELECT name, open_mode
       FROM v\$pdbs
      UNION ALL
      SELECT name, open_mode
       FROM v\$database) dbs
     WHERE dbs.name = '${DATABASE}'
      AND dbs.open_mode = 'READ WRITE';
   exit;
EOF
)

if [ "${db_status}" == "READY" ]; then
   exit 0;
else
   exit 1;
fi;
