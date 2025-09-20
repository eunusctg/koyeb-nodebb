# Use Node 18 base image
FROM node:18

# Install dependencies
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB from the correct branch (master)
RUN git clone --recurse-submodules -b master https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

# Set working directory
WORKDIR /usr/src/nodebb

# Install NodeBB dependencies
RUN npm install --production

# Generate config.json with preconfigured DB + URL
RUN printf '{
  "url": "https://piforum.koyeb.app",
  "secret": "piforum_super_secret_key_123456789",
  "database": "postgres",
  "postgres": {
    "host": "ep-muddy-hall-a4xfddxq.us-east-1.pg.koyeb.app",
    "port": "5432",
    "username": "koyeb-adm",
    "password": "npg_3taSXcbxYvU2",
    "database": "koyebdb"
  }
}' > config.json

# Build assets
RUN ./nodebb build

# Expose NodeBB default port
EXPOSE 4567

# Start NodeBB with admin auto-setup
CMD ["bash", "-c", "node ./nodebb setup \
  --admin:username=$ADMIN_USER \
  --admin:email=$ADMIN_EMAIL \
  --admin:password=$ADMIN_PASS \
  --admin:password:confirm=$ADMIN_PASS && \
  node app.js"]
