data_edit
=========

Easy way to edit Git data blobs.

Firstly, backup your repository using cpdup or rsync.

Set the target_branch in both scripts to the current branch
that you are on and that you want to edit.

Run `prepare_data.sh` which will provide all of the data blobs.
From here you can edit these files and can run `git diff` to
review your changes.

Finally, run `load_data.sh` to add these files to the repository
and to retrospectively patch the revisions on the target branch.

Enjoy,
Logan =)_
