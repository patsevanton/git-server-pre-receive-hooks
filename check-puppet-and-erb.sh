#!/bin/bash

# Git hook from https://gist.github.com/rombert/7109f2f7d7448a7848a8
# See https://www.kernel.org/pub/software/scm/git/docs/githooks.html#pre-receive    
oldrev=$1
newrev=$2
refname=$3

while read oldrev newrev refname; do
    
    # Get the file names, without directory, of the files that have been modified
    # between the new revision and the old revision
    files=`git diff --name-only ${oldrev} ${newrev}`

    # Get a list of all objects in the new revision
    objects=`git ls-tree --full-name -r ${newrev}`

    # Iterate over each of these files
    for file in ${files}; do
  
        # Search for the file name in the list of all objects
        object=`echo -e "${objects}" | egrep "(\s)${file}\$" | awk '{ print $3 }'`
        
        # If it's not present, then continue to the the next itteration
        if [ -z ${object} ]; 
                then 
                continue; 
        fi

        # validate
        if [[ "$file" == *\.pp ]]; then
                output=$(git cat-file blob ${object} | puppet parser validate 2>&1)
        elif [[ "$file" == *\.erb ]]; then
            output=$(git cat-file blob ${object} | erb -P -x -T '-'   | ruby -c 2>&1)
        fi
   
        # output the validation result if it failed
        if [[ $? -ne 0 ]];
            then
                echo "ERROR: validation failed for ${file}:"
            echo "${output}"
            bad_file=1
        fi
    done;
done

# reject the commit if at least one file failed
if [[ $bad_file -eq 1 ]]
then
  exit 1
fi
