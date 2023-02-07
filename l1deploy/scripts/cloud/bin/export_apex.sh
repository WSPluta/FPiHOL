#!/bin/sh
INSTALL_HOME=$(dirname $0 | xargs -I {} realpath {} | rev | cut -d '/' -f 2- | rev)
cd $INSTALL_HOME

cd application

SLOG=$INSTALL_HOME/log/sqlcl.log
LOG=$INSTALL_HOME/log/install.log

TNS_PROFILE=""
DB_USER=""
DB_PASSWORD=""
APEX_APP_ID=""

print_usage()
{
    echo ""
    echo " export_apex.sh [-d WALLET_DIR] [-t TNS_PROFILE] [-u DB_USER] [-p DB_PASSWORD] [-a applicationId] [-w APEX_WORKSPACE] [-h]"
    echo ""
    echo " -d: Wallet Directory"
    echo " -t: TNS profile used to connect to database"
    echo " -u: Database User (to export APEX app)"
    echo " -p: Database Password (for Database User)"
    echo " -a: Application ID (for the APEX app)"
    echo " -w: APEX Workspace (for the APEX app)"
    echo " -h: this help"
    echo ""
}

while getopts 'd:t:u:p:a:w:h' flag; do
  case "${flag}" in
    d) export TNS_ADMIN="$(realpath ${OPTARG})" ;;
    t) TNS_PROFILE="${OPTARG}" ;;
    u) DB_USER="${OPTARG}" ;;
    p) DB_PASSWORD="${OPTARG}" ;;
    a) APEX_APP_ID="${OPTARG}" ;;
    w) APEX_WORKSPACE="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [ -z "$TNS_ADMIN" ]
then
    read -p "Wallet Directory: " TNS_ADMIN
    export TNS_ADMIN="$(realpath ${TNS_ADMIN})"
fi
if [ -z "$TNS_PROFILE" ]
then
    read -p "TNS Profile: " TNS_PROFILE
fi
if [ -z "$DB_USER" ]
then
    read -p "Database User: " DB_USER
fi
if [ "$DB_PASSWORD" = "" ]
then
    stty -echo
    printf "Database Password: "
    read DB_PASSWORD
    stty echo
    printf "\n"
fi
if [ -z "$APEX_WORKSPACE" ]
then
    read -p "APEX Workspace: " APEX_WORKSPACE
fi
if [ -z "$APEX_APP_ID" ]
then
    read -p "APEX Application ID: " APEX_APP_ID
fi

# Run Commands

echo ${TNS_ADMIN}
echo "
set lines 199 trimsp on pages 0 feed on
-- spool $SLOG
connect \"${DB_USER}\"/\"${DB_PASSWORD}\"@${TNS_PROFILE}
declare
  v_workspace_id NUMBER;
begin
  select workspace_id into v_workspace_id
  from apex_workspaces where workspace = '${APEX_WORKSPACE}';
  apex_util.set_security_group_id
    (p_security_group_id => v_workspace_id);
end;
/
apex export -applicationId ${APEX_APP_ID} -skipExportDate -expSupportingObjects Y
/ 
" | $INSTALL_HOME/sqlcl/bin/sql /NOLOG
