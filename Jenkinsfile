// ============================================
// Aarogya Sathi — Jenkins CI/CD Pipeline
// Stages: Checkout → Lint → Test → Docker Build → Push → K8s Deploy
// ============================================

pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDS   = credentials('dockerhub-credentials')
        DOCKER_REGISTRY     = 'jayd21'
        BACKEND_IMAGE       = "${DOCKER_REGISTRY}/aarogya-backend"
        FRONTEND_IMAGE      = "${DOCKER_REGISTRY}/aarogya-frontend"
        DATABASE_IMAGE      = "${DOCKER_REGISTRY}/aarogya-database"
        IMAGE_TAG            = "${BUILD_NUMBER}-${GIT_COMMIT.take(7)}"
        KUBECONFIG_CREDS    = credentials('kubeconfig')
    }

    options {
        timestamps()
        timeout(time: 45, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 1: Checkout Source Code
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('📥 Checkout') {
            steps {
                checkout scm
                echo "🔀 Branch: ${env.BRANCH_NAME ?: env.GIT_BRANCH}"
                echo "📝 Commit: ${env.GIT_COMMIT}"
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 2: Backend — Lint & Test
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('🔍 Backend — Lint') {
            steps {
                dir('backend') {
                    bat 'python -m pip install --upgrade pip'
                    bat 'pip install -r requirements.txt'
                    bat 'pip install flake8 bandit'
                    bat 'flake8 app/ --count --select=E9,F63,F7,F82 --show-source --statistics'
                    echo '✅ Backend linting passed!'
                }
            }
        }

        stage('🧪 Backend — Test') {
            steps {
                dir('backend') {
                    bat 'python -m pytest tests/ -v --junitxml=test-results.xml'
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'backend/test-results.xml'
                }
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 3: Frontend — Analyze & Test
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('🔍 Frontend — Analyze') {
            steps {
                dir('frontend') {
                    bat 'flutter pub get'
                    bat 'flutter analyze --no-fatal-infos'
                    echo '✅ Frontend analysis passed!'
                }
            }
        }

        stage('🧪 Frontend — Test') {
            steps {
                dir('frontend') {
                    bat 'flutter test'
                }
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 4: Docker — Build All Images
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('🐳 Docker — Build Images') {
            steps {
                echo "🏗️ Building Docker images with tag: ${IMAGE_TAG}"
                
                // Build Backend
                bat "docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest ./backend"
                
                // Build Frontend
                bat "docker build -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:latest ./frontend"
                
                // Build Database
                bat "docker build -t ${DATABASE_IMAGE}:${IMAGE_TAG} -t ${DATABASE_IMAGE}:latest ./database"

                echo '✅ All Docker images built successfully!'
                bat 'docker images | findstr "aarogya"'
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 5: Docker — Push to Registry
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('📤 Docker — Push to Registry') {
            when {
                anyOf {
                    branch 'main'
                    branch 'release/*'
                }
            }
            steps {
                bat "docker login -u ${DOCKER_HUB_CREDS_USR} -p ${DOCKER_HUB_CREDS_PSW}"
                
                bat "docker push ${BACKEND_IMAGE}:${IMAGE_TAG}"
                bat "docker push ${BACKEND_IMAGE}:latest"
                
                bat "docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                bat "docker push ${FRONTEND_IMAGE}:latest"
                
                bat "docker push ${DATABASE_IMAGE}:${IMAGE_TAG}"
                bat "docker push ${DATABASE_IMAGE}:latest"

                echo '✅ All images pushed to Docker Hub!'
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 6: Kubernetes — Deploy
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('☸️ Kubernetes — Deploy') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    // Apply all K8s manifests
                    bat 'kubectl apply -f k8s/namespace.yaml'
                    bat 'kubectl apply -f k8s/configmap.yaml'
                    bat 'kubectl apply -f k8s/secrets.yaml'
                    bat 'kubectl apply -f k8s/database/'
                    bat 'kubectl apply -f k8s/cache/'
                    bat 'kubectl apply -f k8s/backend/'
                    bat 'kubectl apply -f k8s/frontend/'
                    bat 'kubectl apply -f k8s/ingress.yaml'

                    // Update image tags
                    bat "kubectl set image deployment/backend backend=${BACKEND_IMAGE}:${IMAGE_TAG} -n aarogya-sathi"
                    bat "kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:${IMAGE_TAG} -n aarogya-sathi"

                    // Verify deployment
                    bat 'kubectl rollout status deployment/backend -n aarogya-sathi --timeout=120s'
                    bat 'kubectl rollout status deployment/frontend -n aarogya-sathi --timeout=120s'
                    
                    echo '✅ Kubernetes deployment completed!'
                    bat 'kubectl get all -n aarogya-sathi'
                }
            }
        }

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Stage 7: Frontend — Build APK (Release)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        stage('📱 Build APK') {
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

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Post Actions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    post {
        success {
            echo '''
            ╔══════════════════════════════════════╗
            ║  ✅ PIPELINE COMPLETED SUCCESSFULLY  ║
            ╚══════════════════════════════════════╝
            '''
        }
        failure {
            echo '''
            ╔══════════════════════════════════════╗
            ║  ❌ PIPELINE FAILED — CHECK LOGS     ║
            ╚══════════════════════════════════════╝
            '''
        }
        always {
            // Clean up Docker images to save disk space
            bat 'docker system prune -f'
        }
        cleanup {
            cleanWs()
        }
    }
}
