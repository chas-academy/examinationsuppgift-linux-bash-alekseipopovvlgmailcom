#!/bin/bash

#check if the user is root
if [ $UID -gt 0 ]; then
    echo "Error: User is not eligible to run the script"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "No users provided"
    exit 1
fi

# takes username and creates necessary folders for the user
create_folders() {
    folders=(Documents Downloads Work)

    for folder in "${folders[@]}"; do
        path="/home/$1/$folder"
        mkdir "$path"
        chmod 700 "$path"
    done

    echo "Folders created"
}

add_users_to_file() {
    path="/home/$1/welcome.txt"
    string=""

    while IFS=: read -r user _ id _; do
        if [ "$id" -ge 1000 ] && [ "$user" != "nobody" ] && [ "$user" != "$1" ]; then
            string="$string $user"
        fi
    done < /etc/passwd

    string="${string:1}"

    echo "$string" >> "$path"
}

# takes username and creates welcome file with corresponding header
create_welcome_file() {
    path="/home/$1/welcome.txt"
    touch "$path"
    echo "Välkommen $1" > "$path"
    add_users_to_file "$1"
    chmod 700 "$path"
}

for user in "$@"; do
    if id "$user" &>/dev/null; then
        echo "User: $user exists."
        continue
    fi

    echo "Creating user: $user"

    home_dir="/home/$user"
    #crete user with corresponding directory
    useradd -m "$user"
    create_folders "$user"

    #set ownership
    chown -R "$user:$user" "$home_dir"
done

#create welcome  file with corresponding content 
for user in "$@"; do
    create_welcome_file "$user"
done

exit 0
