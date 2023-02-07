#!/bin/sh

# Check jq intallation
OS=$(grep "^ID=" /etc/os-release | cut -d "=" -f 2 | sed -e 's/^"//' -e 's/"$//')
JQO=$(jq --help)
if [ $? = 127 ]
then
    echo "jq is not installed. attempting to install."
    if [ "$OS" = "ol" ]
    then
        sudo dnf install jq
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]
    then
        sudo apt-get update
        sudo apt-get install jq
    else
        echo "Unable to confidently install jq. https://stedolan.github.io/jq/"
        echo "Install jq before continuing (install terminated)."
        exit 255
    fi
fi

print_usage()
{
    echo ""
    echo " download_package.sh [-d INSTALL_HOME] [-h]"
    echo ""
    echo " -d: Wallet Install Directory"
    echo " -h: this help"
    echo ""
}

# Check existing installation version
INSTALL_HOME=$(dirname $0 | xargs -I {} realpath {} | rev | cut -d '/' -f 2- | rev)
if [ -e "${INSTALL_HOME}/build.info" ]
then
    cd ${INSTALL_HOME}
    CP=`grep "GIT_REPO=" build.info | cut -d '=' -f 2`
    CT=`grep "TAG=" build.info | cut -d '=' -f 2`
    CV=`grep "BUILD_NUMBER=" build.info | cut -d '=' -f 2`
    CURRENT_BUILD="${CP}/${CP}-${CT}-${CV}.tar.gz"
else
    CP="f1-simulator-cloud"
    echo "Default to latest build (and name)."
    CV=0
    INSTALL_HOME=""
    while getopts 'd:h' flag; do
        case "${flag}" in
        d) INSTALL_HOME="$(realpath ${OPTARG})" ;;
        *) print_usage
           exit 1 ;;
        esac
    done
    if [ -z "$INSTALL_HOME" ]
    then
        read -p "Install Directory: " INSTALL_HOME
        INSTALL_HOME="$(realpath ${INSTALL_HOME})"
    fi
fi

# Download package
LATEST_BUILD=`curl https://apigw.withoracle.cloud/livelaps/rdm/packages/ | jq -rc --arg PROJECT "${CP}/${CP}" '[ .objects[] | select(.name | contains($PROJECT)) ] | last | .name'`
echo ${LATEST_BUILD}

LV=`echo "${LATEST_BUILD}" | cut -d '.' -f 1 | rev | cut -d '-' -f 1 | rev`
LF=`echo "${LATEST_BUILD}" | cut -d '/' -f 2-`

if [ $((${CV} < ${LV})) = 0 ]
then
    echo "${CURRENT_BUILD} is the latest build."
    exit 1
fi

echo "${LATEST_BUILD} is the latest build. Installing."

if [ ! -d dist ]
then
    mkdir dist
fi

wget -O dist/${LF} https://apigw.withoracle.cloud/livelaps/rdm/packages/${LATEST_BUILD}

# Unzip package
tar xzvf dist/${LF} --directory=$INSTALL_HOME

if [ ! -d log ]
then
    mkdir log
fi
