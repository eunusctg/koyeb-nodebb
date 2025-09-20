# Stage 1: Builder
FROM node:18 AS builder

# Install dependencies including development tools
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone specific stable NodeBB version (v2.8.0)
RUN git clone --depth 1 --branch v2.8.0 https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

WORKDIR /usr/src/nodebb

# Check if package.json exists in root, if not copy from install/
RUN if [ -f package.json ]; then \
        echo "package.json found in root directory!"; \
    else \
        echo "package.json not in root, checking install/ directory..."; \
        if [ -f ./install/package.json ]; then \
            echo "Moving package.json from install/ to root..." && \
            cp ./install/package.json . && \
            echo "package.json moved to root directory"; \
        else \
            echo "ERROR: package.json not found anywhere!"; \
            exit 1; \
        fi; \
    fi

# Install all dependencies (including dev dependencies for build)
RUN npm install

# Try to build using NodeBB's own build script with a timeout
RUN echo "Building NodeBB assets..." && \
    timeout 300s ./nodebb build --series || \
    (echo "Build timed out or failed, trying alternative approach..." && \
     echo "Skipping build step - will build at runtime")

# Stage 2: Final
FROM node:18-slim

WORKDIR /usr/src/nodebb

# Copy NodeBB from builder
COPY --from=builder /usr/src/nodebb .

# Install curl for health checks and build essentials for runtime build
RUN apt-get update && apt-get install -y curl python3 build-essential && rm -rf /var/lib/apt/lists/*

# Environment variables (set these in Koyeb or secrets)
ENV NODE_ENV="production"
ENV URL="http://localhost:4567"
ENV SECRET="change-this-to-a-random-secret"

# Create a script to handle configuration
RUN echo '#!/bin/bash' > /usr/src/nodebb/configure.sh && \
    echo 'set -e' >> /usr/src/nodebb/configure.sh && \
    echo '' >> /usr/src/nodebb/configure.sh && \
    echo '# Wait for environment variables to be injected' >> /usr/src/nodebb/configure.sh && \
    echo 'echo "Waiting for environment variables to be available..."' >> /usr/src/nodebb/configure.sh && \
    echo 'sleep 5' >> /usr/src/nodebb/configure.sh && \
    echo '' >> /usr/src/nodebb/configure.sh && \
    echo '# Check if config already exists' >> /usr/src/nodebb/configure.sh && \
    echo 'if [ ! -f /usr/src/nodebb/config.json ]; then' >> /usr/src/nodebb/configure.sh && \
    echo '    echo "Generating config.json from environment variables..."' >> /usr/src/nodebb/configure.sh && \
    echo '    node -e "' >> /usr/src/nodebb/configure.sh && \
    echo '        const fs = require(\"fs\");' >> /usr/src/nodebb/configure.sh && \
    echo '        const config = {' >> /usr/src/nodebb/configure.sh && \
    echo '            url: process.env.URL || \"http://localhost:4567\",' >> /usr/src/nodebb/configure.sh && \
    echo '            secret: process.env.SECRET || \"change-this-to-a-random-secret\",' >> /usr/src/nodebb/configure.sh && \
    echo '            database: \"postgres\",' >> /usr/src/nodebb/configure.sh && \
    echo '            postgres: {' >> /usr/src/nodebb/configure.sh && \
    echo '                host: process.env.DATABASE_HOST,' >> /usr/src/nodebb/configure.sh && \
    echo '                port: process.env.DATABASE_PORT || 5432,' >> /usr/src/nodebb/configure.sh && \
    echo '                username: process.env.DATABASE_USER,' >> /usr/src/nodebb/configure.sh && \
    echo '                password: process.env.DATABASE_PASSWORD,' >> /usr/src/nodebb/configure.sh && \
    echo '                database: process.env.DATABASE_NAME,' >> /usr/src/nodebb/configure.sh && \
    echo '                ssl: true,' >> /usr/src/nodebb/configure.sh && \
    echo '                sslmode: \"require\"' >> /usr/src/nodebb/configure.sh && \
    echo '            }' >> /usr/src/nodebb/configure.sh && \
    echo '        };' >> /usr/src/nodebb/configure.sh && \
    echo '        fs.writeFileSync(\"/usr/src/nodebb/config.json\", JSON.stringify(config, null, 2));' >> /usr/src/nodebb/configure.sh && \
    echo '    "' >> /usr/src/nodebb/configure.sh && \
    echo '    echo "Config file generated successfully"' >> /usr/src/nodebb/configure.sh && \
    echo 'else' >> /usr/src/nodebb/configure.sh && \
    echo '    echo "Using existing config.json"' >> /usr/src/nodebb/configure.sh && \
    echo 'fi' >> /usr/src/nodebb/configure.sh

RUN chmod +x /usr/src/nodebb/configure.sh

# Create startup script that builds at runtime if needed
RUN echo '#!/bin/bash' > /usr/src/nodebb/start.sh && \
    echo 'set -e' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Generate configuration' >> /usr/src/nodebb/start.sh && \
    echo '/usr/src/nodebb/configure.sh' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Install production dependencies only' >> /usr/src/nodebb/start.sh && \
    echo 'if [ ! -d /usr/src/nodebb/node_modules ]; then' >> /usr/src/nodebb/start.sh && \
    echo '    echo "Installing NodeBB production dependencies..."' >> /usr/src/nodebb/start.sh && \
    echo '    npm install --omit=dev' >> /usr/src/nodebb/start.sh && \
    echo 'fi' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Build NodeBB if not built (this may take several minutes)' >> /usr/src/nodebb/start.sh && \
    echo 'if [ ! -f /usr/src/nodebb/build/loader.js ]; then' >> /usr/src/nodebb/start.sh && \
    echo '    echo "Building NodeBB at runtime... (This may take several minutes)"' >> /usr/src/nodebb/start.sh && \
    echo '    ./nodebb build --series' >> /usr/src/nodebb/start.sh && \
    echo 'fi' >> /usr/src/nodebb/start.sh && \
    echo '' >> /usr/src/nodebb/start.sh && \
    echo '# Start NodeBB' >> /usr/src/nodebb/start.sh && \
    echo 'echo "Starting NodeBB..."' >> /usr/src/nodebb/start.sh && \
    echo 'exec ./nodebb start' >> /usr/src/nodebb/start.sh

RUN chmod +x /usr/src/nodebb/start.sh

# Expose NodeBB port
EXPOSE 4567

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=300s --retries=3 \
    CMD curl -f http://localhost:4567 || exit 1

# Run the startup script
CMD ["/usr/src/nodebb/start.sh"]
