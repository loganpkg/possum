#! /bin/sh

#
# Copyright (c) 2024, 2025 Logan Ryan McLintock. All rights reserved.
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


# possum:
# Organises photos and videos based on the create date stored inside the media.
# For my loving wife with her beautiful possum eyes.

set -e
set -u

if [ "$#" -ne 2 ]
then
    printf 'Usage: %s search_dir store_dir\n' "$0" 1>&2
    printf '       %s --verify store_dir\n' "$0" 1>&2
    exit 1
fi

store_dir=$(printf '%s' "$2" | sed -E 's~/+$~~')
export store_dir

if [ ! -d "$store_dir" ]
then
    printf '%s: Error: store_dir does not exist: %s\n' "$0" "$store_dir" 1>&2
    exit 1
fi


if [ "$1" = --verify ]
then
    cd "$store_dir" || exit 1
    find . -type f | sed -E 's~.*_([0-9a-f]+)\..*~\1 \0~' | sha256sum -c
    exit 0
fi


search_dir=$(printf '%s' "$1" | sed -E 's~/+$~~')

if [ ! -d "$search_dir" ]
then
    printf '%s: Error: search_dir does not exist: %s\n' "$0" "$search_dir" 1>&2
    exit 1
fi


tmp=$(mktemp)

find "$search_dir" -type f ! -empty \
    \( -iname '*.jpg'  \
    -o -iname '*.jpeg' \
    -o -iname '*.mov'  \
    -o -iname '*.mp4'  \
    -o -iname '*.heic' \
    \) \
    -print0 > "$tmp"

bad_ch_count=$(wc -l "$tmp" | cut -d ' ' -f 1)

if [ "$bad_ch_count" -ne 0 ]
then
    printf '%s: ERROR: File path contains a newline char\n' "$0" 1>&2
    exit 1
fi

tmp_nl=$(mktemp)
< "$tmp" tr '\0' '\n' > "$tmp_nl"


while IFS='' read -r file
do
    create_date=$(exiftool -CreateDate "$file" \
        | sed -E 's~Create Date +: ~~' | tr ': ' '_')

    if [ -z "$create_date" ] || [ "$create_date" = 0000_00_00_00_00_00 ]
    then
        printf 'No create date: %s\n' "$file"
    else
        ext=$(printf %s "$file" | grep -E -o '[^.]+$' \
            | tr '[:upper:]' '[:lower:]')

        hash=$(sha256sum "$file" | cut -d ' ' -f 1)

        year=$(printf %s "$create_date" | cut -c 1-4)
        month=$(printf %s "$create_date" | cut -c 6-7)

        mkdir -p "$store_dir/$year/$month"

        target_suffix="$year/$month/$create_date"'_'"$hash.$ext"
        target="$store_dir/$target_suffix"

        if [ -e "$target" ]
        then
            printf 'Dupe: %s\n' "$file"
        else
            cp "$file" "$target"~
            mv "$target"~ "$target"
            printf 'Copied: %s => %s\n' "$file" "$target"
        fi
    fi
done < "$tmp_nl"


rm "$tmp" "$tmp_nl"
