#! /bin/sh

#
# Copyright (c) 2024, 2025 Logan Ryan McLintock. All rights reserved.
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


# Mirror:
# Mirrors the source directory to the destination directory.

set -e
set -u

if [ "$#" -ne 2 ]
then
    printf 'Usage: %s source_dir dest_dir\n' "$0" 1>&2
    exit 1
fi

source_dir="$1"
dest_dir="$2"

if [ ! -d "$source_dir" ]
then
    printf '%s: Error: source_dir does not exist: %s\n' "$0" "$source_dir" 1>&2
    exit 1
fi

if [ ! -d "$dest_dir" ]
then
    printf '%s: Error: dest_dir does not exist: %s\n' "$0" "$dest_dir" 1>&2
    exit 1
fi

rsync -aHvv --delete --force "$source_dir"/ "$dest_dir"

exit 0
