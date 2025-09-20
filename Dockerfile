# Stage 1: Builder
FROM node:18 AS builder

# Install dependencies
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone specific stable NodeBB version (v3.0.0)
RUN git clone --depth 1 --branch v3.0.0 https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

WORKDIR /usr/src/nodebb

# Check what was cloned
RUN ls -la && \
    echo "Checking for package.json..." && \
    if [ -f package.json ]; then echo "package.json found!"; cat package.json | head -5; else echo "package.json NOT found!"; fi

# Install NodeBB dependencies (omit dev)
RUN npm install --omit=dev

# Stage 2: Final
FROM node:18

WORKDIR /usr/src/nodebb

# Copy NodeBB from builder
COPY --from=builder /usr/src/nodebb .

# Environment variables (set these in Koyeb or secrets)
ENV DATABASE_HOST=""
ENV DATABASE_USER=""
ENV DATABASE_PASSWORD=""
ENV DATABASE_NAME=""
ENV URL=""
ENV SECRET=""
ENV ADMIN_USERNAME=""
ENV ADMIN_EMAIL=""
ENV ADMIN_PASSWORD=""
ENV DATABASE_PORT="5432"

# Create startup script
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
    echo '    "database": "'"\$DATABASE_NAME"'"' >> /usr/src/nodebb/start.sh && \
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
