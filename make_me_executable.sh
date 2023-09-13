#!/usr/bin/env bash

#===============================================================================
#
#          FILE:  make_me_executable.sh
#
#         USAGE:  make_me_executable.sh  [-p fullPathScript]
#
#   DESCRIPTION:  Makes the script passed as parameter executable across the system
#
#       OPTIONS:  ---
#  REQUIREMENTS:  superuser grants
#         NOTES:  ---
#
#        AUTHOR:  majobasgall
#       COMPANY:
#       VERSION:  1.0
#       CREATED:  04/04/2019
#      REVISION:  --- .
#===============================================================================


if [[ -z "$1" ]]
  then
    echo "No argument supplied. Enter the script full path you want to make executable (the name of the script will be the name of the executable)."
    echo "To run: sh make_me_executable.sh <path_script>"
    exit
fi

SCRIPT_NAME=${1##*/}

sudo ln -s ${1} /usr/local/bin/${SCRIPT_NAME}

echo "It's done! now you can call the ${SCRIPT_NAME} from everywhere!"