#!/bin/bash
# Since: April, 2023
# Author: gvenzl
# Name: test_container_2330.sh
# Description: Run container test scripts for Oracle DB Free 23.3
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

source ./functions.sh

#######################
###### 23 TESTS #######
#######################

#######################
##### Image tests #####
#######################

runContainerTest "23.4 FULL image" "234-full" "gvenzl/oracle-free:23.4-full"
runContainerTest "23.3 FULL image" "233-full" "gvenzl/oracle-free:23.3-full"
runContainerTest "23.2 FULL image" "232-full" "gvenzl/oracle-free:23.2-full"
runContainerTest "23 FULL image" "23-full" "gvenzl/oracle-free:23-full"
runContainerTest "FULL image" "full" "gvenzl/oracle-free:full"

runContainerTest "23.4 FULL FASTSTART image" "234-full-faststart" "gvenzl/oracle-free:23.4-full-faststart"
runContainerTest "23.3 FULL FASTSTART image" "233-full-faststart" "gvenzl/oracle-free:23.3-full-faststart"
runContainerTest "23.2 FULL FASTSTART image" "232-full-faststart" "gvenzl/oracle-free:23.2-full-faststart"
runContainerTest "23 FULL FASTSTART image" "23-full-faststart" "gvenzl/oracle-free:23-full-faststart"
runContainerTest "FULL FASTSTART image" "full-faststart" "gvenzl/oracle-free:full-faststart"

runContainerTest "23.4 REGULAR image" "234" "gvenzl/oracle-free:23.4"
runContainerTest "23.3 REGULAR image" "233" "gvenzl/oracle-free:23.3"
runContainerTest "23.2 REGULAR image" "232" "gvenzl/oracle-free:23.2"
runContainerTest "23 REGULAR image" "23" "gvenzl/oracle-free:23"
runContainerTest "REGULAR image" "latest" "gvenzl/oracle-free"

runContainerTest "23.4 REGULAR FASTSTART image" "234-faststart" "gvenzl/oracle-free:23.4-faststart"
runContainerTest "23.3 REGULAR FASTSTART image" "233-faststart" "gvenzl/oracle-free:23.3-faststart"
runContainerTest "23.2 REGULAR FASTSTART image" "232-faststart" "gvenzl/oracle-free:23.2-faststart"
runContainerTest "23 REGULAR FASTSTART image" "23-faststart" "gvenzl/oracle-free:23-faststart"
runContainerTest "REGULAR FASTSTART image" "latest-faststart" "gvenzl/oracle-free:latest-faststart"

runContainerTest "23.4 SLIM image" "234-slim" "gvenzl/oracle-free:23.4-slim"
runContainerTest "23.3 SLIM image" "233-slim" "gvenzl/oracle-free:23.3-slim"
runContainerTest "23.2 SLIM image" "232-slim" "gvenzl/oracle-free:23.2-slim"
runContainerTest "23 SLIM image" "23-slim" "gvenzl/oracle-free:23-slim"
runContainerTest "SLIM image" "slim" "gvenzl/oracle-free:slim"

runContainerTest "23.4 SLIM FASTSTART image" "234-slim-faststart" "gvenzl/oracle-free:23.4-slim-faststart"
runContainerTest "23.3 SLIM FASTSTART image" "233-slim-faststart" "gvenzl/oracle-free:23.3-slim-faststart"
runContainerTest "23.2 SLIM FASTSTART image" "232-slim-faststart" "gvenzl/oracle-free:23.2-slim-faststart"
runContainerTest "23 SLIM FASTSTART image" "23-slim-faststart" "gvenzl/oracle-free:23-slim-faststart"
runContainerTest "SLIM FASTSTART image" "slim-faststart" "gvenzl/oracle-free:slim-faststart"

#################################
##### Oracle password tests #####
#################################

# Provide different password
ORA_PWD="MyTestPassword"
ORA_PWD_CMD="-e ORACLE_PASSWORD=${ORA_PWD}"
# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="23-ora-pwd"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="ORACLE_PASSWORD"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="OK"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-free:full-faststart"

# Test password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s system/"${ORA_PWD}" <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset ORA_PWD_CMD
unset TEST_NAME

########################################
##### Oracle random password tests #####
########################################

# We want a random password for this test
ORA_PWD_CMD="-e ORACLE_RANDOM_PASSWORD=sure"
# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="23-rand-ora-pwd"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="ORACLE_RANDOM_PASSWORD"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="OK"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-free:latest-faststart"

# Let's get the password
rand_pwd=$(podman logs ${CONTAINER_NAME} | grep "ORACLE PASSWORD FOR SYS AND SYSTEM:" | awk '{ print $7 }')

# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s system/"${rand_pwd}"@//localhost/FREEPDB1 <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset ORA_PWD_CMD
unset TEST_NAME

#########################
##### App user test #####
#########################

# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="23-app-user"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="APP_USER & PASSWORD"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="Hi from App User"
# App user
APP_USER="test_app_user"
# App user password
APP_USER_PASSWORD="MyAppUserPassword"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-free:slim-faststart"

# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s "${APP_USER}"/"${APP_USER_PASSWORD}"@//localhost/FREEPDB1 <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset TEST_NAME
unset EXPECTED_RESULT
unset APP_USER
unset APP_USER_PASSWORD

######################################
##### Oracle Database (PDB) test #####
######################################

# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="23-oracle-db"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="23.4 ORACLE_DATABASE"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="Hi from your Oracle PDB"
# Oracle PDB (use mixed case deliberately)
ORACLE_DATABASE="gErAld_pDb"
# Oracle password
ORA_PWD="MyTestPassword"
ORA_PWD_CMD="-e ORACLE_PASSWORD=${ORA_PWD}"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-free:23.4-full-faststart"

# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s sys/"${ORA_PWD}"@//localhost/"${ORACLE_DATABASE}" as sysdba <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset TEST_NAME
unset EXPECTED_RESULT
unset ORACLE_DATABASE
unset ORA_PWD
unset ORA_PWD_CMD

#################################################
##### Oracle Database (PDB) + APP_USER test #####
#################################################

# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="23-oracle-db"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="23.3 ORACLE_DATABASE & APP_USER"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="Hi from your Oracle PDB"
# App user
APP_USER="other_app_user"
# App user password
APP_USER_PASSWORD="ThatAppUserPassword1"
# Oracle PDB
ORACLE_DATABASE="regression_tests"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-free:23.3-faststart"

# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s "${APP_USER}"/"${APP_USER_PASSWORD}"@//localhost/"${ORACLE_DATABASE}" <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset TEST_NAME
unset EXPECTED_RESULT
unset APP_USER
unset APP_USER_PASSWORD
unset ORACLE_DATABASE

#################################################
##### Oracle Database PDBs + APP_USER test ######
#################################################

# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="23-oracle-db-pdbs"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="23.4 MULTIPLE PDBs & APP_USER"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="Hi from your Oracle PDB"
# App user
APP_USER="pdb_app_user"
# App user password
APP_USER_PASSWORD="AnotherAppUserPassword1"
# Oracle PDB
ORACLE_DATABASE="test_pdb1,TEST_PDB2,PDB3"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-free:23.4-slim-faststart"

##################
# PDB: test_pdb1 #
##################
# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s "${APP_USER}"/"${APP_USER_PASSWORD}"@//localhost/test_pdb1 <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

##################
# PDB: test_pdb2 #
##################
# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s "${APP_USER}"/"${APP_USER_PASSWORD}"@//localhost/test_pdb2 <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

##################
# PDB: pdb3      #
##################
# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s "${APP_USER}"/"${APP_USER_PASSWORD}"@//localhost/pdb3 <<EOF
   set heading off;
   set echo off;
   set pagesize 0;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset TEST_NAME
unset EXPECTED_RESULT
unset APP_USER
unset APP_USER_PASSWORD
unset ORACLE_DATABASE

################################################
##### Test for timezone file failure (#23) #####
################################################

# Tell test method not to tear down container
NO_TEAR_DOWN="true"
# Let's keep the container name in a var to keep it simple
CONTAINER_NAME="timezone-test"
# Let's keep the test name in a var to keep it simple too
TEST_NAME="TIMEZONE TEST"
# This is what we want to have back from the SQL statement
EXPECTED_RESULT="Hi from your Oracle PDB"
# App user
APP_USER="my_test_user"
# App user password
APP_USER_PASSWORD="ThatAppUserPassword1"
# Oracle PDB
ORACLE_DATABASE="timezone_pdb"

# Spin up container
runContainerTest "${TEST_NAME}" "${CONTAINER_NAME}" "gvenzl/oracle-free:slim-faststart"

# Test the random password, if it works we will get "OK" back from the SQL statement
result=$(podman exec -i ${CONTAINER_NAME} sqlplus -s "${APP_USER}"/"${APP_USER_PASSWORD}"@//localhost/"${ORACLE_DATABASE}" <<EOF
   whenever sqlerror exit sql.sqlcode;
   set heading off;
   set echo off;
   set feedback off;
   set pagesize 0;
   CREATE TABLE FOO (id INT);
   INSERT INTO FOO VALUES (1);

   -- This should NOT throw:
   -- ORA-04088: error during execution of trigger 'SYS.DELETE_ENTRIES'
   -- ORA-00604: Error occurred at recursive SQL level 1. Check subsequent errors.
   -- ORA-01804: failure to initialize timezone information
   DROP TABLE FOO;
   SELECT '${EXPECTED_RESULT}' FROM dual;
   exit;
EOF
)

# See whether we got "OK" back from our test
if [ "${result}" == "${EXPECTED_RESULT}" ]; then
  echo "TEST ${TEST_NAME}: OK";
  echo "";
else
  echo "TEST ${TEST_NAME}: FAILED!";
  exit 1;
fi;

# Tear down the container, no longer needed
tear_down_container "${CONTAINER_NAME}"

# Clean up environment variables, all tests should remain self-contained
unset CONTAINER_NAME
unset NO_TEAR_DOWN
unset TEST_NAME
unset EXPECTED_RESULT
unset APP_USER
unset APP_USER_PASSWORD
unset ORACLE_DATABASE
