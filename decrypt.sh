#!/bin/sh

# This script decrypts files with AES-256. The password can be set in
# password.txt under the current directory. If password.txt doesn't exist or is
# empty, the script will ask for it first. During decryption, the filename need
# to be decrypted from encrypted.txt before decrypting the file. The saving
# folder for decrypted files can be set with -d option and the default is
# Decrypted. To decrypt all filenames in encrypted.txt, use -filenames option.
#
# Usage: ./decrypt.sh [-d path] [-filenames] file1 file2 file3 ...

# Ask for password if password.txt doesn't exist or is empty, otherwise read it
if [ ! -f password.txt ] || [ -z "$(cat password.txt)" ]; then
    # Ask for password and check if it's not empty
    while true; do
        read -s -p "Enter password: " password
        echo
        if [ -n "$password" ]; then
            break
        else
            echo "Password can't be empty. Try again."
        fi
    done
else
    password=$(cat password.txt)
fi

# Check if encrypted.txt exists
if [ ! -f encrypted.txt ]; then
    echo "encrypted.txt not found!"
    exit 1
fi

# Set default save folder to Decrypted
save_folder="Decrypted"

# Process all options before arguments
while [ "$1" != "" ]; do
    case $1 in
        -d )            shift
                        save_folder="$1"
                        shift
                        ;;
        -filenames )    shift
                        # Decrypt all filenames in encrypted.txt to encrypted-raw.txt
                        echo "Decrypting filenames..."
                        touch encrypted-raw.txt
                        while read line; do
                            # Get final filename from line
                            final_filename=$(echo "$line" | cut -d' ' -f1)

                            # Get encrypted filename from line
                            encrypted_filename=$(echo "$line" | cut -d' ' -f2)

                            # Decrypt encrypted filename with AES-256 and base64 decode
                            decrypted_filename=$(echo "$encrypted_filename" | openssl enc -aes-256-cbc -a -d -pass pass:"$password")

                            # Append final filename and decrypted filename to encrypted-raw.txt
                            echo "$final_filename $decrypted_filename" >> encrypted-raw.txt
                        done < encrypted.txt
                        ;;
        * )             break
    esac
done

# Create save folder with parent directory if it doesn't exist
mkdir -p "$save_folder"

# For each argument decrypt it with AES-256 and save it to save folder
for file in "$@"; do
    # Get final filename from file path
    final_filename=$(basename "$file")

    # Decrypt file with AES-256 and save it to save folder
    echo "Decrypting $file..."
    if [[ "$final_filename" == *.enc ]]; then
        # Get encrypted filename from encrypted.txt
        encrypted_filename=$(grep "$final_filename" encrypted.txt | cut -d' ' -f2)

        # Decrypt encrypted filename with AES-256 and base64 decode
        decrypted_filename=$(echo "$encrypted_filename" | openssl enc -aes-256-cbc -a -d -pass pass:"$password")

        openssl enc -aes-256-cbc -d -in "$file" -out "$save_folder/$decrypted_filename" -pass pass:"$password"
    elif [[ "$final_filename" == *.ten ]]; then
        openssl enc -aes-256-cbc -d -in "$file" -out "$save_folder/$final_filename" -pass pass:"$password"

        # Extract tar file and remove it
        echo "Extracting $file..."
        tar -xvf "$save_folder/$final_filename" -C "$save_folder"
        rm "$save_folder/$final_filename"
    fi
done
