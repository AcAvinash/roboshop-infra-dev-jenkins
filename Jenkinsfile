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
                    components = [
                        '00-vpc',
                        '10-sg',
                        '20-bastion',
                        '30-vpn',
                        '40-databases',
                        '50-backend-alb',
                        '60-acm',
                        '70-frontend-alb',
                        '90-components'
                    ]
                    env.COMPONENTS = components.join(',')
                }
            }
        }

        stage('Terraform: Sequential Deploy') {
            steps {
                script {
                    def comps = env.COMPONENTS.split(',')
                    for (c in comps) {
                        echo "==> Processing Component: ${c}"
                        dir("${REPO_ROOT}/${c}") {
                            withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_REGION}") {

                                // Init
                                echo "--> Init: ${c}"
                                sh "terraform init -input=false -reconfigure"

                                // Plan
                                echo "--> Plan: ${c}"
                                sh "terraform plan -input=false -out=plan-${c}.tfplan"

                                // Apply
                                echo "--> Apply: ${c}"
                                sh "terraform apply -input=false plan-${c}.tfplan"
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment finished"
        }
        failure {
            echo "❌ Deployment FAILED"
        }
    }
}
