#!/usr/bin/env bash
#
# Centralized Local User Management
# https://github.com/dehesselle/clum
#

function clean_passwd
{
#  This function is meant to create versions of /etc/passwd and
#  /etc/group without entries that have a GID or UID that is
#  managed by CLUM (i.e. >= id).

   local source_file=$1
   local target_file=$2
   local id=$3

   while IFS='' read -r line || [[ -n "$line" ]]; do
      local uid=$(echo $line | awk -F: '{ print $3 }')

      if [ $uid -lt $id ]; then
         echo $line >> $target_file
      fi
   done < $source_file
}

clean_passwd $1 $2 $3
