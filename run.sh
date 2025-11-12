#!/bin/bash

source code/00_setup.sh
NOW=$(date +"%d-%m-%Y_%H_%M")
echo $LOGDIR



# shellcheck checks if the script that's about to be run has proper bash synthax
set -e
script_name=${@: -1}
echo "Running shellcheck on $script_name"
#shellcheck $script_name

# filenames that when sorted by filename shows relevant files together.
sbatch --output="$LOGDIR/%x-[$NOW]-[%a]-OUT-[%J]" --error="$LOGDIR/%x-[$NOW]-[%a]-ERR-[%J]" $@
