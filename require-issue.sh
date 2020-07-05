#!/usr/bin/env bash

commit_format="(JIRA|PROJECTKEY|MULE|ECOM|SAP|XLR-[1-9]+Merge)"
zero_commit="0000000000000000000000000000000000000000"

# Do not traverse over commits that are already in the repository
# (e.g. in a different branch)
# This prevents funny errors if pre-receive hooks got enabled after some
# commits got already in and then somebody tries to create a new branch
# If this is unwanted behavior, just set the variable to empty
excludeExisting="--not --all"
error_msg="Aborting commit. Your commit message is missing a JIRA Issue ('For example, SAP-111, MULE-111') "

while read oldrev newrev refname; do
  # branch or tag get deleted
  if [ "$newrev" = "$zero_commit" ]; then
    continue
  fi
  # Check for new branch or tag
  if [ "$oldrev" = "$zero_commit" ]; then
    span=`git rev-list $newrev $excludeExisting`
  else
    span=`git rev-list $oldrev..$newrev $excludeExisting`
  fi
  for COMMIT in $span;
   do
        COMMIT_MESSAGE=`git log --format=%B -n 1 ${COMMIT}`
        if ! [[ $COMMIT_MESSAGE =~ $commit_format ]]; then
        echo "$error_msg" >&2
        exit 1
    fi;
    done
done
exit 0
