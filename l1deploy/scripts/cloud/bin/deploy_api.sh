#!/bin/sh
INSTALL_HOME=$(dirname $0 | xargs -I {} realpath {} | rev | cut -d '/' -f 2- | rev)
cd $INSTALL_HOME

cd api

SLOG=$INSTALL_HOME/log/sqlcl.log
LOG=$INSTALL_HOME/log/install.log

TNS_PROFILE=""
DB_USER=""
DB_PASSWORD=""
ORDS_SCHEMA_ALIAS=""
API_FILE=""

print_usage()
{
    echo ""
    echo " deploy_api.sh [-d WALLET_DIR] [-t TNS_PROFILE] [-u DB_USER] [-p DB_PASSWORD] [-s DB_SCHEMA] [-a ORDS_SCHEMA_ALIAS] [-f API_FILE] [-h]"
    echo ""
    echo " -d: Wallet Directory"
    echo " -t: TNS profile used to connect to database"
    echo " -u: DB User"
    echo " -p: DB Password"
    echo " -a: ORDS SCHEMA alias (used in the URL)"
    echo " -f: ORDS API file (to install)"
    echo " -h: this help"
    echo ""
}
while getopts 'd:t:u:p:s:a:f:h' flag; do
  case "${flag}" in
    d) export TNS_ADMIN="$(realpath ${OPTARG})" ;;
    t) TNS_PROFILE="${OPTARG}" ;;
    u) DB_USER="${OPTARG}" ;;
    p) DB_PASSWORD="${OPTARG}" ;;
    s) DB_SCHEMA="${OPTARG}" ;;
    a) ORDS_SCHEMA_ALIAS="${OPTARG}" ;;
    f) API_FILE="${OPTARG}" ;;
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
    read -p "DB User: " DB_USER
fi
if [ "$DB_PASSWORD" = "" ]
then
    stty -echo
    printf "DB Password: "
    read DB_PASSWORD
    stty echo
    printf "\n"
fi
if [ -z "$DB_SCHEMA" ]
then
    read -p "DB Schema: " DB_SCHEMA
fi
if [ -z "$ORDS_SCHEMA_ALIAS" ]
then
    read -p "ORDS schema alias: " ORDS_SCHEMA_ALIAS
fi
if [ -z "$API_FILE" ]
then
    read -p "ORDS API file: " API_FILE
fi

# Run Commands
unzip -o ${API_FILE}.zip

# Install APEX apps
echo "set lines 199 trimsp on pages 0 feed on
-- spool $SLOG
connect "${DB_USER}"/\"${DB_PASSWORD}\"@${TNS_PROFILE};
begin
  ORDS.ENABLE_SCHEMA(
    p_enabled             => TRUE,
    p_schema              => '${DB_SCHEMA}',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => '${ORDS_SCHEMA_ALIAS}',
    p_auto_rest_auth      => FALSE);
end;
/ 
@${API_FILE}.sql
" | $INSTALL_HOME/sqlcl/bin/sql /NOLOG
