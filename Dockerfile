FROM node:18

WORKDIR /app

# Clone into a temporary directory to avoid nuking working dir
RUN git clone -b v3.x https://github.com/NodeBB/NodeBB.git /tmp/nodebb && \
    mv /tmp/nodebb/* /app && \
    mv /tmp/nodebb/.* /app || true && \
    rm -rf /tmp/nodebb && \
    npm install --production

EXPOSE 4567

CMD ["node", "loader.js", "--no-daemon"]
