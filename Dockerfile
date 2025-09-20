# Node.js base image
FROM node:18

# Install dependencies
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB
RUN git clone --recurse-submodules -b master https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

# Set working directory
WORKDIR /usr/src/nodebb

# Install NodeBB dependencies
RUN npm install --omit=dev

# Generate config.json inside the container
RUN echo '{
  "url": "https://piforum.koyeb.app",
  "secret": "piforum_super_secret_key_123456789",
  "database": "postgres",
  "port": "4567",
  "bind_address": "0.0.0.0",
  "postgres": {
    "host": "ep-muddy-hall-a4xfddxq.us-east-1.pg.koyeb.app",
    "port": "5432",
    "username": "koyeb-adm",
    "password": "npg_3taSXcbxYvU2",
    "database": "koyebdb",
    "ssl": true
  }
}' > /usr/src/nodebb/config.json

# Expose NodeBB port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
