#!/bin/bash
# Only download the OracleDB RPM if it's not there
# It's possible that this was injected as part of the docker build
if [ ! -f ${ORACLE_XE_RPM} ]; then
  curl -sSfL ${ORACLE_XE_RPM_URL} -o ${ORACLE_XE_RPM} \
    || exit 1
fi

yum install -d1 -q -y \
  bc compat-libcap1 compat-libstdc++-33 libaio libstdc++ \
  pam procps psmisc sysstat utillinux

if [ $? -gt 1 ]; then
  exit 1
fi

rpm -Uv --nodeps ${ORACLE_XE_RPM}

if [ $? -gt 1 ]; then
  exit 1
fi

# Fix pam
sed -i -r 's/^(session\s+required\s+pam_limits.so)/#\1/' /etc/pam.d/*

# Remove unused templates & other systems
rm -rf /opt/oracle/product/18c/dbhomeXE/OPatch
rm -rf /opt/oracle/product/18c/dbhomeXE/QOPatch
rm -rf /opt/oracle/product/18c/dbhomeXE/R
rm -rf /opt/oracle/product/18c/dbhomeXE/assistants
rm -rf /opt/oracle/product/18c/dbhomeXE/crs
rm -rf /opt/oracle/product/18c/dbhomeXE/ctx
rm -rf /opt/oracle/product/18c/dbhomeXE/cv
rm -rf /opt/oracle/product/18c/dbhomeXE/deinstall
rm -rf /opt/oracle/product/18c/dbhomeXE/demo
rm -rf /opt/oracle/product/18c/dbhomeXE/dmu
rm -rf /opt/oracle/product/18c/dbhomeXE/install
rm -rf /opt/oracle/product/18c/dbhomeXE/installclient
rm -rf /opt/oracle/product/18c/dbhomeXE/instantclient
rm -rf /opt/oracle/product/18c/dbhomeXE/inventory
rm -rf /opt/oracle/product/18c/dbhomeXE/javavm
rm -rf /opt/oracle/product/18c/dbhomeXE/jdbc
rm -rf /opt/oracle/product/18c/dbhomeXE/jdk
rm -rf /opt/oracle/product/18c/dbhomeXE/jlib
rm -rf /opt/oracle/product/18c/dbhomeXE/md
rm -rf /opt/oracle/product/18c/dbhomeXE/odbc
rm -rf /opt/oracle/product/18c/dbhomeXE/ord
rm -rf /opt/oracle/product/18c/dbhomeXE/oui
rm -rf /opt/oracle/product/18c/dbhomeXE/perl
rm -rf /opt/oracle/product/18c/dbhomeXE/sdk
rm -rf /opt/oracle/product/18c/dbhomeXE/xdk

rm -rf /opt/oracle/product/18c/dbhomeXE/bin/*.exe

rm -rf /opt/oracle/product/18c/dbhomeXE/bin/afdboot
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/ctxkbtc
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/ctxload
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/ctxlc
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/diagsetup
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/diskmon.bin
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/dgmgrl
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/imp
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/ldap*
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/lxinst
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/orion
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/proc
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/procob
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/rman
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/wrap
rm -rf /opt/oracle/product/18c/dbhomeXE/bin/wrc

rm -rf /opt/oracle/product/18c/dbhomeXE/lib/clntsh.map
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libccme_*.so
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libcrs18.so
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libmkl_avx*.so
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libmkl_gf_*.so
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libmkl_intel_*.so
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libmkl_vml_*.so
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libopc.so
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libosbws.so
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libra.so
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/libshpkavx*.so

rm -rf /opt/oracle/product/18c/dbhomeXE/lib/*_ppc64.*
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/*_sparc64.*
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/*_windows64.*
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/ra_*.zip
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/*_installer.zip

rm -rf /opt/oracle/product/18c/dbhomeXE/lib/*.jar
rm -rf /opt/oracle/product/18c/dbhomeXE/lib/*.zip

# Cleanup yum
yum clean all
rm -rf /var/cache/yum
rm -rf /var/lib/rpm/
rm -rf /var/lib/yum/

# Cleanup logs
rm -rf /var/log/oracle-database-preinstall-18c
rm -rf /var/log/oracle-database-xe-18c
rm -rf /var/log/btmp
rm -rf /var/log/lastlog
rm -rf /var/log/sa
rm -rf /var/log/wtmp
rm -rf /var/log/tallylog
rm -rf /var/log/yum.log

# Cleanup Temporary files
rm -rf /tmp/*
