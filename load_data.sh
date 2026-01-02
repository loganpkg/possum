#! /bin/sh

#
# Copyright (c) 2025 Logan Ryan McLintock. All rights reserved.
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
