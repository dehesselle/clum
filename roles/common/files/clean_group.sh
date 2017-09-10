#!/usr/bin/env bash
#
# Centralized Local User Management
# https://github.com/dehesselle/clum
#

# associative array to store all users with their UIDs
declare -A USERS

function read_users
{
   while IFS='' read -r line || [[ -n "$line" ]]; do
      local uname=$(echo $line | awk -F: '{ print $1 }')
      local uid=$(echo $line | awk -F: '{ print $3 }')
      USERS[$uname]=$uid
   done < /etc/passwd
}

function clean_groups
{
   local file_source=$1
   local file_target=$2
   local id=$3

   while IFS='' read -r line || [[ -n "$line" ]]; do
      if [[ "$line" =~ (.+:.+:.+:)(.+) ]]; then
         local group_empty=${BASH_REMATCH[1]}
         local group_members=${BASH_REMATCH[2]}

         for uname in "${!USERS[@]}"; do
            # only remove users managed with CLUM (identified by their id)
            if [ ${USERS[$uname]} -ge $id ]; then
               if [[ "$group_members" =~ (.+)?($uname[,]?)(.+)? ]]; then
                  # remove user from group
                  group_members=${BASH_REMATCH[1]}${BASH_REMATCH[3]}
                  # remove trailing comma
                  if [ "${group_members: -1}" = "," ]; then
                     group_members=$(echo -n $group_members | head -c -1)
                  fi
               fi
            fi
         done

         echo $group_empty$group_members >> $file_target
      else
         echo $line >> $file_target
      fi
   done < $file_source
}

read_users
clean_groups $1 $2 $3
