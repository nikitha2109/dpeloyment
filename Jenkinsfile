pipeline {
    agent any

    environment {
        function_name = 'jenkins'
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
                anyOf{
                    branch 'main'
                }
            }
        
            steps {
                withSonarQubeEnv('sonarqube') {
                    echo 'scanning'
                    sh 'mvn sonar:sonar'
                }
            }
        }
        stage("Quality Gate") {
    steps {
        script {
            try {
                timeout(time: 45, unit: 'SECONDS') {
                    def qualityGate = waitForQualityGate abortPipeline: true
                    echo "Quality Gate status is ${qualityGate.status}"
                    echo "Quality Gate details: ${qualityGate}"
                }
            } catch (Exception e) {
                echo "Quality Gate failed: ${e.getMessage()}"
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

        stage('Deploy') {
            steps {
                echo 'Build'

                sh "aws lambda update-function-code --function-name $function_name --region us-east-1 --s3-bucket jenkinsbuckets --s3-key sample-1.0.3.jar"
            }
        }
    }
}
