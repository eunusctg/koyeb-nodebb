FROM node:18

# Install dependencies required for building NodeBB
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB from main branch
RUN git clone --recurse-submodules -b main https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

# Set working directory
WORKDIR /usr/src/nodebb

# Copy package.json & package-lock.json first for caching npm install
COPY --from=0 /usr/src/nodebb/package*.json ./

# Install production dependencies (cached if package.json unchanged)
RUN npm install --omit=dev

# Copy the rest of the NodeBB source
COPY --from=0 /usr/src/nodebb ./

# Expose NodeBB port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
