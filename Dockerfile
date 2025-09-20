FROM node:18

# Install dependencies for NodeBB
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB (use master branch, which exists)
RUN git clone --recurse-submodules -b master https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

# Set working directory
WORKDIR /usr/src/nodebb

# Install production dependencies
RUN npm install --omit=dev

# Generate config.json inside the container
RUN printf '{\n\
  "url": "https://piforum.koyeb.app",\n\
  "secret": "piforum_super_secret_key_123456789",\n\
  "database": "postgres",\n\
  "port": "4567",\n\
  "bind_address": "0.0.0.0",\n\
  "postgres": {\n\
    "host": "ep-muddy-hall-a4xfddxq.us-east-1.pg.koyeb.app",\n\
    "port": "5432",\n\
    "username": "koyeb-adm",\n\
    "password": "npg_3taSXcbxYvU2",\n\
    "database": "koyebdb",\n\
    "ssl": true\n\
  }\n\
}' > /usr/src/nodebb/config.json

# Expose NodeBB default port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
