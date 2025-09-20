# Stage 1: Builder
FROM node:18 AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Clone NodeBB
RUN git clone --recurse-submodules -b master https://github.com/NodeBB/NodeBB.git /usr/src/nodebb

# Set working directory
WORKDIR /usr/src/nodebb

# Install NodeBB dependencies
RUN npm install --omit=dev

# Copy startup script
COPY start.sh /usr/src/nodebb/start.sh
RUN chmod +x start.sh

# Expose default NodeBB port
EXPOSE 4567

# Start NodeBB with pre-created admin
CMD ["./start.sh"]
