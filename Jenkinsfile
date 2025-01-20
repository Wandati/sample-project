pipeline {
    agent any 
    environment  {
        EC2_INSTANCE_IP = "13.247.185.39"
        SSH_KEY_PATH = '~/.ssh/ci-cd-key.pem' 
        AWS_ACCOUNT_ID = credentials('ACCOUNT_ID')
        AWS_ECR_REPO_NAME = credentials('ECR_REPO')
        AWS_DEFAULT_REGION = 'af-south-1'
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/"
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
        stage('Trivy File scan'){
            steps {
                sh 'trivy filesystem --exit-code 0 --severity HIGH,CRITICAL --no-progress . > trivyfile.txt'
            }
        }
        
        stage("Docker Image Build") {
            steps {
                script {

                    sh 'docker system prune -f'
                    sh 'docker container prune -f'
                    sh 'docker build -t ${AWS_ECR_REPO_NAME} .'
                    
                }
            }
        }
        stage("ECR Image Pushing") {
            steps {
                script {
                        sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI}'
                        sh 'docker tag ${AWS_ECR_REPO_NAME} ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${BUILD_NUMBER}'
                        sh 'docker push ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${BUILD_NUMBER}'
                }
            }
        }
        stage("TRIVY Image Scan") {
            steps {
                sh 'trivy image ${REPOSITORY_URI}${AWS_ECR_REPO_NAME}:${BUILD_NUMBER} > trivyimage.txt' 
            }
        }
        stage('Deploy to EC2') {
            steps {
                script {
                    // SSH into the EC2 instance and pull the Docker image to run it
                    sh """
                    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ubuntu@${EC2_INSTANCE_IP} << 'EOF'
                    docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${DOCKER_TAG}
                    docker stop sample-app || true
                    docker rm sample-app || true
                    docker run -d --name sample-app -p 80:8080 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${DOCKER_TAG}
                    EOF
                    """
                }
        }
    }
}
