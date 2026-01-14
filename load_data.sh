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
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
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
