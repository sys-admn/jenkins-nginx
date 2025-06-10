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