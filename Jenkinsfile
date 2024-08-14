pipeline {
    agent {
        label unix
    }

    environment {
        AWS_REGION = 'eu-central-1'  // Set your AWS region
        ECR_REPO_URI = '499814927990.dkr.ecr.eu-central-1.amazonaws.com/go-app'  // Replace with your ECR repo URI
        IMAGE_TAG = 'latest'  // Image tag
        K8S_NAMESPACE = 'default'  // Kubernetes namespace
        APP_NAME = 'go-app'  // Application name for deployment
        CHART_DIR = './go-app/go-app-chart'  // Path to the Helm chart in the repository
    }

    stages {

        stage('Build and Push Docker Image to ECR') {
            steps {
                script {
                    // Login to AWS ECR
                    sh '''
                    $(aws ecr get-login-password --region $AWS_REGION | docker login --username davide --password-stdin $ECR_REPO_URI)
                    '''

                    // Build Docker image
                    sh '''
                    docker build -t $ECR_REPO_URI:$IMAGE_TAG go-app
                    '''

                    // Push Docker image to ECR
                    sh '''
                    docker push $ECR_REPO_URI:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes using Helm') {
            steps {
                script {
                    // Deploy the app using Helm
                    sh '''
                    helm upgrade --install $APP_NAME $CHART_DIR \
                    --namespace $K8S_NAMESPACE \
                    '''
                }
            }
        }

        stage('Test the Deployed App') {
            steps {
                script {
                    // Get the Kubernetes service's external IP or LoadBalancer address
                    def externalIP = sh(returnStdout: true, script: "kubectl get svc $APP_NAME -n $K8S_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}'").trim()

                    // Test the application doing a curl
                    sh """
                    curl -v http://$externalIP.svc.cluster.local:80 -kv
                    """
                }
            }
        }

    }

    post {
        always {
            // Clean up Docker images on Jenkins agent (optional)
            sh 'docker system prune -f'
        }
    }
}
