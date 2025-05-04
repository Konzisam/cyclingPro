#!/bin/bash

# Check if the .env file exists
if [ -f .env ]; then

  export $(grep -v '^#' .env | xargs -I {} echo '{}')
  echo "Environment variables loaded from .env file."
else
  echo ".env file not found."
fi
