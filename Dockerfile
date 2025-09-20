FROM node:18

# Install dependencies required for building NodeBB
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB from main branch
RUN git clone --recurse-submodules -b main https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

# Set working directory
WORKDIR /usr/src/nodebb

# Install production dependencies
RUN npm install --omit=dev

# Generate config.json for NodeBB
RUN printf '{\n\
  "url": "https://piforum.koyeb.app",\n\
  "secret": "piforum_super_secret_key_123456789",\n\
  "database": "postgres",\n\
  "port": "4567",\n\
  "postgres": {\n\
    "host": "ep-muddy-hall-a4xfddxq.us-east-1.pg.koyeb.app",\n\
    "port": "5432",\n\
    "username": "koyeb-adm",\n\
    "password": "npg_3taSXcbxYvU2",\n\
    "database": "koyebdb",\n\
    "ssl": true\n\
  }\n\
}' > /usr/src/nodebb/config.json

# Create admin account on first run
RUN node app --setup <<< $'\
{\n\
  "admin:username": "admin",\n\
  "admin:email": "admin@piforum.local",\n\
  "admin:password": "AdminPass123",\n\
  "admin:password:confirm": "AdminPass123"\n\
}\n'

# Expose NodeBB port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
