# ... previous Dockerfile content remains the same ...

# Create startup script with SSL configuration
RUN echo '#!/bin/bash' > /usr/src/nodebb/start.sh && \
    echo 'set -e' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Generate config.json from environment variables' >> /usr/src/nodebb/start.sh && \
    echo 'cat > /usr/src/nodebb/config.json << EOF' >> /usr/src/nodebb/start.sh && \
    echo '{' >> /usr/src/nodebb/start.sh && \
    echo '  "url": "'"\$URL"'",' >> /usr/src/nodebb/start.sh && \
    echo '  "secret": "'"\$SECRET"'",' >> /usr/src/nodebb/start.sh && \
    echo '  "database": "postgres",' >> /usr/src/nodebb/start.sh && \
    echo '  "postgres": {' >> /usr/src/nodebb/start.sh && \
    echo '    "host": "'"\$DATABASE_HOST"'",' >> /usr/src/nodebb/start.sh && \
    echo '    "port": "'"\$DATABASE_PORT"'",' >> /usr/src/nodebb/start.sh && \
    echo '    "username": "'"\$DATABASE_USER"'",' >> /usr/src/nodebb/start.sh && \
    echo '    "password": "'"\$DATABASE_PASSWORD"'",' >> /usr/src/nodebb/start.sh && \
    echo '    "database": "'"\$DATABASE_NAME"'",' >> /usr/src/nodebb/start.sh && \
    echo '    "ssl": true,' >> /usr/src/nodebb/start.sh && \
    echo '    "sslmode": "require"' >> /usr/src/nodebb/start.sh && \
    echo '  }' >> /usr/src/nodebb/start.sh && \
    echo '}' >> /usr/src/nodebb/start.sh && \
    echo 'EOF' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo 'echo "Generated config.json:"' >> /usr/src/nodebb/start.sh && \
    echo 'cat /usr/src/nodebb/config.json' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Install dependencies if not present' >> /usr/src/nodebb/start.sh && \
    echo 'if [ ! -d /usr/src/nodebb/node_modules ]; then' >> /usr/src/nodebb/start.sh && \
    echo '    echo "Installing NodeBB dependencies..."' >> /usr/src/nodebb/start.sh && \
    echo '    npm install --omit=dev' >> /usr/src/nodebb/start.sh && \
    echo 'fi' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Build NodeBB if not built' >> /usr/src/nodebb/start.sh && \
    echo 'if [ ! -f /usr/src/nodebb/build/loader.js ]; then' >> /usr/src/nodebb/start.sh && \
    echo '    echo "Building NodeBB..."' >> /usr/src/nodebb/start.sh && \
    echo '    ./nodebb build' >> /usr/src/nodebb/start.sh && \
    echo 'fi' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Check if this is the first run' >> /usr/src/nodebb/start.sh && \
    echo 'if [ ! -f /usr/src/nodebb/.installed ]; then' >> /usr/src/nodebb/start.sh && \
    echo '    echo "First run detected. Setting up NodeBB..."' >> /usr/src/nodebb/start.sh && \
    echo '    ' >> /usr/src/nodebb/start.sh && \
    echo '    # Setup with environment variables or manually' >> /usr/src/nodebb/start.sh && \
    echo '    if [ ! -z "\$ADMIN_USERNAME" ] && [ ! -z "\$ADMIN_EMAIL" ] && [ ! -z "\$ADMIN_PASSWORD" ]; then' >> /usr/src/nodebb/start.sh && \
    echo '        echo "Setting up with provided admin credentials..."' >> /usr/src/nodebb/start.sh && \
    echo '        ./nodebb setup "\$ADMIN_USERNAME" "\$ADMIN_EMAIL" "\$ADMIN_PASSWORD"' >> /usr/src/nodebb/start.sh && \
    echo '    else' >> /usr/src/nodebb/start.sh && \
    echo '        echo "Please run setup manually when NodeBB starts"' >> /usr/src/nodebb/start.sh && \
    echo '    fi' >> /usr/src/nodebb/start.sh && \
    echo '    ' >> /usr/src/nodebb/start.sh && \
    echo '    touch /usr/src/nodebb/.installed' >> /usr/src/nodebb/start.sh && \
    echo 'fi' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo 'echo "Starting NodeBB..."' >> /usr/src/nodebb/start.sh && \
    echo 'exec ./nodebb start' >> /usr/src/nodebb/start.sh

RUN chmod +x /usr/src/nodebb/start.sh

# Expose NodeBB default port
EXPOSE 4567

# Run the setup script on container start
CMD ["/usr/src/nodebb/start.sh"]
