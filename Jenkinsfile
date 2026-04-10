// ============================================
// Aarogya Sathi — Jenkins CI/CD Pipeline
// Pulls from GitHub → Lint → Test → Docker → APK
// ============================================

pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 45, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 1: Checkout from GitHub
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('Checkout') {
            steps {
                checkout scm
                bat 'echo Branch: %GIT_BRANCH%'
                bat 'git log --oneline -3'
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 2: Backend — Install & Lint
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('Backend - Install Dependencies') {
            steps {
                dir('backend') {
                    bat 'python -m pip install --upgrade pip'
                    bat 'pip install -r requirements.txt'
                }
            }
        }

        stage('Backend - Lint') {
            steps {
                dir('backend') {
                    bat 'pip install flake8'
                    bat 'flake8 app/ --count --select=E9,F63,F7,F82 --show-source --statistics'
                }
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 3: Docker — Build Images
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('Docker - Build Backend Image') {
            steps {
                bat 'docker build -t aarogya-backend:latest ./backend'
                echo 'Backend Docker image built!'
            }
        }

        stage('Docker - Build Database Image') {
            steps {
                bat 'docker build -t aarogya-database:latest ./database'
                echo 'Database Docker image built!'
            }
        }

        stage('Docker - Show Images') {
            steps {
                bat 'docker images | findstr "aarogya"'
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 4: Flutter — Build APK
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('Flutter - Get Dependencies') {
            steps {
                dir('frontend') {
                    bat 'flutter pub get'
                }
            }
        }

        stage('Flutter - Build APK') {
            steps {
                dir('frontend') {
                    bat 'flutter build apk --release'
                }
            }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Post Actions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    post {
        success {
            echo '========================================='
            echo '  Pipeline completed successfully!'
            echo '========================================='
            archiveArtifacts artifacts: 'frontend/build/app/outputs/flutter-apk/*.apk',
                             allowEmptyArchive: true,
                             fingerprint: true
        }
        failure {
            echo '========================================='
            echo '  Pipeline FAILED - Check logs above'
            echo '========================================='
        }
        always {
            echo "Build: ${env.BUILD_NUMBER} | Branch: ${env.GIT_BRANCH}"
        }
    }
}
