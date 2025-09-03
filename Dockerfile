# Build stage-1
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy built assets from the build stage
COPY --from=build /app/dist ./dist

# Install a simple HTTP server
RUN npm install -g http-server

# Expose port
EXPOSE 8080

# Start the server
CMD ["http-server", "dist", "-p", "8080", "-c-1"]