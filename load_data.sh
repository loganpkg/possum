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

sed_map=$(mktemp)
original_revisions=$(mktemp)
new_revisions=$(mktemp)

git add --all
git commit -am new_data

git fast-export --full-tree --no-data data_edit~1..data_edit \
    | grep -o -E '^M 100[0-7]{3} [0-9a-f]{40} [0-9a-f]{40}' \
    | grep -o -E '[0-9a-f]{40} [0-9a-f]{40}' \
    | sed -E 's~^([0-9a-f]{40}) ([0-9a-f]{40})$~s/\2/\1/g~' > "$sed_map"

git switch "$target_branch"

git fast-export --no-data "$target_branch" > "$original_revisions"

sed -E -f "$sed_map" "$original_revisions" > "$new_revisions"

git branch -M old_"$target_branch"
git switch old_"$target_branch"
< "$new_revisions" git fast-import
git switch "$target_branch"
git branch -D old_"$target_branch"
git branch -D data_edit
git reflog expire --expire-unreachable=now --all
git gc --prune=now
