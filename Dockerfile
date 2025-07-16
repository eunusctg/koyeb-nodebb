FROM node:18

# Set working directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the code
COPY . .

# Expose the port NodeBB runs on
EXPOSE 4567

# Run NodeBB setup automatically with default or environment values
RUN yes | ./nodebb setup

# Start NodeBB
CMD ["./nodebb", "start"]
