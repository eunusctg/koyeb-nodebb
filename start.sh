#!/bin/bash
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

# Install dependencies
npm install --omit=dev

# If admin does not exist, create it
node app --setup --username="${ADMIN_USERNAME}" --password="${ADMIN_PASSWORD}" --email="${ADMIN_EMAIL}" --isAdmin

# Start NodeBB
node app
