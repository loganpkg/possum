#!/bin/sh

#
# Copyright (c) 2019, 2020, 2021 Logan Ryan McLintock
#
# Permission to use, copy, modify, and distribute this software for any
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

#
# possum -- Stores pictures and movies based on their creation date.
# For my loving esposinha with her beautiful possum eyes.
#
# README:
# Requires exiftool and jdupes to be installed first.
# To install:
# Make this file executable. For example:
#    $ chmod 700 possum.sh
# Place it somewhere in your PATH. For example:
#    $ mv possum.sh ~/bin/possum
# To use:
#    $ possum searchdir storedir
#
# Enjoy, Logan =)_
#

if [ "$#" -ne 2 ]
then
    printf 'Usage: %s searchdir storedir\n' "$0" 1>&2
    exit 1
fi

set -e
set -u
set -x

searchdir="$1"
storedir="$2"

# Check that the directories exist
if [ ! -d "$searchdir" ]
then
    printf 'Directory does not exist: %s\n' "$searchdir" 1>&2
    exit 1
fi

if [ ! -d "$storedir" ]
then
    printf 'Directory does not exist: %s\n' "$storedir" 1>&2
    exit 1
fi

# Delete empty files as they cause exiftool to stop
find "$searchdir" -type f -empty -delete

# Rename and move files with exif date
exiftool -r '-FileName<CreateDate' \
-d "$storedir"'/%Y/%m/%Y_%m_%d_%H_%M_%S%%-c.%%ue' \
-ext heic -ext jpg -ext jpeg -ext mov -ext mp4 "$searchdir"

# Rename and move files without exif date
exiftool -r '-FileName<FileModifyDate' \
-d "$storedir"'/noexifdate/%Y_%m_%d_%H_%M_%S%%-c.%%ue' \
-ext heic -ext jpg -ext jpeg -ext mov -ext mp4 "$searchdir"

# Delete junk files
find "$searchdir" \
\( -name 'desktop.ini' -o -name '.nomedia' -o -iname '*.AAE' \) \
-type f -delete

# Delete empty directories
find "$searchdir" -type d -empty -delete

# Remove duplicates
jdupes --recurse --delete --noprompt "$storedir"
