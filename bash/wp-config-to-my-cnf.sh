#!/usr/bin/env bash
#
# SCRIPT: wp-config-to-my-cnf.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2017-04-20
# REV:    1.0.T (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Create a MySQL my.cnf file from a WordPress configuration file.
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test "$1" && echo $@
    echo "Usage: $0 [OPTION]... path/to/wp-config.php"
    echo
    echo "Create a MySQL my.cnf file from a WordPress configuration file"
    exit 1
}

args=()
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args+=("$1") ;;
    esac
    shift
done

set -- "${args[@]}"

test $# -gt 0 || usage

reset_db_vars() {
    DB_NAME=
    DB_HOST=
    DB_USER=
    DB_PASSWORD=
}

check_db_vars() {
    local path=$1
    if ! [[ $DB_NAME && $DB_USER ]]; then
        msg "error: could not find DB_NAME and DB_USER variables in file $path; aborting."
        return 1
    fi
}

extract_db_vars() {
    local path=$1
    if ! test -f "$path"; then
        error "no such file: $path"
        return 1
    fi
    while read -r line; do
        value=${line#*=}
        case $line in
            DB_NAME=*) DB_NAME="$value" ;;
            DB_HOST=*) DB_HOST="$value" ;;
            DB_USER=*) DB_USER="$value" ;;
            DB_PASSWORD=*) DB_PASSWORD="$value" ;;
        esac
    done < <(tr -d '\r' < "$path" | sed -ne 's/^define..\(DB_[A-Z]*\)....\(.*\)..;/\1=\2/p')
}

create_my_cnf() {
    my_cnf_path=~/.my.cnf.$DB_NAME
    msg "creating file: $my_cnf_path"
    cat << EOF | tee "$my_cnf_path"
# you can connect to this database with the command:
# mysql --defaults-file=$my_cnf_path
[client]
host=$DB_HOST
user=$DB_USER
password=$DB_PASSWORD

[mysql]
database=$DB_NAME
EOF
}

wp_config_to_my_cnf() {
    local path=$1
    reset_db_vars
    extract_db_vars "$path" && check_db_vars "$path" && create_my_cnf
}

msg() {
    echo "*" "$@"
}

error() {
    msg "error:" "$@"
}

for path; do
    wp_config_to_my_cnf "$path"
done
