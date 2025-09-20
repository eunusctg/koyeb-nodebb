# Stage 1: Builder
FROM node:18 AS builder

# Install dependencies
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB
RUN git clone --recurse-submodules -b master https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

# Set working directory
WORKDIR /usr/src/nodebb

# Install NodeBB dependencies (omit dev)
RUN npm install --omit=dev

# Stage 2: Final image
FROM node:18

# Set working directory
WORKDIR /usr/src/nodebb

# Copy NodeBB from builder
COPY --from=builder /usr/src/nodebb .

# Environment variables (set these in Koyeb secrets or env)
ENV DATABASE_HOST=""
ENV DATABASE_USER=""
ENV DATABASE_PASSWORD=""
ENV DATABASE_NAME=""
ENV URL=""
ENV SECRET=""
ENV ADMIN_USERNAME=""
ENV ADMIN_EMAIL=""
ENV ADMIN_PASSWORD=""

# Generate config.json dynamically
RUN printf '{
  "url": "%s",
  "secret": "%s",
  "database": "postgres",
  "host": "%s",
  "port": 5432,
  "username": "%s",
  "password": "%s",
  "database_name": "%s",
  "admin": {
    "username": "%s",
    "email": "%s",
    "password": "%s"
  }
}' "$URL" "$SECRET" "$DATABASE_HOST" "$DATABASE_USER" "$DATABASE_PASSWORD" "$DATABASE_NAME" "$ADMIN_USERNAME" "$ADMIN_EMAIL" "$ADMIN_PASSWORD" > /usr/src/nodebb/config.json

# Expose NodeBB default port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
