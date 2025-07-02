pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "aaleem1993"
        IMAGE_NAME = "twn-project"
        DOCKER_CREDENTIALS_ID = "docker-hub-creds"
    }

    stages {

        stage('Build Java App') {
            steps {
                sh './gradlew build'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: "${DOCKER_CREDENTIALS_ID}", url: "https://index.docker.io/v1/"]) {
                    sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Provision EC2 with Terraform') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy to EC2 with Docker Compose') {
            steps {
                sshagent (credentials: ["ec2-ssh-key"]) {
                    sh '''
                        public_ip=$(terraform -chdir=terraform output -raw public_ip)
                        ssh -o StrictHostKeyChecking=no ec2-user@$public_ip "
                            docker pull aaleem1993/twn-project:latest &&
                            docker-compose down || true &&
                            docker-compose up -d
                        "
                    '''
                }
            }
        }
    }
}
