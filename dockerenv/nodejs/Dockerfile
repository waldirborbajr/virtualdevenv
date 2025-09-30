# Use a lightweight Node.js base image
FROM node:18-alpine

# Install yarn
# RUN apk add --no-cache yarn

# Set working directory inside the container
WORKDIR /app

# Copy package.json and yarn.lock (if exists) to install dependencies
COPY package.json yarn.lock* ./

# Install dependencies with yarn
RUN yarn install

# Expose the port used by webpack-dev-server
EXPOSE 8080

# Command to install dependencies and start the development server
CMD ["sh", "-c", "yarn install && yarn start"]
