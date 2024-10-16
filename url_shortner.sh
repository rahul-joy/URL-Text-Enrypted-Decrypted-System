#!/bin/bash

# File to store the original URLs and shortened codes
DATABASE_FILE="urls.txt"

# Function to generate a random 6-character short code
generate_short_url() {
    local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local short_url=""
    for i in {1..6}; do
        short_url="$short_url${chars:RANDOM%${#chars}:1}"
    done
    echo "$short_url"
}

# Function to shorten a URL and store it in the database
shorten_url() {
    echo -n "Enter the URL to shorten: "
    read original_url

    # Check if the URL is already in the database
    if grep -q "|$original_url" "$DATABASE_FILE"; then
        short_url=$(grep "|$original_url" "$DATABASE_FILE" | cut -d'|' -f1)
        echo "This URL is already shortened. Short URL is: $short_url"
    else
        # Generate a unique short URL
        short_url=$(generate_short_url)

        # Ensure no collision of short codes
        while grep -q "$short_url|" "$DATABASE_FILE"; do
            short_url=$(generate_short_url)
        done

        # Save the short URL and original URL to the database
        echo "$short_url|$original_url" >> "$DATABASE_FILE"
        echo "Shortened URL is: $short_url"
    fi
}

# Function to retrieve the original URL based on the short URL code
retrieve_url() {
    echo -n "Enter the short URL code: "
    read short_url

    if grep -q "^$short_url|" "$DATABASE_FILE"; then
        original_url=$(grep "^$short_url|" "$DATABASE_FILE" | cut -d'|' -f2)
        echo "The original URL is: $original_url"
    else
        echo "No URL found for the short code: $short_url"
    fi
}

# Function to list all URLs stored in the database
list_urls() {
    if [ ! -s "$DATABASE_FILE" ]; then
        echo "No URLs found."
    else
        echo "Stored URLs:"
        while IFS='|' read -r short_url original_url; do
            echo "Short URL: $short_url -> Original URL: $original_url"
        done < "$DATABASE_FILE"
    fi
}

# Main menu function
menu() {
    while true; do
        echo ""
        echo "--- URL Shortener ---"
        echo "1. Shorten a URL"
        echo "2. Retrieve original URL"
        echo "3. List all URLs"
        echo "4. Exit"

        echo -n "Enter your choice: "
        read choice

        case "$choice" in
            1) shorten_url ;;
            2) retrieve_url ;;
            3) list_urls ;;
            4) echo "Exiting..."; break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

# Create the database file if it doesn't exist
if [ ! -f "$DATABASE_FILE" ]; then
    touch "$DATABASE_FILE"
fi

# Run the program
menu
