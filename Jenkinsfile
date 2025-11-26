pipeline {
    agent { label 'AGENT-1' }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_CREDENTIALS_ID = 'aws'
        REPO_ROOT = 'roboshop-dev-infra-jenkis'
    }

    options {
        ansiColor('xterm')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Components List') {
            steps {
                script {
                    env.COMPONENTS = [
                        '00-vpc',
                        '10-sg',
                        '20-bastion',
                        '30-vpn',
                        '40-databases',
                        '50-backend-alb',
                        '60-acm',
                        '70-frontend-alb',
                        '90-components'
                    ].join(',')
                }
            }
        }

        stage('Terraform Run') {
            steps {
                script {
                    def comps = env.COMPONENTS.split(',')

                    for (c in comps) {

                        echo "===== Processing: ${c} ====="

                        dir("${REPO_ROOT}/${c}") {
                            withAWS(credentials: AWS_CREDENTIALS_ID, region: AWS_REGION) {

                                sh "terraform init -input=false -reconfigure"

                                sh "terraform plan -input=false"

                                sh "terraform apply -input=false -auto-approve"
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success { echo "✅ Deployment Completed" }
        failure { echo "❌ Deployment Failed" }
    }
}



