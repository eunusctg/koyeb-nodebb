# Stage 1: Builder
FROM node:18 AS builder

# Install dependencies
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB
RUN git clone --recurse-submodules -b master https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

WORKDIR /usr/src/nodebb

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

# Copy startup script
COPY start.sh /usr/src/nodebb/start.sh
RUN chmod +x /usr/src/nodebb/start.sh

# Create a script to generate config.json at runtime
RUN echo '#!/bin/bash' > /usr/src/nodebb/generate-config.sh && \
    echo 'cat > /usr/src/nodebb/config.json << EOF' >> /usr/src/nodebb/generate-config.sh && \
    echo '{' >> /usr/src/nodebb/generate-config.sh && \
    echo '  "url": "'"$URL"'",' >> /usr/src/nodebb/generate-config.sh && \
    echo '  "secret": "'"$SECRET"'",' >> /usr/src/nodebb/generate-config.sh && \
    echo '  "database": "postgres",' >> /usr/src/nodebb/generate-config.sh && \
    echo '  "postgres": {' >> /usr/src/nodebb/generate-config.sh && \
    echo '    "host": "'"$DATABASE_HOST"'",' >> /usr/src/nodebb/generate-config.sh && \
    echo '    "port": "'"$DATABASE_PORT"'",' >> /usr/src/nodebb/generate-config.sh && \
    echo '    "username": "'"$DATABASE_USER"'",' >> /usr/src/nodebb/generate-config.sh && \
    echo '    "password": "'"$DATABASE_PASSWORD"'",' >> /usr/src/nodebb/generate-config.sh && \
    echo '    "database": "'"$DATABASE_NAME"'"' >> /usr/src/nodebb/generate-config.sh && \
    echo '  }' >> /usr/src/nodebb/generate-config.sh && \
    echo '}' >> /usr/src/nodebb/generate-config.sh && \
    echo 'EOF' >> /usr/src/nodebb/generate-config.sh

RUN chmod +x /usr/src/nodebb/generate-config.sh

# Expose NodeBB default port
EXPOSE 4567

# Run the setup script on container start
CMD ["/usr/src/nodebb/start.sh"]
