<!--

Copyright (c) 2025, 2026 Logan Ryan McLintock. All rights reserved.

The contents of this file are subject to the
Common Development and Distribution License (CDDL) version 1.1
(the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License in
the LICENSE file included with this software or at
https://opensource.org/license/cddl-1-1

NOTICE PURSUANT TO SECTION 4.2 OF THE LICENSE:
This software is prohibited from being distributed or otherwise made
available under any subsequent version of the License.

Software distributed under the License is distributed on an "AS IS"
basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
License for the specific language governing rights and limitations
under the License.

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
