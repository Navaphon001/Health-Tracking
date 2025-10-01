pipeline {
  agent {
    docker {
      image 'python:3.13'
      // รันเป็น root และต่อ docker.sock เพื่อ build/run ได้
      args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  options { timestamps() }

  environment {
    // ปรับให้ตรงโปรเจกต์
    PROJECT_DIR       = 'my-server'          // ถ้าแอปอยู่ราก repo ให้ใช้ '.'
    DOCKER_IMAGE      = 'fastapi-app:latest'
    DOCKER_CONTAINER  = 'fastapi-app'
    SONAR_PROJECT_KEY = 'Health-Tracking-my-server'
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

          # ---- Install SonarScanner CLI (กัน 404 ด้วยหลายชื่อไฟล์) ----
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
            URL="${BASE_URL}/${f}"; echo "Trying: $URL"
            if wget -q --spider "$URL"; then wget -qO /tmp/sonar.zip "$URL"; break; fi
          done
          test -s /tmp/sonar.zip || { echo "Failed to download SonarScanner ${SCAN_VER}"; exit 1; }
          unzip -q /tmp/sonar.zip -d /opt
          SCAN_HOME="$(find /opt -maxdepth 1 -type d -name 'sonar-scanner*' | head -n1)"
          ln -sf "$SCAN_HOME/bin/sonar-scanner" /usr/local/bin/sonar-scanner
          sonar-scanner --version

          # ต้องมี docker.sock ให้บิลด์ได้
          test -S /var/run/docker.sock || { echo "ERROR: /var/run/docker.sock not mounted"; exit 1; }
        '''
      }
    }

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install Python Deps') {
      steps {
        dir(env.PROJECT_DIR) {
          sh '''
            set -eux
            python -m pip install --upgrade pip
            if [ -f pyproject.toml ]; then
              # รองรับทั้ง poetry v1 (--no-dev) และ v2 (--only main)
              pip install "poetry==1.8.1" || pip install poetry || true
              poetry config virtualenvs.create false || true
              poetry --version || true
              if poetry install --only main 2>/tmp/p_only_main.log; then
                echo "poetry install --only main ok"
              elif poetry install --no-dev 2>/tmp/p_no_dev.log; then
                echo "poetry install --no-dev ok"
              else
                tail -n +1 /tmp/p_only_main.log || true
                tail -n +1 /tmp/p_no_dev.log || true
                poetry install || true
              fi
            elif [ -f requirements.txt ]; then
              pip install -r requirements.txt
            else
              echo "No pyproject.toml or requirements.txt found in ${PWD}, continuing"
            fi
            pip install pytest pytest-cov || true
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
          # นับไฟล์ทดสอบ (รองรับ *_test.py และ test_*.py) โดยใช้ shell globbing แทน backslash-escaped parens
          CNT=0
          # count test_*.py
          set -- tests/test_*.py
          if [ -e "$1" ]; then
            CNT=$((CNT + $(ls tests/test_*.py 2>/dev/null | wc -l)))
          fi
          # count *_test.py
          set -- tests/*_test.py
          if [ -e "$1" ]; then
            CNT=$((CNT + $(ls tests/*_test.py 2>/dev/null | wc -l)))
          fi
          if [ "${CNT:-0}" -gt 0 ]; then
            # ถ้าโค้ดหลักอยู่ในโฟลเดอร์ app/ ให้ใช้ --cov=app; ถ้าไม่ ให้ใช้ --cov=.
            if [ -d app ]; then
              pytest -q --cov=app --cov-report=xml tests/
            else
              pytest -q --cov=.   --cov-report=xml tests/
            fi
          else
            echo "No test files found under tests/, skipping pytest"
          fi
        else
          echo "No tests directory in ${PWD}, skipping pytest"
        fi
      '''
    }
  }
}

    stage('SonarQube Analysis') {
      steps {
        // ต้องตั้ง SonarQube server ชื่อ "SonarQube" และ credentialId: FastApi (Secret Text)
        withSonarQubeEnv('SonarQube') {
          withCredentials([string(credentialsId: 'tracking', variable: 'SONAR_TOKEN')]) {
            dir(env.PROJECT_DIR) {
              sh '''
                set -eux
                SRC="."
                [ -d app ] && SRC="app"
                TESTS_OPT=""
                [ -d tests ] && TESTS_OPT="-Dsonar.tests=tests"
                COV_OPT=""
                [ -f coverage.xml ] && COV_OPT="-Dsonar.python.coverage.reportPaths=coverage.xml"

                sonar-scanner \
                  -Dsonar.host.url="$SONAR_HOST_URL" \
                  -Dsonar.token="$SONAR_TOKEN" \
                  -Dsonar.projectBaseDir="$PWD" \
                  -Dsonar.projectKey="${SONAR_PROJECT_KEY}" \
                  -Dsonar.projectName="${SONAR_PROJECT_KEY}" \
                  -Dsonar.sources="$SRC" \
                  -Dsonar.python.version=3.13 \
                  -Dsonar.sourceEncoding=UTF-8 \
                  -Dsonar.exclusions=tests/** \
                  $TESTS_OPT \
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
            docker build -t "${DOCKER_IMAGE}" .
          '''
        }
      }
    }

    stage('Deploy Container (dev)') {
      steps {
        sh '''
          set -eux
          docker rm -f "${DOCKER_CONTAINER}" || true
          docker run -d --name "${DOCKER_CONTAINER}" -p 8000:8000 "${DOCKER_IMAGE}"
        '''
      }
    }
  }

  post { always { echo "Pipeline finished" } }
}
