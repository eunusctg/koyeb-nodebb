#!/bin/bash
set -e

# Generate config.json from environment variables
cat > /usr/src/nodebb/config.json << EOF
{
  "url": "$URL",
  "secret": "$SECRET",
  "database": "postgres",
  "postgres": {
    "host": "$DATABASE_HOST",
    "port": "$DATABASE_PORT",
    "username": "$DATABASE_USER",
    "password": "$DATABASE_PASSWORD",
    "database": "$DATABASE_NAME",
    "ssl": true,
    "sslmode": "require"
  }
}
EOF

echo "=== NodeBB Starting ==="
echo "Generated config.json:"
cat /usr/src/nodebb/config.json

# Create a simple health check endpoint that always returns 200 during setup
start_health_server() {
    echo "Starting health check server on port 8080..."
    while true; do
        echo -e "HTTP/1.1 200 OK\n\nNodeBB Setup in Progress" | nc -l -p 8080 -q 1
    done
}

# Start health server in background
start_health_server &

# Install dependencies if not present
if [ ! -d /usr/src/nodebb/node_modules ]; then
    echo "Installing NodeBB dependencies..."
    npm install --omit=dev
fi

# Build NodeBB if not built
if [ ! -f /usr/src/nodebb/build/loader.js ]; then
    echo "Building NodeBB... (This may take several minutes)"
    ./nodebb build
fi

echo "=== FIRST RUN DETECTED ==="
echo "NodeBB setup will take several minutes. Please be patient..."

# Start NodeBB in background to allow setup
echo "Starting NodeBB in background for setup..."
./nodebb start &

# Wait for NodeBB to start and be ready for setup
echo "Waiting for NodeBB to be ready..."
sleep 30

# Check if NodeBB is running and ready for setup
if curl -f http://localhost:4567 > /dev/null 2>&1; then
    echo "NodeBB is running! Please complete setup at:"
    echo "https://piforum.koyeb.app/setup"
    echo ""
    echo "The application will remain running for 1 hour to allow setup."
    echo "After setup, restart the application for normal operation."
    
    # Keep container alive for 1 hour to allow manual setup
    sleep 3600
else
    echo "NodeBB failed to start. Please check logs for errors."
    echo "You can try accessing the setup page directly:"
    echo "https://piforum.koyeb.app/setup"
    
    # Keep container alive for troubleshooting
    sleep 3600
fi
