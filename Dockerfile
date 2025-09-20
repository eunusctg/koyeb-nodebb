# Copy NodeBB source
COPY . /usr/src/nodebb

# Set working directory
WORKDIR /usr/src/nodebb

# Copy startup script
COPY start.sh /usr/src/nodebb/start.sh
RUN chmod +x start.sh

# Default command
CMD ["./start.sh"]
