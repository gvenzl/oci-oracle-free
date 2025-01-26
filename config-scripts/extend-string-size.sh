#!/bin/bash
#
# Since: December, 2024
# Author: gvenzl
# Name: extend-string-size.sh
# Description: A script to extend the MAX_STRING_SIZE for all databases.
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

echo "CONFIGURATION: Configuring database instance for MAX_STRING_SIZE=EXTENDED."

if ! PERL_LOC="$(type -p "${ORACLE_HOME}/perl/bin/perl")" || [[ -z "${PERL_LOC}" ]]; then
  sudo microdnf install perl
  PERL_LOC="/usr/bin/perl"
else
  PERL_LOC="${ORACLE_HOME}/perl/bin/perl"
fi;

sqlplus -s / as sysdba <<EOF
   -- Exit on any errors
   WHENEVER SQLERROR EXIT SQL.SQLCODE

   ALTER SYSTEM SET MAX_STRING_SIZE=EXTENDED SCOPE=SPFILE;

   SHUTDOWN IMMEDIATE;
   STARTUP UPGRADE;

   exit;
EOF

cd "${ORACLE_HOME}/rdbms/admin"
mkdir /tmp/ora-string-size

"${PERL_LOC}" "${ORACLE_HOME}/rdbms/admin/catcon.pl" \
  --force_pdb_mode 'UPGRADE' \
  -d "${ORACLE_HOME}/rdbms/admin" -l '/tmp/ora-string-size' \
  -b utl32k_cdb_pdbs_output utl32k.sql

sqlplus -s / as sysdba <<EOF
   -- Exit on any errors
   WHENEVER SQLERROR EXIT SQL.SQLCODE

   SHUTDOWN IMMEDIATE;
   STARTUP;

   exit;
EOF

"${PERL_LOC}" "${ORACLE_HOME}/rdbms/admin/catcon.pl" \
  --force_pdb_mode 'READ WRITE'\
  -d "${ORACLE_HOME}/rdbms/admin" -l '/tmp/ora-string-size' \
  -b utlrp_cdb_pdbs_output utlrp.sql

rm -rf /tmp/ora-string-size

if [[ "$PERL_LOC" == "/usr/bin/perl" ]]; then
  sudo microdnf remove redhat-rpm-config platform-python* python* systemtap-sdt-devel perl*
fi;

unset PERL_LOC

echo "CONFIGURATION: Database instance is now configured for MAX_STRING_SIZE=EXTENDED."
