#!/usr/bin/env sh
# This script will nuke your git repository history.
# It will:
# - Squash the local filesystem state into one commit. 
# - Purge all of git reflog, after this there is no easy way to recover anything!
# - At the end it will attempt to force push to the
#   current default remote. 
#
#   @license This is stringed together from stackoverflow snippets 
#    + trivial parts written by me (Moritz Rehbach) 
#    with the help of shellcheck
#   so license / MIT / unlicense / nobody will ever read this.
#   Using this for work might lose your job.

# Set up a script-local alias for this, we'll call it repeatedly.
alias confirm=/Users/moritz/scripts/confirm.sh

forcepush() {
    git add .
    git commit -m "$1" --amend || {
        confirm "Failed to amend. Is this your first commit? Confirm to create initial commit.
If this is not a git repository or you have not added any remotes yet, please do so manually" && \
        git commit -a -m "$1"
    }
    #git rev-list HEAD --not --remotes && exit 1; 
    git reset "$(git commit-tree HEAD^\{tree\} -m "$1")"
    git reflog expire --expire=now --all
    git gc --aggressive --prune=now
    git push -f || { 
        confirm "Failed to force push. If the message above said that no upstream remote is set, we could try setting upstream to  \"origin\" and then again attempt to force push.
Do you want that?" && \
        git push -uf origin HEAD || exit 1; 
    }
}

COMMIT_MSG="${1:-Initial commit.}"
echo "Commit message to use:
$COMMIT_MSG

To customize this, use the commit message as first argument.

"
confirm 'This is a desctructive operation. This script will:
- Completely purge your git repository history...
- ...including reflog!
- This means that you probably will not be able to recover any of your git history (file system forensics aside).
- It will also attempt to force push to your default remote at the end, overwriting any history at the remote. NEVER DO THIS IN A COLLABORATIVE REPOSITORY!
- Existing .gitignore is of course untouched and respected 

Please confirm that you understand and really intend to do this:' || { echo 'Quitting on user request.'; exit; };

forcepush "$COMMIT_MSG" || echo "Error, see above" && exit 1;
