#!/usr/bin/env bash

function clean_passwd
{
   local source_file=$1
   local target_file=$2

   while IFS='' read -r line || [[ -n "$line" ]]; do
      local uid=$(echo $line | awk -F: '{ print $3 }')

      if [ $uid -le 1000000 ]; then
         echo $line >> $target_file
      fi
   done < $source_file
}

clean_passwd $1 $2
