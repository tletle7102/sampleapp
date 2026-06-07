pipeline {
    agent any

    options {
        timeout(time: 20, unit: 'MINUTES')
        timestamps()
    }

    environment {
        DB_USERNAME = credentials('sampleapp-db-username')
        DB_PASSWORD = credentials('sampleapp-db-password')
        DOMAIN = credentials('domain-name')
        SUBDOMAIN = "sampleapp.${DOMAIN}"
        DISCORD_WEBHOOK_BUILD_SUCCESS = credentials('discord-webhook-build-success')
        DISCORD_WEBHOOK_BUILD_FAILURE = credentials('discord-webhook-build-failure')
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Docker Build & Deploy') {
            steps {
                sh 'docker compose down || true'
                sh 'docker rm -f sampleapp || true'
                sh 'docker compose up -d --build'
            }
        }

        stage('Health Verification') {
            steps {
                script {
                    sh '''
                        echo "sampleapp healthy 대기 (최대 4분)..."
                        for i in $(seq 1 24); do
                            status=$(docker inspect sampleapp --format='{{.State.Health.Status}}' 2>/dev/null || echo "missing")
                            echo "  [$i/24] sampleapp: $status"
                            [ "$status" = "healthy" ] && break
                            if [ "$i" -eq 24 ]; then
                                echo "❌ healthy 미도달"
                                docker logs sampleapp --tail 50
                                exit 1
                            fi
                            sleep 10
                        done
                        code=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 15 https://${SUBDOMAIN}/ || echo "000")
                        if [ "$code" != "200" ]; then
                            echo "❌ HTTPS 비정상: HTTP $code"
                            exit 1
                        fi
                        echo "✅ https://${SUBDOMAIN} 정상 (HTTP $code)"
                    '''
                }
            }
        }

        stage('Cleanup') {
            steps { sh 'docker image prune -f' }
        }
    }

    post {
        success {
            sh '''
                MSG="빌드 #${BUILD_NUMBER} 배포 완료
https://${SUBDOMAIN}"
                PAYLOAD=$(jq -nc \
                  --arg t "✅ sampleapp 배포 성공" \
                  --arg d "$MSG" \
                  --argjson c 3066993 \
                  '{embeds: [{title: $t, description: $d, color: $c}]}')
                curl -sS -H "Content-Type: application/json" -d "$PAYLOAD" \
                     "${DISCORD_WEBHOOK_BUILD_SUCCESS}" >/dev/null 2>&1 || true
            '''
        }
        failure {
            sh '''
                MSG="빌드 #${BUILD_NUMBER} 실패
[로그 보기](${BUILD_URL}console)"
                PAYLOAD=$(jq -nc \
                  --arg t "❌ sampleapp 배포 실패" \
                  --arg d "$MSG" \
                  --argjson c 15158332 \
                  '{embeds: [{title: $t, description: $d, color: $c}]}')
                curl -sS -H "Content-Type: application/json" -d "$PAYLOAD" \
                     "${DISCORD_WEBHOOK_BUILD_FAILURE}" >/dev/null 2>&1 || true
            '''
        }
    }
}
