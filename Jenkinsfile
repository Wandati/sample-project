pipeline {
    agent any 
    environment {
        EC2_INSTANCE_IP = "13.247.111.219"  // Updated to your current EC2 IP
        SSH_KEY_PATH = '/var/lib/jenkins/ci-cd-key.pem' 
        AWS_ACCOUNT_ID = credentials('ACCOUNT_ID')
        AWS_ECR_REPO_NAME = credentials('ECR_REPO')
        AWS_DEFAULT_REGION = 'af-south-1'
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/"
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Cleaning Workspace') {
            steps {
                cleanWs()
            }
        }
        
        stage('Checkout from Git') {
            steps {
                git branch: "main", url: 'https://github.com/Wandati/sample-project.git'
            }
        }
        
        stage('Trivy File Scan') {
            steps {
                dir('static') {
                    sh '''
                        trivy fs . \
                            --severity HIGH,CRITICAL \
                            --format table \
                            --output trivyfs.txt
                    '''
                }
            }
        }
        
        stage("Docker Image Build") {
            steps {
                script {
                    sh 'docker system prune -f'
                    sh 'docker container prune -f'
                    sh 'docker build -t ${AWS_ECR_REPO_NAME}:${DOCKER_IMAGE_TAG} .'
                }
            }
        }
        
        stage("ECR Image Pushing") {
            steps {
                script {
                    withAWS(credentials: 'AWS-CREDS', region: "${AWS_DEFAULT_REGION}") {
                        sh '''
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}
                            docker tag ${AWS_ECR_REPO_NAME}:${DOCKER_IMAGE_TAG} ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${DOCKER_IMAGE_TAG}
                            docker push ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${DOCKER_IMAGE_TAG}
                        '''
                    }
                }
            }
        }
        
        stage("TRIVY Image Scan") {
            steps {
                sh '''
                    trivy image \
                        --severity HIGH,CRITICAL \
                        --format table \
                        ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${DOCKER_IMAGE_TAG} \
                        --output trivyimage.txt
                '''
            }
        }
        
        stage('Deploy to EC2') {
            steps {
                script {
                    withAWS(credentials: 'AWS-CREDS', region: "${AWS_DEFAULT_REGION}") {
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${EC2_INSTANCE_IP} << EOF
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
export REPOSITORY_URI=${REPOSITORY_URI}
export AWS_ECR_REPO_NAME=${AWS_ECR_REPO_NAME}
export DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG}

aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}

docker rm -f sample-app || true

docker pull ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${DOCKER_IMAGE_TAG}

docker run -d -p 80:8080 --name sample-app ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${DOCKER_IMAGE_TAG}
EOF
'''
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}