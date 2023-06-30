#!/bin/bash

# chmod +x git_push2.sh
# ./git_push2.sh

git lfs track "*.pdf"
git lfs track "*.docx"
git lfs track "*.epub"

files=( $(find ./ -type f) )   # Find all files in the current directory and subdirectories
batch_size=1000                 # Define the batch size
total_files=${#files[@]}       # Get total number of files
batches=$((($total_files + $batch_size - 1) / $batch_size))

for ((i=0; i<$batches; i++))
do
  start=$((i*batch_size))
  end=$((start+batch_size-1))

  if [[ $end -gt $((total_files-1)) ]]; then
    end=$((total_files-1))
  fi

  echo "Adding files from $start to $end"
  file_group=""
  for ((j=start; j<=end; j++))
  do
    file_group+=" ${files[$j]}"
  done

  git add $file_group
  git commit -m "WIP Adding files from $start to $end"
  echo "Push start after adding files from $start to $end"
  git push origin
  echo "Pushed files from $start to $end"
  sleep 20
done


# git add *.qmd
# git commit -m "qmd files"
# git add *.yml
# git commit -m "yml files"
# git push origin

