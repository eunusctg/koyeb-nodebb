#!/bin/bash
set -e

# Generate config.json from environment variables
/usr/src/nodebb/generate-config.sh

echo "Generated config.json:"
cat /usr/src/nodebb/config.json

# Install dependencies if not present
if [ ! -d /usr/src/nodebb/node_modules ]; then
    echo "Installing NodeBB dependencies..."
    npm install --omit=dev
fi

# Build NodeBB if not built
if [ ! -f /usr/src/nodebb/build/loader.js ]; then
    echo "Building NodeBB..."
    ./nodebb build
fi

# Check if this is the first run
if [ ! -f /usr/src/nodebb/.installed ]; then
    echo "First run detected. Setting up NodeBB..."
    
    # Setup with environment variables or manually
    if [ ! -z "$ADMIN_USERNAME" ] && [ ! -z "$ADMIN_EMAIL" ] && [ ! -z "$ADMIN_PASSWORD" ]; then
        echo "Setting up with provided admin credentials..."
        ./nodebb setup "$ADMIN_USERNAME" "$ADMIN_EMAIL" "$ADMIN_PASSWORD"
    else
        echo "Please run setup manually when NodeBB starts"
    fi
    
    touch /usr/src/nodebb/.installed
fi

echo "Starting NodeBB..."
exec ./nodebb start
