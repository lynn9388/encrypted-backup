#!/bin/sh

# This script encrypts files and folders with AES-256. The password can be set
# in password.txt under the current directory. If password.txt doesn't exist or
# is empty, the script will ask for it first. It also creates encrypted.txt
# which contains the final filename and encrypted filename. The saving folder
# for encrypted files can be set with -d option and the default is Encrypted.
#
# Usage: ./encrypt.sh [-d path] file1 file2 file3 ...

# Ask for password if password.txt doesn't exist or is empty, otherwise read it
if [ ! -f password.txt ] || [ -z "$(cat password.txt)" ]; then
    # Ask for password twice and check if they match each other and are not empty
    while true; do
        read -s -p "Enter password: " password
        echo
        read -s -p "Re-enter password: " password2
        echo
        if [ -n "$password" ] && [ "$password" = "$password2" ]; then
            break
        else
            echo "Passwords don't match or are empty. Try again."
        fi
    done
else
    password=$(·cat password.txt)
fi

# Create encrypted.txt if it doesn't exist
touch encrypted.txt

# Create save folder with parent directory if it doesn't exist
save_folder="Encrypted"
if [ "$1" = "-d" ]; then
    save_folder="$2"
    shift 2
fi
mkdir -p "$save_folder"


# For each argument encrypt it with AES-256 and save it to save folder
for file in "$@"; do
    # Get filename from file path
    filename=$(basename "$file")

    # Encrypt filename with AES-256 and base64 encode without line breaks
    encrypted_filename=$(echo "$filename" | openssl enc -aes-256-cbc -a -A -salt -pass pass:"$password")

    # Hash filename with SHA-256 in macOS
    hashed_filename=$(echo "$filename" | shasum -a 256 | cut -d' ' -f1)

   # Prefix current date to hashed filename and append corresponding extension
    final_filename=$(date +%Y%m%d%H%M%S)-$hashed_filename
    if [ -f "$file" ]; then
        final_filename="$final_filename.enc"
    elif [ -d "$file" ]; then
        final_filename="$final_filename.ten"
    fi

    # Encrypt file or folder with AES-256 and save it to save folder
    echo "Encrypting $file..."
    if [ -f "$file" ]; then
        openssl enc -aes-256-cbc -salt -in "$file" -out "$save_folder/$final_filename" -pass pass:"$password"
    elif [ -d "$file" ]; then
        tar -cv --exclude='.DS_Store' "$file" | openssl enc -aes-256-cbc -salt -out "$save_folder/$final_filename" -pass pass:"$password"
    fi

    # Append final filename and encrypted filename to encrypted.txt
    echo "$final_filename $encrypted_filename" >> encrypted.txt
done
