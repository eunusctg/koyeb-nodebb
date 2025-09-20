#!/bin/bash
set -e

# Generate config.json from environment variables
/usr/src/nodebb/generate-config.sh

# Check if NodeBB is already installed
if [ ! -f /usr/src/nodebb/config.json ]; then
    echo "Error: config.json was not generated properly"
    exit 1
fi

# Start NodeBB
if [ ! -d /usr/src/nodebb/node_modules ]; then
    echo "Installing NodeBB dependencies..."
    npm install --omit=dev
fi

if [ ! -f /usr/src/nodebb/build/loader.js ]; then
    echo "Building NodeBB..."
    ./nodebb build
fi

# Check if we need to install (first run)
if [ ! -f /usr/src/nodebb/.installed ]; then
    echo "Setting up NodeBB for the first time..."
    
    # Start NodeBB in background for setup
    ./nodebb start &
    NODEBB_PID=$!
    
    # Wait for NodeBB to start
    sleep 10
    
    # Setup admin user if credentials are provided
    if [ ! -z "$ADMIN_USERNAME" ] && [ ! -z "$ADMIN_EMAIL" ] && [ ! -z "$ADMIN_PASSWORD" ]; then
        echo "Creating admin user..."
        ./nodebb setup "$ADMIN_USERNAME" "$ADMIN_EMAIL" "$ADMIN_PASSWORD"
    else
        echo "Admin credentials not provided, manual setup required"
    fi
    
    # Stop the background process
    kill $NODEBB_PID
    wait $NODEBB_PID
    
    touch /usr/src/nodebb/.installed
    echo "NodeBB setup complete"
fi

# Start NodeBB
echo "Starting NodeBB..."
exec ./nodebb start
