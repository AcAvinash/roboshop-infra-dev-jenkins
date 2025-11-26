pipeline {
    agent { label 'AGENT-1' }

    options {
        ansiColor('xterm')
    }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_CREDENTIALS_ID = 'aws'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Deploy All Components') {
            steps {
                script {

                    def components = [
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

                    for (c in components) {
                        echo "===== Processing: ${c} ====="

                        dir("${c}") {
                            withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_REGION}") {
                                
                                        // Only for VPN component
                                if (c == '30-vpn') {
                                    withCredentials([file(credentialsId: 'openvpn-pubkey', variable: 'PUBKEY')]) {
                                        // copy to folder with same name that Terraform expects
                                        sh 'cp $PUBKEY ./terraform.pub'
                                    }
                                }
                                sh "terraform init -input=false -reconfigure"
                                sh "terraform plan -input=false"
                                sh "terraform apply -auto-approve"
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment Successful"
        }
        failure {
            echo "❌ Deployment Failed"
        }
    }
}




