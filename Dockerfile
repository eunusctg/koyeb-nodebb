FROM node:18

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone NodeBB repo and move files
RUN git clone -b v3.x https://github.com/NodeBB/NodeBB.git /tmp/nodebb && \
    cp -r /tmp/nodebb/. /app && \
    rm -rf /tmp/nodebb && \
    npm install --production

# Expose NodeBB default port
EXPOSE 4567

# Start NodeBB
CMD ["node", "app.js"]
