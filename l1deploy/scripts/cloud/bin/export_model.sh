#!/bin/sh
INSTALL_HOME=$(dirname $0 | xargs -I {} realpath {} | rev | cut -d '/' -f 2- | rev)
cd $INSTALL_HOME

cd model

TNS_PROFILE=""
DB_USER=""
DB_PASSWORD=""

print_usage()
{
    echo ""
    echo " export_model.sh [-d WALLET_DIR] [-t TNS_PROFILE] [-u DB_USER] [-p DB_PASSWORD] [-h]"
    echo ""
    echo " -d: Wallet Directory"
    echo " -t: TNS profile used to connect to database"
    echo " -u: Database User (to create)"
    echo " -p: Database Password (to create for Database User)"
    echo " -h: this help"
    echo ""
}

while getopts 'd:t:u:p:h' flag; do
  case "${flag}" in
    d) export TNS_ADMIN="$(realpath ${OPTARG})" ;;
    t) TNS_PROFILE="${OPTARG}" ;;
    u) DB_USER="${OPTARG}" ;;
    p) DB_PASSWORD="${OPTARG}" ;;
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

SLOG=$INSTALL_HOME/log/sqlcl.log
LOG=$INSTALL_HOME/log/install.log

# Run Commands

# Install objects>
echo "set lines 199 trimsp on pages 0 feed on
-- spool $SLOG
connect \"${DB_USER}\"/\"${DB_PASSWORD}\"@${TNS_PROFILE}
lb genschema
/
" | $INSTALL_HOME/sqlcl/bin/sql /NOLOG
