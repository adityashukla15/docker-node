# Use Ubuntu as the base image
FROM ubuntu

# Update the package list
RUN apt-get update

# Install curl
RUN apt-get install -y curl

# Set up the Node.js 18 repository
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

# Upgrade installed packages
RUN apt-get upgrade -y

# Install Node.js
RUN apt-get install -y nodejs

# Copy package.json into the container
COPY package.json package.json

# Copy package-lock.json into the container
COPY package-lock.json package-lock.json

# Copy the application file into the container
COPY index.js index.js

# Install the project dependencies
RUN npm install

# Run the Node.js application when the container starts
ENTRYPOINT [ "node", "index.js" ]