pipeline {
    agent any

    environment {
        function_name = 'jenkins'
    }

    parameters {
        string(name: 'PARAMETER_NAME', defaultValue: 'default_value', description: 'Parameter description')
        booleanParam(name: 'ENABLE_FEATURE', defaultValue: true, description: 'Enable feature flag')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'qa', 'prod'], description: 'Select deployment environment')
    }

    stages {
        stage('Build') {
            steps {
                echo 'Build'
                sh 'mvn package'
            }
        }

        stage('SonarQube analysis') {
            when {
                branch 'main'
            }
            steps {
                withSonarQubeEnv('sonarqube') {
                    echo 'Scanning'
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    try {
                        timeout(time: 1, unit: 'MINUTES') {
                            def qualityGate = waitForQualityGate abortPipeline: true
                            echo "Quality Gate status is ${qualityGate.status}"
                            echo "Quality Gate details: ${qualityGate}"
                        }
                    } catch (Exception e) {
                        echo "Quality Gate failed: ${e.getMessage()}"
                        error("Quality Gate check failed.")
                    }
                }
            }
        }

        stage('Push') {
            steps {
                echo 'Push'
                sh "aws s3 cp target/sample-1.0.3.jar s3://jenkinsbuckets"
            }
        }

        stage('Deploy to Test') {
            steps {
                echo 'Deploy to Test'
                sh "aws lambda update-function-code --function-name $function_name --region us-east-1 --s3-bucket jenkinsbuckets --s3-key sample-1.0.3.jar"
            }
        }

        stage('Deploy to Prod') {
            steps {
                echo 'Deploy to Prod'
                input(message: 'Are we good for production?', ok: 'Proceed')
                sh "aws lambda update-function-code --function-name $function_name --region us-east-1 --s3-bucket jenkinsbuckets --s3-key sample-1.0.3.jar"
            }
        }
    }

    post {
        always {
            echo "${env.BUILD_ID}"
            echo "${BRANCH_NAME}"
            echo "${BUILD_NUMBER}"

            mail(
                body: 'Whatever',
                subject: 'Jenkins Build Notification',
                to: 'nikithareddy2109@gmail.com'
            )
        }
    }
}
