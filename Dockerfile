# -------------------------
# Stage 1: Build NodeBB
# -------------------------
FROM node:18 as builder

# Install required dependencies
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB (master branch, not main)
RUN git clone --recurse-submodules -b master https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

WORKDIR /usr/src/nodebb

# Install NodeBB dependencies
RUN npm install --omit=dev


# -------------------------
# Stage 2: Runtime
# -------------------------
FROM node:18

WORKDIR /usr/src/nodebb

# Copy NodeBB from builder stage
COPY --from=builder /usr/src/nodebb ./

# Generate config.json with DB + URL
RUN printf '{\n\
  "url": "https://piforum.koyeb.app",\n\
  "secret": "piforum_super_secret_key_123456789",\n\
  "database": "postgres",\n\
  "postgres": {\n\
    "host": "ep-muddy-hall-a4xfddxq.us-east-1.pg.koyeb.app",\n\
    "port": "5432",\n\
    "username": "koyeb-adm",\n\
    "password": "npg_3taSXcbxYvU2",\n\
    "database": "koyebdb"\n\
  }\n\
}' > config.json

# Create preconfigured admin user (email + pass)
RUN node app --setup '{"admin:username":"admin","admin:password":"Admin123","admin:email":"admin@piforum.koyeb.app"}'

# Expose NodeBB default port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
