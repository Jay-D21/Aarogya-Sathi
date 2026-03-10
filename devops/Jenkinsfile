pipeline {
    agent any

    environment {
        FLUTTER_HOME = tool(name: 'Flutter SDK', type: 'com.example.FlutterInstallation') ?: ''
        PYTHON_HOME  = tool(name: 'Python', type: 'jenkins.plugins.shiningpanda.tools.PythonInstallation') ?: ''
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Branch: ${env.BRANCH_NAME ?: env.GIT_BRANCH}"
            }
        }

        // ────────────────────────────────────────────
        //  PYTHON BACKEND
        // ────────────────────────────────────────────
        stage('Backend – Install Dependencies') {
            steps {
                dir('backend') {
                    bat 'python -m pip install --upgrade pip'
                    bat 'pip install -r requirements.txt'
                }
            }
        }

        stage('Backend – Lint') {
            steps {
                dir('backend') {
                    bat 'pip install flake8'
                    bat 'flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics'
                }
            }
        }

        stage('Backend – Test') {
            steps {
                dir('backend') {
                    bat 'python -m pytest tests/ --junitxml=test-results.xml -v'
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'backend/test-results.xml'
                }
            }
        }

        // ────────────────────────────────────────────
        //  FLUTTER FRONTEND
        // ────────────────────────────────────────────
        stage('Frontend – Get Dependencies') {
            steps {
                dir('frontend') {
                    bat 'flutter pub get'
                }
            }
        }

        stage('Frontend – Analyze') {
            steps {
                dir('frontend') {
                    bat 'flutter analyze'
                }
            }
        }

        stage('Frontend – Test') {
            steps {
                dir('frontend') {
                    bat 'flutter test --machine > test-results.json'
                }
            }
        }

        stage('Frontend – Build APK') {
            when {
                anyOf {
                    branch 'main'
                    branch 'release/*'
                }
            }
            steps {
                dir('frontend') {
                    bat 'flutter build apk --release'
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'frontend/build/app/outputs/flutter-apk/*.apk', fingerprint: true
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check the logs above.'
        }
        cleanup {
            cleanWs()
        }
    }
}
