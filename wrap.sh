#! /bin/sh

#
# Copyright (c) 2025 Logan Ryan McLintock. All rights reserved.
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
    | sed -E 's/([^\x00])\x00 *([^ \x00])/\1 \2/g' \
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
