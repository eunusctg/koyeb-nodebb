FROM node:18

# Install dependencies for NodeBB
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB (include submodules so package.json is present)
RUN git clone --recurse-submodules -b master https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

# Set working directory
WORKDIR /usr/src/nodebb

# Install production dependencies
RUN npm install --omit=dev

# Copy config.json (DB + URL settings)
COPY config.json /usr/src/nodebb/config.json

# Expose NodeBB default port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
