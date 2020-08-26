#!/bin/bash
set -e

echo "Configuring Database..."

cat <<- EOF > ${ORACLE_BASE}/product/18c/dbhomeXE/dbs/initXE.ora
db_name='XE'
processes = 150
shared_pool_size = '1G'
audit_trail ='none'
db_block_size=8192
db_domain=''
diagnostic_dest='${ORACLE_BASE}/oradata/'
dispatchers='(PROTOCOL=TCP) (SERVICE=ORCLXDB)'
open_cursors=300
remote_login_passwordfile='EXCLUSIVE'
control_files = (${ORACLE_BASE}/oradata/XE/control)
compatible ='12.0.0.0.0'
EOF

mkdir -p ${ORACLE_BASE}/oradata

mkdir -p ${ORACLE_BASE}/oradata/XE/logs/
mkdir -p ${ORACLE_BASE}/oradata/XE/data/
mkdir -p $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/

chown -R oracle.oinstall ${ORACLE_BASE}/oradata

echo "Creating XE Database..."

runuser oracle -c "${ORACLE_HOME}/bin/sqlplus -F -L -S / as sysdba" << EOF

WHENEVER SQLERROR EXIT SQL.SQLCODE;

STARTUP NOMOUNT;

CREATE SPFILE FROM PFILE;

SHUTDOWN ABORT;

STARTUP NOMOUNT;

CREATE DATABASE XE
   USER SYS IDENTIFIED BY oracle
   USER SYSTEM IDENTIFIED BY oracle
   LOGFILE
      GROUP 1 ('${ORACLE_BASE}/oradata/XE/logs/redo.0.log', '${ORACLE_BASE}/oradata/XE/logs/redo.1.log') SIZE 8M BLOCKSIZE 512,
      GROUP 2 ('${ORACLE_BASE}/oradata/XE/logs/redo.2.log', '${ORACLE_BASE}/oradata/XE/logs/redo.3.log') SIZE 8M BLOCKSIZE 512,
      GROUP 3 ('${ORACLE_BASE}/oradata/XE/logs/redo.4.log', '${ORACLE_BASE}/oradata/XE/logs/redo.5.log') SIZE 8M BLOCKSIZE 512
   MAXLOGHISTORY 1
   MAXLOGFILES 16
   MAXLOGMEMBERS 3
   MAXDATAFILES 1024
   CHARACTER SET AL32UTF8
   NATIONAL CHARACTER SET AL16UTF16
   EXTENT MANAGEMENT LOCAL
   DATAFILE '${ORACLE_BASE}/oradata/XE/data/system01.dbf'
     SIZE 8M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   SYSAUX DATAFILE '${ORACLE_BASE}/oradata/XE/data/sysaux01.dbf'
     SIZE 8M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   DEFAULT TABLESPACE users
      DATAFILE '${ORACLE_BASE}/oradata/XE/data/users01.dbf'
      SIZE 8M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   DEFAULT TEMPORARY TABLESPACE tempts1
      TEMPFILE '${ORACLE_BASE}/oradata/XE/data/temp01.dbf'
      SIZE 8M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   UNDO TABLESPACE undotbs_configuring
      DATAFILE '${ORACLE_BASE}/oradata/XE/data/undotbs_configuring.dbf'
      SIZE 8M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED
   USER_DATA TABLESPACE usertbs
      DATAFILE '${ORACLE_BASE}/oradata/XE/data/usertbs01.dbf'
      SIZE 8M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

spool /dev/null

@?/rdbms/admin/catalog.sql

@?/rdbms/admin/catproc.sql

@?/sqlplus/admin/pupbld.sql

spool off;

CREATE UNDO TABLESPACE undotbs1
      DATAFILE '/opt/oracle/oradata/XE/data/undotbs01.dbf'
      SIZE 8M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

ALTER SYSTEM SET UNDO_TABLESPACE = undotbs1 SCOPE=BOTH;

DROP TABLESPACE undotbs_configuring INCLUDING CONTENTS AND DATAFILES;

SHUTDOWN ABORT;

EXIT;
EOF
