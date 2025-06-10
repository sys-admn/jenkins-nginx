# CI/CD Pipeline for Nginx Web Application

This project implements a complete CI/CD pipeline for deploying a Nginx web application using Jenkins, SonarQube, Docker, and Terraform. The project is based on [jenkins-nginx](https://github.com/sys-admn/Install-DevOps-tools-with-Docker.git).

## Project Overview

- **Frontend Repository**: [https://github.com/sys-admn/jenkins-nginx.git](https://github.com/sys-admn/jenkins-nginx.git)
- **Containerization**: Docker
- **CI/CD**: Jenkins Pipeline
- **Code Quality**: SonarQube
- **Infrastructure**: Terraform

## Project Structure

- `Dockerfile` - Docker configuration for the Nginx container
- `index.html` - Main web page
- `nginx.conf` - Nginx server configuration
- `status.sh` - Script to check Nginx status
- `Jenkinsfile` - Jenkins pipeline configuration
- `sonar-project.properties` - SonarQube configuration
- `terraform/` - Infrastructure as Code using Terraform

## Prerequisites

- Jenkins server with required plugins
- SonarQube server for code quality analysis
- Docker installed on the target server
- Terraform for infrastructure provisioning
- SSH access to the target server

## Server Requirements

The following setup is required on the target server:

```bash
# Create the deployment directory
sudo mkdir -p /opt/devops-tools/website/
sudo chown ubuntu:ubuntu /opt/devops-tools/website/

# Add the target server to known hosts on Jenkins
ssh-keyscan -H 35.181.166.23 >> ~/.ssh/known_hosts
```

## Jenkins Pipeline Configuration

The CI/CD pipeline includes the following stages:

1. **Checkout**: Clone the code from GitHub
2. **SonarQube Analysis**: Analyze code quality
3. **Terraform**: Provision infrastructure (if needed)
4. **Build**: Build the Docker image
5. **Deploy**: Deploy to the target server

```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/sys-admn/jenkins-nginx.git', branch: 'main'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv(credentialsId: 'sonarqube-Token') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=jenkins-nginx"
                    }
                }
            }
        }
        
        stage('Terraform') {
            steps {
                echo 'Provisioning infrastructure with Terraform...'
                // Add Terraform steps if needed
                // sh 'terraform init && terraform apply -auto-approve'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building the Docker image...'
                // Add build steps if needed
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying to production server...'
                sh '''
                    scp -i /var/jenkins_home/secrets/devops-platform.pem ./* ./status.sh ubuntu@35.181.166.23:/opt/devops-tools/website/
                    
                    ssh -i /var/jenkins_home/secrets/devops-platform.pem ubuntu@35.181.166.23 "cd /opt/devops-tools/website/ && docker build -t nginx-devops . && docker run -d -p 8085:80 --name=nginx nginx-devops"
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline execution failed!'
        }
    }
}
```

## SonarQube Configuration

SonarQube is configured to analyze the code quality:

```properties
sonar.projectKey=jenkins-nginx
sonar.projectName=Jenkins Nginx Application
sonar.sources=.
sonar.exclusions=**/*.md
```

## Terraform Infrastructure

Terraform is used to provision the necessary infrastructure:

- EC2 instance for hosting the application
- Security groups for network access
- Required IAM roles and policies

## Docker Containerization

The application is containerized using Docker:

```dockerfile
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
```

## Security Requirements

1. Create the SSH key file on Jenkins server:
```bash
nano /var/jenkins_home/secrets/devops-platform.pem
```

2. Set proper permissions:
```bash
chmod 600 /var/jenkins_home/secrets/devops-platform.pem
```

## Deployment Process

The complete deployment process:

1. Jenkins checks out the code from the GitHub repository
2. SonarQube analyzes the code for quality issues
3. Terraform provisions or updates the infrastructure (if configured)
4. Jenkins copies all files to the target server
5. The target server builds a Docker image and runs it on port 8085

## Accessing the Application

After successful deployment, the application will be available at:
```
http://35.181.166.23:8085
```

## Troubleshooting

If you encounter issues with the deployment:

1. Check if the SSH key has correct permissions
2. Verify the target server is reachable
3. Ensure Docker is running on the target server
4. Check Jenkins logs for detailed error messages
5. Verify SonarQube token and configuration