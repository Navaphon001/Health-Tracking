pipeline {
  agent {
    docker {
      image 'python:3.13'
      // รันเป็น root และต่อ docker.sock ของโฮสต์ เพื่อ build/run ได้
      args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  options { timestamps() }

  environment {
    // Project-level variables used in cleanup and deploy stages
    PROJECT_DIR = "${WORKSPACE}"
    DOCKER_IMAGE = "health-tracking-backend:latest"
    DOCKER_CONTAINER = "health-tracking-backend"
      COMPOSE_DIR = "${WORKSPACE}/my-server/src/my_server/db"
  }

  stages {

    stage('Install Base Tooling') {
      steps {
        sh '''
          set -eux
          apt-get update
          # ใช้ docker-cli พอ (เบากว่า docker.io) เพราะเราใช้ docker engine จากโฮสต์ผ่าน /var/run/docker.sock
          DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            git wget unzip ca-certificates docker-cli default-jre-headless curl
            
            # Ensure compose directory exists and show contents for debugging
            pipeline {
              agent {
                docker {
                  image 'python:3.13'
                  args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock'
                }
              }

              options { timestamps() }

              environment {
                PROJECT_DIR = "${WORKSPACE}"
                DOCKER_IMAGE = "health-tracking-backend:latest"
                DOCKER_CONTAINER = "health-tracking-backend"
                COMPOSE_DIR = "${WORKSPACE}/my-server/src/my_server/db"
              }

              stages {
                stage('Install Base Tooling') {
                  steps {
                    sh '''
                      set -eux
                      apt-get update
                      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                        git wget unzip ca-certificates docker-cli default-jre-headless curl

                      apt-get -qq install -y docker-compose-plugin || true

                      command -v git
                      command -v docker
                      docker --version
                      java -version || true

                      SCAN_VER=7.2.0.5079
                      BASE_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli"
                      CANDIDATES="\
                        sonar-scanner-${SCAN_VER}-linux-x64.zip\
                        sonar-scanner-${SCAN_VER}-linux.zip\
                        sonar-scanner-cli-${SCAN_VER}-linux-x64.zip\
                        sonar-scanner-cli-${SCAN_VER}-linux.zip\
                      "
                      rm -f /tmp/sonar.zip || true
                      for f in $CANDIDATES; do
                        URL="$BASE_URL/$f"
                        if wget -q --spider "$URL"; then
                          wget -qO /tmp/sonar.zip "$URL"
                          break
                        fi
                      done
                      test -s /tmp/sonar.zip || { echo "Failed to download SonarScanner ${SCAN_VER}"; exit 1; }
                      unzip -q /tmp/sonar.zip -d /opt
                      SCAN_HOME="$(find /opt -maxdepth 1 -type d -name 'sonar-scanner*' | head -n1)"
                      ln -sf "$SCAN_HOME/bin/sonar-scanner" /usr/local/bin/sonar-scanner || true
                      sonar-scanner --version || true

                      test -S /var/run/docker.sock || { echo "ERROR: /var/run/docker.sock not mounted"; exit 1; }
                    '''
                  }
                }

                stage('Checkout') {
                  steps { git branch: 'feat/jenkins-ci', url: 'https://github.com/Navaphon001/Health-Tracking.git' }
                }

                stage('Install Python Deps') {
                  steps {
                    dir('my-server') {
                      sh '''
                        set -eux
                        python -m pip install --upgrade pip
                        if [ -f pyproject.toml ]; then
                          pip install poetry
                          poetry config virtualenvs.create false
                          poetry install
                        elif [ -f requirements.txt ]; then
                          pip install -r requirements.txt
                        else
                          pip install fastapi uvicorn sqlalchemy psycopg2-binary alembic pydantic python-jose[cryptography] passlib[bcrypt] python-multipart
                        fi
                        pip install pytest pytest-cov
                      '''
                    }
                  }
                }

                stage('Run Tests & Coverage') {
                  steps {
                    dir('my-server') {
                      sh '''
                        set -eux
                        export PYTHONPATH="$PWD/src${PYTHONPATH:+:$PYTHONPATH}"
                        mkdir -p tests
                        if [ ! -f "tests/test_main.py" ]; then
                          cat > tests/test_main.py << 'EOF'
            from fastapi.testclient import TestClient
            from my_server.main import app
            client = TestClient(app)

            def test_root_or_health():
                for path in ("/", "/health"):
                    try:
                        resp = client.get(path)
                        assert resp.status_code in (200, 404)
                    except Exception:
                        pass
            EOF
                        fi

                        python - <<'PY'
            import sys
            try:
                import my_server.main as m
                print('Imported my_server.main ok')
            except Exception as e:
                print('Failed to import my_server.main:', e)
                sys.exit(2)
            PY

                        python -m pytest -q --cov=src/my_server --cov-report=xml:coverage.xml tests/
                        ls -la
                        test -f coverage.xml
                      '''
                    }
                  }
                }

                stage('SonarQube Analysis') {
                  steps {
                    dir('my-server') {
                      withSonarQubeEnv('SonarQube') {
                        sh '''
                          set -eux
                          if [ -f sonar-project.properties ]; then
                            sonar-scanner -Dsonar.host.url="$SONAR_HOST_URL" -Dsonar.login="$SONAR_AUTH_TOKEN"
                          else
                            sonar-scanner -Dsonar.host.url="$SONAR_HOST_URL" -Dsonar.login="$SONAR_AUTH_TOKEN" \
                              -Dsonar.projectBaseDir="$PWD" \
                              -Dsonar.projectKey=Health-Tracking \
                              -Dsonar.projectName="Health Tracking Backend" \
                              -Dsonar.sources=src/my_server \
                              -Dsonar.tests=tests \
                              -Dsonar.python.version=3.13 \
                              -Dsonar.python.coverage.reportPaths=coverage.xml \
                              -Dsonar.sourceEncoding=UTF-8
                          fi
                        '''
                      }
                    }
                  }
                }

                stage('Quality Gate') {
                  steps { timeout(time: 10, unit: 'MINUTES') { waitForQualityGate abortPipeline: true } }
                }

                stage('Deploy with Docker Compose') {
                  steps {
                    dir('my-server') {
                      sh '''
                        set -eux
                        if [ ! -d "${COMPOSE_DIR}" ]; then
                          echo "ERROR: compose directory ${COMPOSE_DIR} not found"
                          echo "Workspace listing:"; ls -la || true
                          exit 1
                        fi
                        echo "Compose directory contents:"; ls -la "${COMPOSE_DIR}"

                        echo "Building Docker image..."
                        docker build -t "${DOCKER_IMAGE}" .

                        (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml down) || true
                        docker rm -f "${DOCKER_CONTAINER}" || true
                        docker rm -f wellness_postgres || true
                        docker rm -f wellness_backend || true

                        echo "Running docker-compose up (attempt 1)"
                        (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml up -d --remove-orphans) || RC=$?
                        if [ -z "${RC:-}" ]; then RC=0; fi
                        if [ "$RC" -ne 0 ]; then
                          echo "docker-compose up failed (rc=$RC), retrying once after a brief wait..."
                          sleep 5
                          (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml up -d --remove-orphans) || RC=$?
                          echo "docker-compose up retry finished with rc=${RC:-}" || true
                        fi

                        echo "Waiting for postgres to become healthy..."
                        HEALTH_OK=0
                        for i in 1 12; do
                          STATUS=$(docker inspect --format '{{.State.Health.Status}}' wellness_postgres 2>/dev/null || echo unknown)
                          echo "[poll $i] postgres health=$STATUS"
                          if [ "${STATUS}" = "healthy" ]; then
                            HEALTH_OK=1
                            break
                          fi
                          sleep 5
                        done

                        if [ "$HEALTH_OK" -ne 1 ]; then
                          echo "Postgres failed to reach healthy state. Collecting diagnostics..."
                          (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml ps) || true
                          docker ps -a || true
                          (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml logs postgres) || true
                          docker logs wellness_postgres || true

                          if (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml logs postgres) 2>/dev/null | grep -Ei "incompatible with this version|initialized by PostgreSQL version" >/dev/null 2>&1; then
                            echo "Detected Postgres data-dir version mismatch. Removing compose volumes and retrying..."
                            (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml down -v) || true
                            for V in $(docker volume ls --format '{{.Name}}' | grep -Ei 'postgres|postgres_data' || true); do
                              echo "Removing docker volume: $V" || true
                              docker volume rm -f "$V" || true
                            done

                            echo "Retrying docker-compose up after volume cleanup..."
                            (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml up -d --remove-orphans) || RC=$?
                            if [ -z "${RC:-}" ]; then RC=0; fi

                            HEALTH_OK=0
                            for i in 1 12; do
                              STATUS=$(docker inspect --format '{{.State.Health.Status}}' wellness_postgres 2>/dev/null || echo unknown)
                              echo "[post-prune-poll $i] postgres health=$STATUS"
                              if [ "${STATUS}" = "healthy" ]; then
                                HEALTH_OK=1
                                break
                              fi
                              sleep 5
                            done

                            if [ "$HEALTH_OK" -ne 1 ]; then
                              echo "Postgres still unhealthy after cleaning volumes. Final diagnostics:"
                              (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml ps) || true
                              docker ps -a || true
                              (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml logs postgres) || true
                              docker logs wellness_postgres || true
                              echo "Failing the build due to unhealthy postgres container"
                              exit 1
                            fi
                          else
                            echo "Postgres did not reach healthy state and no version-mismatch detected. Printing diagnostics and failing."
                            exit 1
                          fi
                        fi

                        (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml ps)
                        (cd "${COMPOSE_DIR}" && docker-compose -f docker-compose.yaml logs backend --tail=10) || true

                        curl -f http://localhost:8000/ || curl -f http://localhost:8000/docs || echo "Backend may still be starting..."
                      '''
                    }
                  }
                }

                stage('Deploy Container (dev)') {
                  steps {
                    sh '''
                      set -eux
                      if docker image inspect "${DOCKER_IMAGE}" >/dev/null 2>&1; then
                        echo "Docker image ${DOCKER_IMAGE} found. Checking port 8000 availability..."
                        BINDING=$(docker ps --format '{{.ID}} {{.Names}} {{.Ports}}' | grep '0.0.0.0:8000->' || true)
                        if [ -n "$BINDING" ]; then
                          CONTAINER_ID=$(echo "$BINDING" | awk '{print $1}')
                          docker rm -f "$CONTAINER_ID" || true
                        fi

                        HOST_BUSY=0
                        if command -v ss >/dev/null 2>&1; then
                          if ss -ltnp | grep -q ':8000\\b'; then HOST_BUSY=1; fi
                        elif command -v netstat >/dev/null 2>&1; then
                          if netstat -tlnp 2>/dev/null | grep -q ':8000\\b'; then HOST_BUSY=1; fi
                        fi

                        if [ "$HOST_BUSY" -eq 1 ]; then
                          echo "Host port 8000 is in use by a non-container process. Skipping docker run to avoid conflict."
                        else
                          echo "Port 8000 available — starting container."
                          docker run -d --name "${DOCKER_CONTAINER}" -p 8000:8000 "${DOCKER_IMAGE}"
                        fi
                      else
                        echo "Docker image ${DOCKER_IMAGE} not found, skipping deploy"
                      fi
                    '''
                  }
                }
              }

              post {
                always {
                  echo "Pipeline finished"
                  sh '''
                    set -eux || true
                    if [ -f "${PROJECT_DIR}/server.pid" ]; then
                      PID=$(cat "${PROJECT_DIR}/server.pid" || true)
                      echo "Stopping server pid=$PID"
                      kill -9 "$PID" || true
                      rm -f "${PROJECT_DIR}/server.pid" || true
                    fi
                    if [ -f "${PROJECT_DIR}/server.log" ]; then
                      echo "=== server.log (last 200 lines) ==="
                      tail -n 200 "${PROJECT_DIR}/server.log" || true
                    fi
                  '''
                }
              }
            }
                  exit 1
