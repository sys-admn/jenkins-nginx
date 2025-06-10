FROM nginx:alpine

# Install bash and curl for the status script
RUN apk add --no-cache bash curl

# Copy web files
COPY index.html /usr/share/nginx/html/index.html
COPY status.sh /usr/share/nginx/

# Make the status script executable
RUN chmod +x /usr/share/nginx/status.sh

# Configure Nginx to handle the status endpoint
COPY nginx.conf /etc/nginx/conf.d/default.conf
