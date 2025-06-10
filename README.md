# CI/CD Pipeline for Nginx Web Application

This project implements a CI/CD pipeline for deploying a Nginx web application using Jenkins and SonarQube. The project is based on [ci-cd-nginx](https://github.com/sys-admn/ci-cd-nginx).

## Project Structure

- `Dockerfile` - Docker configuration for the Nginx container
- `index.html` - Main web page
- `nginx.conf` - Nginx server configuration
- `status.sh` - Script to check Nginx status

## Prerequisites

- Jenkins server with required plugins
- SonarQube server for code quality analysis
- Docker installed on the target server
- SSH access to the target server

## Server Requirements

The following setup is required on the target server:

```bash
# Create the deployment directory
sudo mkdir -p /opt/devops-tools/website/
sudo chown ubuntu:ubuntu /opt/devops-tools/website/

# Add the target server to known hosts on Jenkins
ssh-keyscan -H <PUBLIC-IP-EC2> >> ~/.ssh/known_hosts
```

## Jenkins Pipeline Configuration

1. Create a new Jenkins pipeline job
2. Configure the pipeline to use SCM (Source Code Management)
3. Add the following Jenkinsfile to your repository:

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
                    withSonarQubeEnv(credentialsId: 'sonarqube-Token')  {
                          sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=jenkins-nginx"
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building the application...'
                // Add build steps if needed
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying to production server...'
                sh '''
                    scp -i /var/jenkins_home/secrets/devops-platform.pem ./* ./status.sh ubuntu@<PUBLIC-IP-EC2>:/opt/devops-tools/website/
                    
                    ssh -i /var/jenkins_home/secrets/devops-platform.pem ubuntu@<PUBLIC-IP-EC2> "cd /opt/devops-tools/website/ && docker build -t nginx-devops . && docker run -d -p 8085:80 --name=nginx nginx-devops"
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

Create a `sonar-project.properties` file in your repository:

```properties
sonar.projectKey=nginx-web-app
sonar.projectName=Nginx Web Application
sonar.sources=.
sonar.exclusions=**/*.md
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

The deployment process:

1. Jenkins checks out the code from the repository
2. SonarQube analyzes the code for quality issues
3. Jenkins copies all files to the target server
4. The target server builds a Docker image and runs it on port 8085

## Accessing the Application

After successful deployment, the application will be available at:
```
http://<PUBLIC-IP-EC2>:8085
```

## Troubleshooting

If you encounter issues with the deployment:

1. Check if the SSH key has correct permissions
2. Verify the target server is reachable
3. Ensure Docker is running on the target server
4. Check Jenkins logs for detailed error messages
