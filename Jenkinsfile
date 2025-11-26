pipeline {
    agent { label 'AGENT-1' }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_CREDENTIALS_ID = 'aws'
        TF_VAR_env = 'dev'
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

        stage('Terraform: Init & Plan') {
            steps {
                script {
                    def comps = env.COMPONENTS.split(',')
                    for (c in comps) {
                        echo "==> Init & Plan: ${c}"
                        dir("${REPO_ROOT}/${c}") {
                            withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_REGION}") {
                                sh """
                                    terraform init -input=false -reconfigure
                                    terraform validate
                                    terraform plan -input=false -var-file=../../envs/${TF_VAR_env}.tfvars -out=plan-${TF_VAR_env}-${c}.tfplan
                                """
                                archiveArtifacts artifacts: "plan-${TF_VAR_env}-${c}.tfplan", fingerprint: true
                            }
                        }
                    }
                }
            }
        }

        stage('Manual Approval (optional for prod)') {
            when { expression { return env.TF_VAR_env == 'prod' } }
            steps {
                script {
                    input message: "Approve apply for ${TF_VAR_env}?"
                }
            }
        }

        stage('Terraform: Apply') {
            steps {
                script {
                    def comps = env.COMPONENTS.split(',')
                    for (c in comps) {
                        echo "==> Applying: ${c}"
                        dir("${REPO_ROOT}/${c}") {
                            withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_REGION}") {
                                sh """
                                    terraform apply -input=false plan-${TF_VAR_env}-${c}.tfplan
                                    terraform output -json > outputs-${c}.json || true
                                """
                                archiveArtifacts artifacts: "outputs-${c}.json"
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Direct deployment finished for ${TF_VAR_env}"
        }
        failure {
            echo "❌ Direct deployment FAILED for ${TF_VAR_env}"
        }
        always {
            echo "Cleaning up workspace"
            // deleteDir()
        }
    }
}

