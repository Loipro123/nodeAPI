# Build stage - use latest Node.js for building
FROM node:25-alpine3.21 AS builder

# Update system packages and remove potentially vulnerable packages
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    # Remove any OPA-related packages that might exist
    apk del --purge $(apk info | grep -i opa || echo "") && \
    rm -rf /var/cache/apk/* /tmp/*

# Set the working directory inside the container
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including dev dependencies for TypeScript build)
RUN npm install && npm cache clean --force

# Copy source code
COPY . .

# Build the TypeScript application
RUN npm run build

# Clean install only production dependencies (removes dev dependencies)
RUN rm -rf node_modules && npm ci --only=production && npm cache clean --force

# Production stage - use latest distroless image with security updates
FROM gcr.io/distroless/nodejs20-debian12:nonroot AS production

# Set working directory
WORKDIR /app

# Copy built application and production dependencies from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Expose the port the app runs on
EXPOSE 3000

# Use distroless nonroot user (already configured)
# Define the command to run the application
CMD ["dist/index.js"]

# Development stage - use latest secure Alpine image
FROM node:25-alpine3.21 AS development

# Update system packages for development and remove OPA
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    apk del --purge $(apk info | grep -i opa || echo "") && \
    rm -rf /var/cache/apk/* /tmp/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm install

# Copy source code
COPY . .

# Switch to non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
RUN chown -R nodejs:nodejs /app
USER nodejs

EXPOSE 3000

CMD ["npm", "run", "dev"]