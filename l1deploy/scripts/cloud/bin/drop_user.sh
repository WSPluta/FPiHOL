#!/bin/sh
INSTALL_HOME=$(dirname $0 | xargs -I {} realpath {} | rev | cut -d '/' -f 2- | rev)
cd $INSTALL_HOME

# Unzip package
SLOG=$INSTALL_HOME/log/sqlcl.log
LOG=$INSTALL_HOME/log/install.log

TNS_ADMIN=""
TNS_PROFILE=""
APEX_WORKSPACE=""
ADMIN_PASSWORD=""

print_usage()
{
    echo ""
    echo " drop_user.sh [-d WALLET_DIR] [-t TNS_PROFILE] [-u DB_USER] [-w APEX_WORKSPACE] [-a ADMIN_PASSWORD] [-h]"
    echo ""
    echo " -d: Wallet Directory"
    echo " -t: TNS profile used to connect to database"
    echo " -u: DB User (to remove)"
    echo " -w: APEX Workspace (to remove)"
    echo " -a: ADMIN Password"
    echo " -h: this help"
    echo ""
}

while getopts 'd:t:w:u:a:h' flag; do
  case "${flag}" in
    d) export TNS_ADMIN="$(realpath ${OPTARG})" ;;
    t) TNS_PROFILE="${OPTARG}" ;;
    w) APEX_WORKSPACE="${OPTARG}" ;;
    u) DB_USER="${OPTARG}" ;;
    a) ADMIN_PASSWORD="${OPTARG}" ;;
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
if [ -z "$DB_USER" ]
then
    read -p "Database User: " DB_USER
fi
if [ -z "$APEX_WORKSPACE" ]
then
    read -p "APEX Workspace: " APEX_WORKSPACE
fi

# Run Commands
# Remove APEX Workspace (also drops the DB User)
echo "set lines 199 trimsp on pages 0 feed on
-- spool $SLOG
connect ADMIN/\"${ADMIN_PASSWORD}\"@${TNS_PROFILE}
exec apex_instance_admin.remove_workspace(p_workspace => '${APEX_WORKSPACE}');
drop user ${DB_USER} cascade;
/
" | $INSTALL_HOME/sqlcl/bin/sql /NOLOG
