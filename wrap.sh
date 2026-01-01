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
       -e 's/\xC2\xA7//g' \
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
