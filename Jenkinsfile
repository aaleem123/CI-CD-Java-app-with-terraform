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
                    set -e

                    echo "Extracting current version..."
                    version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
                    echo "Current version: $version"

                    IFS='.' read -r major minor patch <<< "$version"
                    new_patch=$((patch + 1))
                    new_version="${major}.${minor}.${new_patch}"

                    echo "Setting new version: $new_version"
                    mvn versions:set -DnewVersion=$new_version
                    mvn versions:commit

                    echo "Pushing updated pom.xml to Git..."
                    git config user.email "ci@example.com"
                    git config user.name "CI Pipeline"
                    git add pom.xml
                    git commit -m "Bump version to $new_version" || echo "No changes to commit"
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
                sh '''
                    set -e
                    version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
                    echo "Building Docker image with tag: $version"
                    docker build -t ${ECR_REPO}:$version .
                    docker tag ${ECR_REPO}:$version ${ECR_REPO}:latest
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${ECR_CREDENTIALS_ID}", usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        set -e
                        echo "Configuring AWS CLI..."
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set region ${AWS_REGION}

                        echo "Authenticating with ECR..."
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}

                        version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

                        echo "Pushing Docker images..."
                        docker push ${ECR_REPO}:$version
                        docker push ${ECR_REPO}:latest
                    '''
                }
            }
        }
    }
}
