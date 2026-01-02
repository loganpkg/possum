<!--

Copyright (c) 2024, 2025 Logan Ryan McLintock. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

-->

possum
======

possum is a collection of utility shell scripts.

It includes the `possum` script which organises photos and videos based
on the create date stored inside the media.


data_edit
---------

`data_edit` is an easy way to edit Git data blobs.

Firstly, backup your repository using cpdup or rsync.

Set the target_branch in both scripts to the current branch
that you are on and that you want to edit.

Run `prepare_data.sh` which will provide all of the data blobs.
From here you can edit these files and can run `git diff` to
review your changes.

Finally, run `load_data.sh` to add these files to the repository
and to retrospectively patch the revisions on the target branch.


swap_license
------------

A simple script to assist in changing the license of a software project.


wrap
----

The `wrap` script folds text while preserving the indent level.


mirror
------

The `mirror` script mirrors the source directory to the destination
directory.


Enjoy,
Logan =)_
