pipeline {
  agent {
    docker {
      image 'python:3.13'
      args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  options { timestamps() }

  environment {
    // Project-specific overrides
    PROJECT_DIR       = 'my-server'            // เปลี่ยนเป็น '.' ถ้าโปรเจ็กต์อยู่ราก repo
    DOCKER_IMAGE      = "fastapi-app:latest"
    SONAR_PROJECT_KEY = 'Health-Tracking-my-server'
    DOCKER_CONTAINER  = 'fastapi-app'
  }

  stages {

    stage('Install Base Tooling') {
      steps {
        sh '''
          set -eux
          apt-get update
          DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            git wget unzip ca-certificates docker-cli default-jre-headless

          command -v git
          command -v docker
          docker --version
          java -version || true

          # ---- Install SonarScanner CLI (ลองหลายชื่อ กัน 404) ----
          SCAN_VER=7.2.0.5079
          BASE_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli"
          CANDIDATES="
            sonar-scanner-${SCAN_VER}-linux-x64.zip
            sonar-scanner-${SCAN_VER}-linux.zip
            sonar-scanner-cli-${SCAN_VER}-linux-x64.zip
            sonar-scanner-cli-${SCAN_VER}-linux.zip
          "
          rm -f /tmp/sonar.zip || true
          for f in $CANDIDATES; do
            URL="${BASE_URL}/${f}"
            echo "Trying: $URL"
            if wget -q --spider "$URL"; then
              wget -qO /tmp/sonar.zip "$URL"
              break
            fi
          done
          test -s /tmp/sonar.zip || { echo "Failed to download SonarScanner ${SCAN_VER}"; exit 1; }

          unzip -q /tmp/sonar.zip -d /opt
          SCAN_HOME="$(find /opt -maxdepth 1 -type d -name 'sonar-scanner*' | head -n1)"
          ln -sf "$SCAN_HOME/bin/sonar-scanner" /usr/local/bin/sonar-scanner
          sonar-scanner --version

          # docker.sock สำหรับ build/run image
          test -S /var/run/docker.sock || { echo "ERROR: /var/run/docker.sock not mounted"; exit 1; }
        '''
      }
    }

    stage('Checkout') {
      steps {
        // ใช้ repo ของ job (รองรับ Multibranch)
        checkout scm
      }
    }

    stage('Install Python Deps') {
      steps {
        dir(env.PROJECT_DIR) {
          sh '''
            set -eux
            python -m pip install --upgrade pip
            if [ -f pyproject.toml ]; then
              # pin poetry v1 ให้รองรับ --no-dev; ตกกรณีไม่ได้ ค่อยติดตั้งล่าสุด
              pip install "poetry==1.8.1" || pip install poetry || true
              poetry --version || true
              poetry config virtualenvs.create false || true
              # รองรับทั้ง poetry v2 (--only main) และ v1 (--no-dev)
              if poetry install --only main 2>/tmp/poetry_install_only_main.log; then
                echo "poetry install --only main succeeded"
              elif poetry install --no-dev 2>/tmp/poetry_install_no_dev.log; then
                echo "poetry install --no-dev succeeded"
              else
                tail -n +1 /tmp/poetry_install_only_main.log || true
                tail -n +1 /tmp/poetry_install_no_dev.log || true
                poetry install || true
              fi
            elif [ -f requirements.txt ]; then
              pip install -r requirements.txt
            else
              echo "No pyproject.toml or requirements.txt found in ${PROJECT_DIR}, continuing"
            fi
            pip install pytest pytest-cov || true
            # เผื่อไม่มี __init__.py
            [ -d app ] && touch app/__init__.py || true
          '''
        }
      }
    }

    stage('Run Tests & Coverage') {
      steps {
        dir(env.PROJECT_DIR) {
          sh '''
            set -eux
            export PYTHONPATH="$PWD"
            if [ -d tests ]; then
              # ถ้าใช้โครงสร้างแพ็กเกจเป็น app/ เปลี่ยน --cov=app ได้
              pytest -q --cov=. --cov-report=xml tests/
              test -f coverage.xml
            else
              echo "No tests directory in ${PROJECT_DIR}, skipping pytest"
            fi
          '''
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        // ต้องตั้งค่า SonarQube server ชื่อ "SonarQube" ใน Jenkins และมี credentialId: FastApi (Secret Text)
        withSonarQubeEnv('SonarQube') {
          withCredentials([string(credentialsId: 'FastApi', variable: 'SONAR_TOKEN')]) {
            dir(env.PROJECT_DIR) {
              sh '''
                set -eux
                # ถ้ามี sonar-project.properties จะถูกใช้โดยอัตโนมัติ
                COV_OPT=""
                [ -f coverage.xml ] && COV_OPT="-Dsonar.python.coverage.reportPaths=coverage.xml"

                sonar-scanner \
                  -Dsonar.host.url="$SONAR_HOST_URL" \
                  -Dsonar.login="$SONAR_TOKEN" \
                  -Dsonar.projectBaseDir="$PWD" \
                  -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
                  -Dsonar.projectName="${SONAR_PROJECT_KEY}" \
                  -Dsonar.sources=. \
                  -Dsonar.tests=tests \
                  -Dsonar.python.version=3.13 \
                  -Dsonar.sourceEncoding=UTF-8 \
                  $COV_OPT
              '''
            }
          }
        }
      }
    }

    // ต้องตั้ง webhook บน SonarQube -> http(s)://<JENKINS_URL>/sonarqube-webhook/
    stage('Quality Gate') {
      steps {
        timeout(time: 10, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        dir(env.PROJECT_DIR) {
          sh '''
            set -eux
            docker build -t ${DOCKER_IMAGE} .
          '''
        }
      }
    }

    stage('Deploy Container (dev)') {
      steps {
        sh '''
          set -eux
          docker rm -f ${DOCKER_CONTAINER} || true
          docker run -d --name ${DOCKER_CONTAINER} -p 8000:8000 ${DOCKER_IMAGE}
        '''
      }
    }
  }

  post { always { echo "Pipeline finished" } }
}
