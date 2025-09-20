# Stage 1: Build NodeBB
FROM node:18 AS builder

RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB source
RUN git clone --recurse-submodules -b master https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

WORKDIR /usr/src/nodebb

# Install dependencies (production only)
RUN npm install --omit=dev

# Stage 2: Runtime
FROM node:18

WORKDIR /usr/src/nodebb

COPY --from=builder /usr/src/nodebb .

# Copy config.json template
COPY config.json .

# Expose port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
