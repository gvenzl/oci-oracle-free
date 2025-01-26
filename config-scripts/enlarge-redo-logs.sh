#!/bin/bash
#
# Since: December, 2024
# Author: gvenzl
# Name: enlarge-redo-logs.sh
# Description: A script to enlarge the REDO log journal files.
#
# Parameters:
# REDO_SIZE_MB: The size of the new REDO log files in MB (default: 100 MB).
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

# Size for REDO logs in MB (default 100MB)
REDO_SIZE_MB=${1:-100}

echo "CONFIGURATION: Enlarging REDO log files to ${REDO_SIZE_MB}MB each."

sqlplus -s / as sysdba << EOF

   -- Exit on any error
   WHENEVER SQLERROR EXIT SQL.SQLCODE

   -- Remove original redo logs and create new ones
   ALTER DATABASE ADD LOGFILE GROUP 4 ('${ORACLE_BASE}/oradata/${ORACLE_SID}/redo04.log') SIZE ${REDO_SIZE_MB}M;
   ALTER DATABASE ADD LOGFILE GROUP 5 ('${ORACLE_BASE}/oradata/${ORACLE_SID}/redo05.log') SIZE ${REDO_SIZE_MB}M;
   ALTER SYSTEM SWITCH LOGFILE;
   ALTER SYSTEM SWITCH LOGFILE;
   ALTER SYSTEM CHECKPOINT;
   ALTER DATABASE DROP LOGFILE GROUP 1;
   ALTER DATABASE DROP LOGFILE GROUP 2;
   ALTER DATABASE ADD LOGFILE GROUP 1 ('${ORACLE_BASE}/oradata/${ORACLE_SID}/redo01.log') SIZE ${REDO_SIZE_MB}M REUSE;
   ALTER DATABASE ADD LOGFILE GROUP 2 ('${ORACLE_BASE}/oradata/${ORACLE_SID}/redo02.log') SIZE ${REDO_SIZE_MB}M REUSE;
   ALTER SYSTEM SWITCH LOGFILE;
   ALTER SYSTEM SWITCH LOGFILE;
   ALTER SYSTEM CHECKPOINT;
   ALTER DATABASE DROP LOGFILE GROUP 4;
   HOST rm "${ORACLE_BASE}"/oradata/"${ORACLE_SID}"/redo04.log
   ALTER DATABASE DROP LOGFILE GROUP 5;
   HOST rm "${ORACLE_BASE}"/oradata/"${ORACLE_SID}"/redo05.log

   exit;
EOF

echo "CONFIGURATION: REDO log files enlarged."
