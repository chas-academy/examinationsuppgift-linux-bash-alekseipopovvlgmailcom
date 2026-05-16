#!/bin/bash

if [ $UID -gt 0 ]; then
    echo "Error: User is not eligible to run the script"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "No users provided"
    exit 1
fi


create_folders() {
    folders=(Documents Downloads Work)

    for folder in "${folders[@]}"; do
        path="/home/$1/$folder"
        mkdir -p "$path"
        chmod 700 "$path"
    done
    echo "Folders created"
}


create_welcome_file() {
    path="/home/$1/welcome.txt"
    touch "$path"
    echo "Välkommen $user" > "$path"
}

add_existing_users() {
    path="/home/$1/welcome.txt"

    for users in /home/*; do
        username=$(basename "$users")

        if [ "$username" != "$1" ]; then
            echo "$username " >> "$path"
        fi
    done
}

for user in "$@"; do
    if id "$user" &>/dev/null ; then
        echo "User: $user exists."
        continue
    fi

    echo "Creating user: $user"

    home_dir="/home/$user"

    # create user with users directory
    useradd -m "$user"
    create_folders "$user"
    create_welcome_file "$user"

    # set ownership
    chown -R "$user:$user" "$home_dir"
done

# add all the user in the system to the welcolme.txt files
# Runs att the end in order to add all the users
for user in "$@"; do
    add_existing_users "$user"
done
