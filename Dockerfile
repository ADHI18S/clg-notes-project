# Use the official Ubuntu base image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y nginx

# Remove the default Nginx index page
RUN rm /var/www/html/index.nginx-debian.html

# Copy the custom HTML file to the web server's root directory
COPY project.html /var/www/html/

# Expose port 80 to allow external traffic
EXPOSE 80

# Start Nginx in the foreground (necessary for Docker to keep the container running)
CMD ["nginx", "-g", "daemon off;"]
