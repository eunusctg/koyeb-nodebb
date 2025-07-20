FROM node:18

WORKDIR /app
RUN git clone -b v3.x https://github.com/NodeBB/NodeBB.git . && \
    npm install --production

EXPOSE 4567
CMD ["node", "loader.js", "--no-daemon"]
