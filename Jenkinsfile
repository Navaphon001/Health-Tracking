pipeline {
  agent {
    docker {
      image 'python:3.13'
      args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  options { timestamps() }

  environment {
    // Project-specific overrides (can be overridden by Jenkins credentials or job parameters)
    PROJECT_DIR = 'my-server'
    DOCKER_IMAGE = "fastapi-app:latest"
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

          # Optional: install sonar-scanner if Sonar is needed (small fallback download)
          SCAN_VER=4.8.0.2856
          BASE_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli"
          ZIP_NAME="sonar-scanner-${SCAN_VER}-linux.zip"
          if wget -q --spider "${BASE_URL}/${ZIP_NAME}"; then
            wget -qO /tmp/sonar.zip "${BASE_URL}/${ZIP_NAME}"
            unzip -q /tmp/sonar.zip -d /opt || true
            SCAN_HOME="$(find /opt -maxdepth 1 -type d -name 'sonar-scanner*' | head -n1)"
            ln -sf "$SCAN_HOME/bin/sonar-scanner" /usr/local/bin/sonar-scanner
          fi

          test -S /var/run/docker.sock || { echo "ERROR: /var/run/docker.sock not mounted"; exit 1; }
        '''
      }
    }

    stage('Checkout') {
      steps {
        // Use the job's repo by default; explicit checkout is useful in multi-repo setups
        checkout scm
      }
    }

    stage('Install Python Deps') {
      steps {
        dir(env.PROJECT_DIR) {
          sh '''
            set -eux
            # prefer poetry if pyproject.toml exists
            if [ -f pyproject.toml ]; then
              python -m pip install --upgrade pip
              pip install poetry
              poetry config virtualenvs.create false || true
              # Install dependencies without dev packages. Support both poetry v2 and v1 flags.
              if poetry install --only main 2>/dev/null; then
                echo "poetry install --only main succeeded"
              elif poetry install --no-dev 2>/dev/null; then
                echo "poetry install --no-dev succeeded"
              else
                echo "Falling back to poetry install (may include dev deps)"
                poetry install || true
              fi
            elif [ -f requirements.txt ]; then
              python -m pip install --upgrade pip
              pip install -r requirements.txt
            else
              echo "No pyproject.toml or requirements.txt found in ${PROJECT_DIR}, continuing"
            fi

            pip install pytest pytest-cov || true
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
              pytest -q --cov=. --cov-report=xml tests/ || true
            else
              echo "No tests directory in ${PROJECT_DIR}, skipping pytest"
            fi
          '''
        }
      }
    }

    stage('SonarQube Analysis (optional)') {
      when {
        expression { return env.SONAR_HOST_URL != null }
      }
      steps {
        withSonarQubeEnv('SonarQube') {
          withCredentials([string(credentialsId: 'FastApi', variable: 'SONAR_TOKEN')]) {
            dir(env.PROJECT_DIR) {
              sh '''
                set -eux
                sonar-scanner \
                  -Dsonar.host.url="$SONAR_HOST_URL" \
                  -Dsonar.login="$SONAR_TOKEN" \
                  -Dsonar.projectBaseDir="$PWD" \
                  -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                  -Dsonar.projectName="${SONAR_PROJECT_KEY}" \
                  -Dsonar.sources=. \
                  -Dsonar.python.version=3.11 \
                  -Dsonar.python.coverage.reportPaths=coverage.xml \
                  -Dsonar.sourceEncoding=UTF-8
              '''
            }
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        dir(env.PROJECT_DIR) {
          sh '''
            set -eux
            # Build Dockerfile located in my-server
            docker build -t ${DOCKER_IMAGE} .
          '''
        }
      }
    }

    stage('Deploy Container (dev)') {
      steps {
        sh '''
          set -eux
          docker rm -f fastapi-app || true
          docker run -d --name fastapi-app -p 8000:8000 ${DOCKER_IMAGE}
        '''
      }
    }
  }

  post {
    always {
      echo "Pipeline finished"
    }
  }
}
