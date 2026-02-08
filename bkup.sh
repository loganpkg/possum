#! /bin/sh

#
# Copyright (c) 2026 Logan Ryan McLintock. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#


# bkup: Creates incremental backups using cpdup with hard links.

set -e
set -u
# set -x


usage='source_dir store_dir'


run_id=$(dd if=/dev/urandom bs=200 count=1 2> /dev/null \
    | tr -dc '[:alnum:]' | cut -c 1-16)


if [ "$#" -ne 2 ]
then
    printf '%s|%s|ERROR|Usage should be %s %s\n' "$run_id" \
        "$(date +%Y_%m_%d_%H_%M_%S)" "$0" "$usage" 1>&2

    exit 1
fi

source_dir=$1
store_dir=$2

mkdir -p "$store_dir"

export run_id source_dir store_dir


(
    get_date() {
        date +%Y_%m_%d_%H_%M_%S
    }


    print_error() {
        {
            printf '%s|%s|ERROR|' "$run_id" "$(get_date)"
            # shellcheck disable=SC2059
            printf "$@"
            printf '\n'
        } 1>&2
    }


    print_success() {
        printf '%s|%s|SUCCESS|' "$run_id" "$(get_date)"
        # shellcheck disable=SC2059
        printf "$@"
        printf '\n'
    }


    str_check() {
        nl_count=$(printf %s "$1" | wc -l)
        if [ "$nl_count" -ne 0 ]
        then
            print_error 'Newline character found in %s' "$1"
            exit 1
        fi

        if printf %s "$1" | grep -E '\|' 1> /dev/null
        then
            print_error 'Pipe character found in %s' "$1"
            exit 1
        fi
    }


    generate_list() {
        tmp_list=$(mktemp)

        wd=$(pwd)
        cd "$1" || exit 1
        find . -type f -printf '%p\0%s\0%m\0%T@\0\0' > "$tmp_list"
        cd "$wd" || exit 1

        tmp_list_check=$(mktemp)
        < "$tmp_list" tr -d '\n|' > "$tmp_list_check"

        if ! cmp "$tmp_list" "$tmp_list_check" 1> /dev/null
        then
            print_error 'Newline or pipe symbol in filename'
            exit 1
        fi

        tmp_list_readable=$(mktemp)
        sed -E -e 's/\x00\x00/\n/g' -e 's/\x00/|/g' "$tmp_list" \
            > "$tmp_list_readable"

        tmp_list_sorted=$(mktemp)
        LC_ALL=C sort -k 1,1 -s "$tmp_list_readable" | sed -E 's/\.[0-9]+$//' \
            > "$tmp_list_sorted"

        rm "$tmp_list" "$tmp_list_check" "$tmp_list_readable"

        printf '%s\n' "$tmp_list_sorted"
    }


    dt=$(get_date)
    printf '%s|%s|INFO|Starting\n' "$run_id" "$dt"

    if flock -n 9
    then
        printf '%s|%s|INFO|Lock obtained\n' "$run_id" "$(get_date)"
    else
        print_error 'Already locked'
        exit 1
    fi

    str_check "$source_dir"
    str_check "$store_dir"

    if [ ! -d "$source_dir" ]
    then
        print_error 'Source directory %s does not exist' "$source_dir"
        exit 1
    fi

    bn=$(basename "$source_dir")

    if [ -f "$store_dir"/source_name.txt ]
    then
        # Check that the source is correct for the store.
        source_nm=$(cat "$store_dir"/source_name.txt)

        if [ "$source_nm" != "$bn" ]
        then
            print_error 'Expecting a source of %s not %s' "$source_nm" "$bn"
            exit 1
        fi
    else
        # New store.
        printf '%s\n' "$bn" > "$store_dir"/source_name.txt
    fi


    dest_dir="$store_dir/$dt""_$bn"

    if [ -e "$dest_dir"~ ]
    then
        print_error '%s already exists' "$dest_dir"~
        exit 1
    fi


    latest=$(find "$store_dir" -mindepth 1 -maxdepth 1 -type d ! -name '*~' \
        | sort | tail -n 1)

    if [ -z "$latest" ]
    then
        # First backup.
        cpdup -I "$source_dir" "$dest_dir"~
        mv "$dest_dir"~ "$dest_dir"
        print_success 'First'
    else
        source_list=$(generate_list "$source_dir")
        latest_list=$(generate_list "$latest")

        if cmp "$source_list" "$latest_list" 1> /dev/null
        then
            # No changes since last backup.
            print_success 'No change'
        else
            # Incremental.
            cpdup -I -s0 -i0 -j0 -H "$latest" "$source_dir" "$dest_dir"~
            mv "$dest_dir"~ "$dest_dir"
            print_success 'Incremental'
        fi

        rm "$source_list" "$latest_list"
    fi

) 9> "$store_dir"/LOCK
