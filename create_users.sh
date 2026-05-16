#!/bin/bash

if [ $UID -gt 0 ]; then
    echo "Error: User is not eligible to run the script"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "No users provided"
    exit 1
fi
