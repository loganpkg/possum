#! /bin/sh

#
# Copyright (c) 2025, 2026 Logan Ryan McLintock. All rights reserved.
#
# The contents of this file are subject to the
# Common Development and Distribution License (CDDL) version 1.1
# (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License in
# the LICENSE file included with this software or at
# https://opensource.org/license/cddl-1-1
#
# NOTICE PURSUANT TO SECTION 4.2 OF THE LICENSE:
# This software is prohibited from being distributed or otherwise made
# available under any subsequent version of the License.
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#

# A simple script to assist in changing the license of a software project.

set -e
set -u
set -x

# Existing license height.
h=24

# New license directory.
new_l=CDDL-1.1

export h new_l

find . -type f ! -path '*.git/*' ! -name '*_new' -exec sh -c '
    set -e
    set -u
    set -x

    fn="$1"

    y=$(git log --follow --date=format:%Y --pretty=format:%ad -- "$fn" \
        | sort --uniq | tr "\n" "," | sed -E -e "s/,/, /g" -e "s/, $//")

    t=$(head -n 1 "$fn")

    if [ "$t" = "/*" ]
    then
        sed -E "s/<YEAR>/$y/" ../"$new_l"/c_header > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif printf %s "$t" | grep -E "^#! /"
    then
        head -n 2 "$fn" > "$fn"_new
        sed -E "s/<YEAR>/$y/" ../"$new_l"/sh_header >> "$fn"_new
        tail -n +"$((2 + h + 1))" "$fn" >> "$fn"_new
        chmod 700 "$fn"_new
    elif [ "$t" = "divert(-1)" ]
    then
        head -n 2 "$fn" > "$fn"_new
        sed -E "s/<YEAR>/$y/" ../"$new_l"/sh_header >> "$fn"_new
        tail -n +"$((2 + h + 1))" "$fn" >> "$fn"_new
    elif [ "$t" = "::" ]
    then
        sed -E "s/<YEAR>/$y/" ../"$new_l"/cmd_header > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif [ "$t" = "#" ]
    then
        sed -E "s/<YEAR>/$y/" ../"$new_l"/sh_header > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif [ "$t" = ";" ]
    then
        sed -E "s/<YEAR>/$y/" ../"$new_l"/asm_header > "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif [ "$t" = "<!--" ]
    then
        head -n 2 "$fn" > "$fn"_new
        sed -E "s/<YEAR>/$y/" ../"$new_l"/HEADER >> "$fn"_new
        tail -n +"$((h + 1))" "$fn" >> "$fn"_new
    elif printf %s "$t" | grep -E "^((Copyright)|(SPDX))"
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


find . -type f ! -path '*.git/*' -exec \
    sed -i -E 's/2023, 2024, 2025/2023-2025/' '{}' \;
