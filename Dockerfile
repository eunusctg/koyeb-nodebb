FROM node:18

# Install dependencies
RUN apt-get update && apt-get install -y git python3 build-essential && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone NodeBB directly into /app
RUN git clone -b v3.x https://github.com/NodeBB/NodeBB.git /app

# Install production dependencies
RUN npm install --production

# Expose NodeBB default port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
