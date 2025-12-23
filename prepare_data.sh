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

set -e
set -u
set -x

target_branch=master

hash_list=$(mktemp)

git switch --orphan data_edit

git fast-export --no-data "$target_branch" \
    | grep -o -E '^M 100[0-7]{3} [0-9a-f]{40} ' \
    | grep -o -E '[0-9a-f]{40}' > "$hash_list"

while IFS='' read -r hash
do
    # shellcheck disable=SC2094
    git cat-file blob "$hash" > "$hash"
done < "$hash_list"

git add --all
git commit -am existing_data

printf 'Edit files ... then run load_data.sh\n'
