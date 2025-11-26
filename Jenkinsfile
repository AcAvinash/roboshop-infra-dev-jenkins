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
        timeout(time: 2, unit: 'HOURS')
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

                                //  Init
                                echo "--> Init: ${c}"
                                sh "terraform init -input=false -reconfigure"

                                //  Validate
                                echo "--> Validate: ${c}"
                                sh "terraform validate"

                                //  Plan
                                echo "--> Plan: ${c}"
                                sh "terraform plan -input=false -var-file=../../envs/${TF_VAR_env}.tfvars -out=plan-${TF_VAR_env}-${c}.tfplan"
                                archiveArtifacts artifacts: "plan-${TF_VAR_env}-${c}.tfplan", fingerprint: true

                                // Apply
                                if (env.TF_VAR_env == 'prod') {
                                    input message: "Approve apply for ${c} in ${TF_VAR_env}?"
                                }
                                echo "--> Apply: ${c}"
                                sh "terraform apply -input=false plan-${TF_VAR_env}-${c}.tfplan"

                                // 5️⃣ Save Outputs
                                sh "terraform output -json > outputs-${c}.json || true"
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
