FROM node:18

WORKDIR /app

# Clone and copy files safely (excluding . and ..)
RUN git clone -b v3.x https://github.com/NodeBB/NodeBB.git /tmp/nodebb && \
    shopt -s dotglob && \
    cp -r /tmp/nodebb/* /app && \
    rm -rf /tmp/nodebb && \
    npm install --production

EXPOSE 4567

CMD ["node", "loader.js", "--no-daemon"]
