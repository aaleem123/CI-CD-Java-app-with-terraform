pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '682475225405.dkr.ecr.us-east-1.amazonaws.com/java-maven-app'
        GIT_CREDENTIALS_ID = 'git-ssh'
        ECR_CREDENTIALS_ID = 'aws-ecr-creds'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'git@github.com:aaleem123/CI-CD-Pipeline-with-EKS-and-AWS-ECR.git',
                        credentialsId: "${GIT_CREDENTIALS_ID}"
                    ]]
                ])
            }
        }

        stage('Increment Version') {
            steps {
                sh '''
                    mvn build-helper:parse-version versions:set \
                    -DnewVersion=${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion} \
                    versions:commit

                    git config user.email "ci@example.com"
                    git config user.name "CI Pipeline"
                    git add pom.xml
                    git commit -m "Bump version"
                    git push origin HEAD:main
                '''
            }
        }

        stage('Build Spring Boot Jar') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${ECR_REPO}:latest ."
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${ECR_CREDENTIALS_ID}", usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set region ${AWS_REGION}
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                        docker push ${ECR_REPO}:latest
                    '''
                }
            }
        }
    }
}
