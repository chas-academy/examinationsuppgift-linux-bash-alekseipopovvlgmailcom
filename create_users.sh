#!/bin/bash
 
 # Check root
 if [ "$UID" -ne 0 ]; then
     echo "Error: must be root"
     exit 1
 fi
 
 # Check arguments
 if [ "$#" -eq 0 ]; then
     echo "No users provided"
     exit 1
 fi
 
 create_folders() {
     for folder in Documents Downloads Work; do
         mkdir -p "/home/$1/$folder"
         chmod 700 "/home/$1/$folder"
     done
 }
 
 create_welcome_file() {
     path="/home/$1/welcome.txt"
     echo "Välkommen $1" > "$path"
 }
 
 add_existing_users() {
     path="/home/$1/welcome.txt"
 
     # safety
     [ -f "$path" ] || touch "$path"
 
     cut -d: -f1 /etc/passwd | while read users; do
         if [ "$users" != "$1" ]; then
             echo "$users" >> "$path"
         fi
     done
 }
 
 for user in "$@"; do
     if id "$user" &>/dev/null; then
         continue
     fi
 
     useradd -m "$user" || exit 1
 
     create_folders "$user"
     create_welcome_file "$user"
 
     chown -R "$user:$user" "/home/$user"
 done
 
 for user in "$@"; do
     add_existing_users "$user"
 done
 
 exit 0
