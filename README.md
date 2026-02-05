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
3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

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


fix_perms
---------

`fix_perms` recursively corrects file permissions.


bkup
----

bkup creates incremental backups using cpdup with hard links.
You can schedule it using cron by typing `crontab -e` and editing
the configuration. The example below runs the backup every 5 minutes.

```
PATH=/home/logan/bin:/usr/bin:$PATH

*/5 * * * * bkup /path/to/source_dir /path/to/store_dir >> /path/to/log_file 2>&1
```

You can type `crontab -l` to view your configuration.


Enjoy,
Logan =)_
