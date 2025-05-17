#!/bin/bash
#
# Since: May, 2025
# Author: gvenzl
# Name: change-filesystemio-options.sh
# Description: A script to change the default filesystemio_options parameter
#
# Parameters:
# OPTIONS: The value to set FILESYSTEMIO_OPTIONS to.
#
# Copyright 2025 Gerald Venzl
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

# The option(s) to set
OPTIONS=${1:-"SETALL"}

# Enable case-insensitive matching
shopt -s nocasematch

case "${OPTIONS}" in
  ASYNCH | DIRECTIO | SETALL | NONE)
    # Valid values, do nothing
    ;;
  *)
    # Invalid value for FILESYSTEMIO_OPTIONS, return 1 and abort script
    echo "CONFIGURATION: ERROR: The parameter value for FILESYSTEMIO_OPTION does not exist: ${OPTIONS}"
    return 1;
    ;;
esac

# Disable case-insensitive matching
shopt -u nocasematch

echo "CONFIGURATION: Changing parameter FILESYSTEMIO_OPTIONS=${OPTIONS}"

sqlplus -s / as sysdba << EOF

   -- Exit on any error
   WHENEVER SQLERROR EXIT SQL.SQLCODE

   ALTER SYSTEM SET FILESYSTEMIO_OPTIONS=${OPTIONS} SCOPE=SPFILE;
   SHUTDOWN IMMEDIATE;
   STARTUP;

   exit;
EOF

echo "CONFIGURATION: Parameter FILESYSTEMIO_OPTIONS changed."
