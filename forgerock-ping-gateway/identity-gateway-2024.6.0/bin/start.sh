#!/bin/sh
#
# Copyright 2019-2021 ForgeRock AS. All Rights Reserved
#
# Use of this code requires a commercial software license with ForgeRock AS.
# or with one of its affiliates. All use shall be exclusively subject
# to such license between the licensee and ForgeRock AS.

# ------------------------------------------------------------------------------
# Environment Variable Prerequisites
# ------------------------------------------------------------------------------
#   IG_OPTS         (Optional) Java runtime options used when the "start"
#                   command is executed.
#                   Include here and not in JAVA_OPTS all options, that should
#                   only be used by IG itself, not by the stop process,
#                   like the JVM memory sizing options.
#
#   JAVA_OPTS       (Optional) Java runtime options used when any command
#                   is executed.
#                   Include here and not in IG_OPTS all options, that
#                   should be used by IG and also by the stop process.
#                   Most options should go into IG_OPTS.
# ------------------------------------------------------------------------------

if [ $# -gt 1 ]; then
  echo "Expecting only the instance directory as argument"
  exit 1
elif [ $# -eq 0 ]; then
  INSTANCE_DIR="${HOME}/.openig"
  echo "No instance dir provided, using ${INSTANCE_DIR}"
else
  # Verifying if path exists then it must be a directory
  if [ -e "${1}" ] && [ ! -d "${1}" ]; then
    echo "Expecting a directory as an argument"
    exit 1
  fi
  INSTANCE_DIR=${1}
  shift
fi

env_file="${INSTANCE_DIR}/bin/env.sh"
if [ -r "${env_file}" ]; then
  _runenvstatus=0
  echo "Using environment file located at: $(cd "$(dirname "$env_file")"; pwd)/$(basename "$env_file")"
 . "${env_file}" || _runenvstatus=$?
 if [ $_runenvstatus != 0 ]; then
     echo "An error occurred when loading env file"
     exit $_runenvstatus
 fi
fi

if [ -z "${JAVA_HOME}" ] ; then
  _java=`which java`
else
  _java="${JAVA_HOME}/bin/java"
fi

if [ ! -x "${_java}" ] ; then
  echo "No java executable found in the JAVA_HOME or through the PATH environment variable."
  exit 1
fi

# -Dnewrelic.config.token_timeout=5 -Dnewrelic.config.segment_timeout=15 
JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=localhost:5005 -javaagent:/Users/jkeller/nr/agents/newrelic_snapshot_build/newrelic.jar -Dnewrelic.config.log_file_name=frig-server.log -Dnewrelic.config.app_name=frig-server-3 -Dnewrelic.debug=true -Dnewrelic.token_debug=true -Dnewrelic.config.token_timeout=10 -Dnewrelic.config.segment_timeout=20"
CLASSES_DIR=$(dirname $0)/..
CLASSPATH=${CLASSES_DIR}/classes:${CLASSES_DIR}/lib/*:\"${INSTANCE_DIR}\"/extra/*
eval exec \"${_java}\" -classpath "${CLASSPATH}" "${JAVA_OPTS}" "${IG_OPTS}" org.forgerock.openig.launcher.Main \"${INSTANCE_DIR}\" $@
