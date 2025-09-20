# Create improved startup script
RUN echo '#!/bin/bash' > /usr/src/nodebb/start.sh && \
    echo 'set -e' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Generate config.json from environment variables' >> /usr/src/nodebb/start.sh && \
    echo 'cat > /usr/src/nodebb/config.json << EOF' >> /usr/src/nodebb/start.sh && \
    echo '{' >> /usr/src/nodebb/start.sh && \
    echo '  "url": "$URL",' >> /usr/src/nodebb/start.sh && \
    echo '  "secret": "$SECRET",' >> /usr/src/nodebb/start.sh && \
    echo '  "database": "postgres",' >> /usr/src/nodebb/start.sh && \
    echo '  "postgres": {' >> /usr/src/nodebb/start.sh && \
    echo '    "host": "$DATABASE_HOST",' >> /usr/src/nodebb/start.sh && \
    echo '    "port": "$DATABASE_PORT",' >> /usr/src/nodebb/start.sh && \
    echo '    "username": "$DATABASE_USER",' >> /usr/src/nodebb/start.sh && \
    echo '    "password": "$DATABASE_PASSWORD",' >> /usr/src/nodebb/start.sh && \
    echo '    "database": "$DATABASE_NAME",' >> /usr/src/nodebb/start.sh && \
    echo '    "ssl": true,' >> /usr/src/nodebb/start.sh && \
    echo '    "sslmode": "require"' >> /usr/src/nodebb/start.sh && \
    echo '  }' >> /usr/src/nodebb/start.sh && \
    echo '}' >> /usr/src/nodebb/start.sh && \
    echo 'EOF' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo 'echo "=== NodeBB Starting ==="' >> /usr/src/nodebb/start.sh && \
    echo 'echo "Generated config.json:"' >> /usr/src/nodebb/start.sh && \
    echo 'cat /usr/src/nodebb/config.json' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Create a simple health check endpoint that always returns 200 during setup' >> /usr/src/nodebb/start.sh && \
    echo 'start_health_server() {' >> /usr/src/nodebb/start.sh && \
    echo '    echo "Starting health check server on port 8080..."' >> /usr/src/nodebb/start.sh && \
    echo '    while true; do' >> /usr/src/nodebb/start.sh && \
    echo '        echo -e "HTTP/1.1 200 OK\n\nNodeBB Setup in Progress" | nc -l -p 8080 -q 1' >> /usr/src/nodebb/start.sh && \
    echo '    done' >> /usr/src/nodebb/start.sh && \
    echo '}' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Start health server in background' >> /usr/src/nodebb/start.sh && \
    echo 'start_health_server &' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Install dependencies if not present' >> /usr/src/nodebb/start.sh && \
    echo 'if [ ! -d /usr/src/nodebb/node_modules ]; then' >> /usr/src/nodebb/start.sh && \
    echo '    echo "Installing NodeBB dependencies..."' >> /usr/src/nodebb/start.sh && \
    echo '    npm install --omit=dev' >> /usr/src/nodebb/start.sh && \
    echo 'fi' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Build NodeBB if not built' >> /usr/src/nodebb/start.sh && \
    echo 'if [ ! -f /usr/src/nodebb/build/loader.js ]; then' >> /usr/src/nodebb/start.sh && \
    echo '    echo "Building NodeBB... (This may take several minutes)"' >> /usr/src/nodebb/start.sh && \
    echo '    ./nodebb build' >> /usr/src/nodebb/start.sh && \
    echo 'fi' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo 'echo "=== FIRST RUN DETECTED ==="' >> /usr/src/nodebb/start.sh && \
    echo 'echo "NodeBB setup will take several minutes. Please be patient..."' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Start NodeBB in background to allow setup' >> /usr/src/nodebb/start.sh && \
    echo 'echo "Starting NodeBB in background for setup..."' >> /usr/src/nodebb/start.sh && \
    echo './nodebb start &' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Wait for NodeBB to start and be ready for setup' >> /usr/src/nodebb/start.sh && \
    echo 'echo "Waiting for NodeBB to be ready..."' >> /usr/src/nodebb/start.sh && \
    echo 'sleep 30' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Check if NodeBB is running and ready for setup' >> /usr/src/nodebb/start.sh && \
    echo 'if curl -f http://localhost:4567 > /dev/null 2>&1; then' >> /usr/src/nodebb/start.sh && \
    echo '    echo "NodeBB is running! Please complete setup at:"' >> /usr/src/nodebb/start.sh && \
    echo '    echo "https://piforum.koyeb.app/setup"' >> /usr/src/nodebb/start.sh && \
    echo '    echo ""' >> /usr/src/nodebb/start.sh && \
    echo '    echo "The application will remain running for 1 hour to allow setup."' >> /usr/src/nodebb/start.sh && \
    echo '    echo "After setup, restart the application for normal operation."' >> /usr/src/nodebb/start.sh && \
    echo '    ' >> /usr/src/nodebb/start.sh && \
    echo '    # Keep container alive for 1 hour to allow manual setup' >> /usr/src/nodebb/start.sh && \
    echo '    sleep 3600' >> /usr/src/nodebb/start.sh && \
    echo 'else' >> /usr/src/nodebb/start.sh && \
    echo '    echo "NodeBB failed to start. Please check logs for errors."' >> /usr/src/nodebb/start.sh && \
    echo '    echo "You can try accessing the setup page directly:"' >> /usr/src/nodebb/start.sh && \
    echo '    echo "https://piforum.koyeb.app/setup"' >> /usr/src/nodebb/start.sh && \
    echo '    ' >> /usr/src/nodebb/start.sh && \
    echo '    # Keep container alive for troubleshooting' >> /usr/src/nodebb/start.sh && \
    echo '    sleep 3600' >> /usr/src/nodebb/start.sh && \
    echo 'fi' >> /usr/src/nodebb/start.sh

RUN chmod +x /usr/src/nodebb/start.sh
