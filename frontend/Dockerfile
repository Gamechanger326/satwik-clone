# Use the official Node.js Alpine image as the base image
FROM node:14.16.1-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies using npm
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

ARG REACT_APP_HOST

ENV REACT_APP_HOST $REACT_APP_HOST

## Build the React app with embedded environment variables
#RUN npm run build
#
## Serve the app using a lightweight web server (e.g., serve)
#RUN npm install -g serve

# Set the command to serve the app
CMD ["npm", "start"]
