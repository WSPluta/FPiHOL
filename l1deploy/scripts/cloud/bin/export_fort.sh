#!/bin/sh
INSTALL_HOME=$(dirname $0 | xargs -I {} realpath {} | rev | cut -d '/' -f 2- | rev)
cd $INSTALL_HOME

TNS_ADMIN=""
TNS_PROFILE=""
DB_USER=""
DB_PASSWORD=""
APEX_WORKSPACE=""
ADMIN_PASSWORD=""
WALLET_DIR=""

print_usage()
{
    echo ""
    echo " export_fort.sh [-d WALLET_DIR] [-t TNS_PROFILE] [-u DB_USER] [-p DB_PASSWORD] [-w APEX_WORKSPACE] [-a ADMIN_PASSWORD] [-h]"
    echo ""
    echo " -d: Wallet Directory"
    echo " -t: TNS profile used to connect to database"
    echo " -u: Database User (to create)"
    echo " -p: Database Password (to create for Database User)"
    echo " -w: APEX Workspace (to install APEX applications)"
    echo " -a: ADMIN Password"
    echo " -h: this help"
    echo ""
}

while getopts 'd:t:u:p:w:a:h' flag; do
  case "${flag}" in
    d) WALLET_DIR="$(realpath ${OPTARG})" ;;
    t) TNS_PROFILE="${OPTARG}" ;;
    u) DB_USER="${OPTARG}" ;;
    p) DB_PASSWORD="${OPTARG}" ;;
    w) APEX_WORKSPACE="${OPTARG}" ;;
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
if [ -z "$WALLET_DIR" ]
then
    read -p "Wallet Directory: " WALLET_DIR
    WALLET_DIR="$(realpath ${WALLET_DIR})"
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

if [ ! -d "./log" ] 
then
    mkdir log
fi

LEADERBOARD_APEX_APPID=134
MANAGER_APEX_APPID=166

bin/export_apex.sh -d ${WALLET_DIR} -t ${TNS_PROFILE} -u "ADMIN" -p "${ADMIN_PASSWORD}" -w "${APEX_WORKSPACE}" -a ${LEADERBOARD_APEX_APPID}
bin/export_apex.sh -d ${WALLET_DIR} -t ${TNS_PROFILE} -u "ADMIN" -p "${ADMIN_PASSWORD}" -w "${APEX_WORKSPACE}" -a ${MANAGER_APEX_APPID}
bin/export_model.sh -d ${WALLET_DIR} -t ${TNS_PROFILE} -u "${DB_USER}" -p "${DB_PASSWORD}"
