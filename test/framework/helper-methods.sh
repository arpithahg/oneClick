#!/bin/bash
#styled printing
LOG_LOCAL_PATH=${LOG_LOCAL_PATH}
print_style () {

    if [ "$2" == "info" ] ; then
        COLOR="36m";
    elif [ "$2" == "success" ] ; then
        COLOR="92m";
    elif [ "$2" == "warning" ] ; then
        COLOR="93m";
    elif [ "$2" == "danger" ] ; then
        COLOR="91m";
    else #default color
        COLOR="0m";
    fi

    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";

    printf "$STARTCOLOR%b$ENDCOLOR" "$1";
#    echo ${LOG_LOCAL_PATH}
#    echo "$1">>${LOG_LOCAL_PATH}
}

#print_style "This is a green text " "success";
#print_style "This is a yellow text " "warning";
#print_style "This is a light blue with a \t tab " "info";
#print_style "This is a red text with a new line " "danger";
#print_style "This has no color";

#exec 2>>${LOG_FILE}
#
#function log {
#    echo "$1">>${LOG_FILE}
#}
#
#function message {
#    echo "$1"
#    echo "$1">>${LOG_FILE}
#}