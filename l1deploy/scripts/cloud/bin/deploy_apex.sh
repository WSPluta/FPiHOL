#!/bin/sh
INSTALL_HOME=$(dirname $0 | xargs -I {} realpath {} | rev | cut -d '/' -f 2- | rev)
cd $INSTALL_HOME

cd application

SLOG=$INSTALL_HOME/log/sqlcl.log
LOG=$INSTALL_HOME/log/install.log

TNS_PROFILE=""
DB_SCHEMA=""
APEX_WORKSPACE=""
APEX_APP_FILE=""
APEX_APP_ALIAS=""
ADMIN_PASSWORD=""

print_usage()
{
    echo ""
    echo " deploy_apex.sh [-d WALLET_DIR] [-t TNS_PROFILE] [-a ADMIN_PASSWORD] [-s DB_SCHEMA] [-w APEX_WORKSPACE] [-f APEX_APP_FILE] [-u APEX_APP_ALIAS] [-h]"
    echo ""
    echo " -d: Wallet Directory"
    echo " -t: TNS profile used to connect to database"
    echo " -a: ADMIN Password (for ADMIN User)"
    echo " -s: Database Schema (to set the schema of the APEX applications)"
    echo " -w: APEX Workspace (to install APEX applications)"
    echo " -f: APEX application file (to install)"
    echo " -u: APEX application alias (used in the URL)"
    echo " -h: this help"
    echo ""
}

while getopts 'd:t:a:s:w:f:u:h' flag; do
  case "${flag}" in
    d) export TNS_ADMIN="$(realpath ${OPTARG})" ;;
    t) TNS_PROFILE="${OPTARG}" ;;
    a) ADMIN_PASSWORD="${OPTARG}" ;;
    s) DB_SCHEMA="${OPTARG}" ;;
    w) APEX_WORKSPACE="${OPTARG}" ;;
    u) APEX_APP_ALIAS="${OPTARG}" ;;
    f) APEX_APP_FILE="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [ "$ADMIN_PASSWORD" = "" ]
then
    stty -echo
    printf "ADMIN Password: "
    read ADMIN_PASSWORD
    stty echo
    printf "\n"
fi
if [ -z "$TNS_ADMIN" ]
then
    read -p "Wallet Directory: " TNS_ADMIN
    export TNS_ADMIN="$(realpath ${TNS_ADMIN})"
fi
if [ -z "$TNS_PROFILE" ]
then
    read -p "TNS Profile: " TNS_PROFILE
fi
if [ -z "$DB_SCHEMA" ]
then
    read -p "Database Schema: " DB_SCHEMA
fi
if [ -z "$APEX_WORKSPACE" ]
then
    read -p "APEX Workspace: " APEX_WORKSPACE
fi
if [ -z "$APEX_APP_FILE" ]
then
    read -p "APEX application file: " APEX_APP_FILE
fi
if [ -z "$APEX_APP_ALIAS" ]
then
    read -p "APEX application alias: " APEX_APP_ALIAS
fi

# Run Commands
unzip -o f${APEX_APP_FILE}.zip

# Install APEX apps
echo "set lines 199 trimsp on pages 0 feed on
-- spool $SLOG
connect ADMIN/\"${ADMIN_PASSWORD}\"@${TNS_PROFILE};
declare
  v_workspace_id NUMBER;
begin
  select workspace_id into v_workspace_id
  from apex_workspaces where workspace = '${APEX_WORKSPACE}';
  apex_application_install.set_workspace_id (v_workspace_id);
  apex_util.set_security_group_id
    (p_security_group_id => apex_application_install.get_workspace_id);
  apex_application_install.set_schema('${DB_SCHEMA}');
  apex_application_install.generate_application_id;
  apex_application_install.generate_offset;
  apex_application_install.set_application_alias('${APEX_APP_ALIAS}');
end;
/ 
@f${APEX_APP_FILE}.sql
" | $INSTALL_HOME/sqlcl/bin/sql /NOLOG
