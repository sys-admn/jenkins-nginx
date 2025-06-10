#!/bin/bash

# Check if Nginx is running in Docker
NGINX_RUNNING=$(docker ps --filter "name=nginx-app" --format "{{.Status}}" | grep -c "Up")

# Output JSON response
if [ "$NGINX_RUNNING" -gt 0 ]; then
    echo '{"status":"running"}'
else
    echo '{"status":"stopped"}'
fi