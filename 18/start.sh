#!/bin/bash
function _int() {
  echo "Stopping container."
  echo "SIGINT received, shutting down database!"
  runuser oracle -s /bin/bash -c "/shutdown.sh immediate"
}

function _term() {
  echo "Stopping container."
  echo "SIGTERM received, shutting down database!"
  runuser oracle -s /bin/bash -c "/shutdown.sh immediate"
}

function _kill() {
  echo "SIGKILL received, shutting down database!"
  runuser oracle -s /bin/bash -c "/shutdown.sh abort"
}

trap _int SIGINT
trap _term SIGTERM
trap _kill SIGKILL

if [ ! -d "/opt/oracle/oradata/XE" ]; then
  tar xf /oradata.tgz -C / > /dev/null 2>&1
fi

# Start database
echo "Starting Oracle Net Listener."
runuser oracle -c "${ORACLE_HOME}/bin/lsnrctl start LISTENER" > /dev/null 2>&1

RETVAL=$?
if [ $RETVAL -eq 0 ]
then
    echo "Oracle Net Listener started."
fi

echo "Starting Oracle Database instance $ORACLE_SID."
runuser oracle -c "${ORACLE_HOME}/bin/sqlplus / as sysdba" << EOF > /dev/null 2>&1
startup
alter pluggable database all open
exit;
EOF

RETVAL1=$?
if [ $RETVAL1 -eq 0 ]
then
    echo "Oracle Database instance $ORACLE_SID started."
fi

tail -f ${ORACLE_BASE}/oradata/diag/rdbms/*/*/trace/alert*.log &
childPID=$!
wait ${childPID}

# TODO workaround
tail -f /dev/null
