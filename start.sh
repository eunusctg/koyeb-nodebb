#!/bin/bash
set -e

# Generate config.json using environment variables
cat <<EOF > config.json
{
  "url": "${URL}",
  "secret": "${SECRET}",
  "database": "postgres",
  "db": {
    "host": "${DATABASE_HOST}",
    "port": ${DATABASE_PORT},
    "username": "${DATABASE_USER}",
    "password": "${DATABASE_PASSWORD}",
    "database": "${DATABASE_NAME}"
  }
}
EOF

# If node_modules are missing, install dependencies
if [ ! -d "node_modules" ]; then
    npm install --omit=dev
fi

# Pre-create admin if it doesn't exist
node app --setup --username="${ADMIN_USERNAME}" --password="${ADMIN_PASSWORD}" --email="${ADMIN_EMAIL}" --isAdmin || true

# Start NodeBB
node app
