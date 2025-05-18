#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: healthcheck.sh
# Description: Checks the health of the database
#              Parameter 1: the CDB name or PDB name(s) to check for
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
DATABASES=${1:-${ORACLE_DATABASE:-FREEPDB1}}
# Make the variable uppercase and use sed to add ' around each database name
DATABASES=$(echo "${DATABASES^^}" | sed "s/[^,]\+/'&'/g")

# This statement retrieves information about all the PDBs and container database that are
# listed in the name IN () list. The IN list values are constructed in the bash
# environment variable, making sure they are all upper case and enclosed with ''.
# The statement checks for each database returned whether the `open_mode` is 'READ WRITE'
# and if so, returns READY, otherwise, 'NOT READY'. The `DISTINCT` function is used to
# return only 1 entry for READY. When all PDBs provided by the parameter are in
# 'READ WRITE' mode, the statement returns a simple 'READY', otherwise a mix of 'READY'
# and 'NOT READY'. For the healthcheck it is only important to know whether all databases
# listed in the parameter are open for 'READ WRITE' mode, aka, 'READY', other states mean
# something is wrong and the user needs to check which of the many error conditions has
# been encountered.
# The UNION ALL to the v\$database view is there so that the healtcheck can also be used
# to just check on the CDBs status, ignoring all PDBs. This is useful if users want to
# create their own PDBs, etc. and do not care about the existing default one.

db_status=$(sqlplus -s / << EOF
   set heading off;
   set pagesize 0;
   SELECT distinct
     CASE dbs.open_mode
       WHEN 'READ WRITE' THEN 'READY'
       ELSE                   'NOT READY'
     END AS status
    FROM (
      SELECT name, open_mode
       FROM v\$pdbs
      UNION ALL
      SELECT name, open_mode
       FROM v\$database) dbs
     WHERE dbs.name IN (${DATABASES});
   exit;
EOF
)

if [ "${db_status}" == "READY" ]; then
   exit 0;
else
   exit 1;
fi;
