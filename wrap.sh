#! /bin/sh

#
# Copyright (c) 2026 Logan Ryan McLintock. All rights reserved.
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

# Wraps text while preserving the indent level.

set -e
set -u
# set -x

w=80

tmp=$(mktemp)


# Unwrap lines first.
sed -E -e 's/\t/    /g' \
       -e 's/\xE2\x80(\x9C|\x9D)/"/g' \
       -e "s/\xE2\x80\x99/'/g" \
       -e 's/ +$//' "$1" \
    | tr -d '\0\r' \
    | tr '\n' '\0' \
    | sed -E 's/([^\x00])\x00([^\x00])/\1 \2/g' \
    | tr '\0' '\n' > "$tmp"


while IFS='' read -r line
do
    if [ -z "$line" ]
    then
        printf '\n'
    else
        ws=$(printf %s "$line" | grep -o -E '^ *')
        x=$(printf %s "$ws" | wc -c)

        printf '%s\n' "$line" | sed -E 's/^ +//' | fold -s -w $((w - x)) | sed -E -e "s/^/$ws/" -e 's/ +$//'
    fi
done < "$tmp"

rm "$tmp"
