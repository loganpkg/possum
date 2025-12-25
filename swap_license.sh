#! /bin/sh

#
# Copyright (c) 2025 Logan Ryan McLintock
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

# A simple script to assist in changing the license of a software project.

set -e
set -u
set -x

# Existing license height.
h=26

# New license directory.
new_l=bsd_3

export h new_l

find . -type f ! -path '*.git/*' ! -name '*_new' -exec sh -c '
    set -e
    set -u
    set -x

    fn="$1"
    type=$(head -c 2 "$fn")

    if [ "$type" = "/*" ]
    then
        cat ../"$new_l"/c_license > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif [ "$type" = "#!" ]
    then
        head -n 2 "$fn" > "$fn"_new
        cat ../"$new_l"/sh_license >> "$fn"_new
        tail -n +"$((2 + h + 1))" "$fn" >> "$fn"_new
    elif [ "$type" = "::" ]
    then
        cat ../"$new_l"/cmd_license > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif [ "$type" = Co ] || [ "$type" = SP ]
    then
        cp ../"$new_l"/LICENSE "$fn"_new
    fi
    ' sh '{}' \;


find . -type f ! -path '*.git/*' -name '*_new' -exec sh -c '
    set -e
    set -u
    set -x

    fn="$1"
    h=$(printf %s "$fn" | sed -E "s/_new$//")
    mv "$fn" "$h"
    ' sh '{}' \;
