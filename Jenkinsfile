pipeline {
  agent {
    docker {
      image 'python:3.13'
      // run as root and bind host docker.sock so the job can build/run containers
      args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  options {
    timestamps()
    timeout(time: 60, unit: 'MINUTES')
    skipDefaultCheckout() // ปิด auto-checkout เพื่อใช้ stage Checkout ของเราเอง
  }

  // อย่าใส่ secret ใน environment block — ให้ใช้ Jenkins Credentials แทน
  environment {
    COMPOSE_DIR = "${WORKSPACE}/my-server/src/my_server/db"
    IMAGE_NAME  = 'health-tracking-backend:latest'
  }

  stages {

    stage('Install Base Tooling') {
      steps {
        sh '''
          set -eux
          apt-get update
          DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            git wget unzip ca-certificates curl \
            default-jre-headless docker-cli jq

          # Install docker-compose v2 (standalone shim)
          curl -sSL "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          docker-compose --version || true

          # ---- Install SonarScanner CLI (best-effort) ----
          SCAN_VER=7.2.0.5079
          BASE_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli"
          for f in \
            "sonar-scanner-${SCAN_VER}-linux-x64.zip" \
            "sonar-scanner-${SCAN_VER}-linux.zip" \
            "sonar-scanner-cli-${SCAN_VER}-linux-x64.zip" \
            "sonar-scanner-cli-${SCAN_VER}-linux.zip"
          do
            if wget -q --spider "${BASE_URL}/$f"; then
              wget -qO /tmp/sonar.zip "${BASE_URL}/$f"
              break
            fi
          done

          if [ -s /tmp/sonar.zip ]; then
            unzip -q /tmp/sonar.zip -d /opt
            SCAN_HOME="$(find /opt -maxdepth 1 -type d -name 'sonar-scanner*' | head -n1)"
            ln -sf "$SCAN_HOME/bin/sonar-scanner" /usr/local/bin/sonar-scanner
            sonar-scanner --version || true
          else
            echo "SonarScanner not downloaded; analysis step will be skipped."
          fi

          # Ensure docker socket is available
          test -S /var/run/docker.sock || { echo "ERROR: /var/run/docker.sock not mounted"; exit 1; }
        '''
      }
    }

    stage('Checkout') {
      steps {
        checkout scm
      }
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
              poetry install --no-interaction || true

              # ✅ ensure python-jose is present even if not declared in pyproject
              pip install --no-cache-dir "python-jose[cryptography]"

              # quick sanity check
              python - <<'PY'
import sys
try:
    import jose, jose.jwt
    print("python-jose OK")
except Exception as e:
    print("python-jose missing/broken:", e)
    sys.exit(1)
PY
            elif [ -f requirements.txt ]; then
              pip install --no-cache-dir -r requirements.txt
              pip install --no-cache-dir "python-jose[cryptography]" || true
            else
              pip install --no-cache-dir fastapi "uvicorn[standard]" sqlalchemy psycopg2-binary alembic pydantic \
                  "python-jose[cryptography]" "passlib[bcrypt]" python-multipart python-dotenv || true
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
            # ใช้ SQLite สำหรับเทสใน CI เพื่อไม่ต้องพึ่ง Postgres
            export DATABASE_URL="${DATABASE_URL:-sqlite:///./ci_test.db}"
            export TESTING=1

            # Ensure test runtime dependencies are available
            if [ -f pyproject.toml ]; then
              pip install poetry
              poetry config virtualenvs.create false
              poetry install --no-interaction || true
              pip install --no-cache-dir "python-jose[cryptography]" pytest pytest-cov
            elif [ -f requirements.txt ]; then
              pip install --no-cache-dir -r requirements.txt || true
              pip install --no-cache-dir "python-jose[cryptography]" pytest pytest-cov || true
            else
              pip install --no-cache-dir fastapi "uvicorn[standard]" pytest pytest-cov "python-jose[cryptography]" || true
            fi

            # ---- bootstrap tests (เฉพาะถ้ายังไม่มีไฟล์ใน repo) ----
            mkdir -p tests
            if [ ! -f tests/conftest.py ]; then
              cat > tests/conftest.py << 'EOF'
import os, pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from my_server.schema.auth import Base
from my_server.api.auth import get_db
from my_server.main import app

@pytest.fixture(scope="session")
def engine(tmp_path_factory):
    db_file = tmp_path_factory.mktemp("data") / "test.db"
    url = f"sqlite:///{db_file}"
    eng = create_engine(url, connect_args={"check_same_thread": False})
    Base.metadata.create_all(eng)
    yield eng
    Base.metadata.drop_all(eng)

@pytest.fixture
def db_session(engine):
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    s = SessionLocal()
    try:
        yield s
    finally:
        s.close()

@pytest.fixture
def client(db_session):
    app.dependency_overrides[get_db] = lambda: iter([db_session])
    c = TestClient(app)
    yield c
    app.dependency_overrides.clear()
EOF
            fi

            if [ ! -f tests/test_health.py ]; then
              cat > tests/test_health.py << 'EOF'
def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json().get("status") == "ok"
EOF
            fi

            if [ ! -f tests/test_auth_flow.py ]; then
              cat > tests/test_auth_flow.py << 'EOF'
def test_register_then_login(client):
    r = client.post("/register", json={"username":"u1","email":"u1@example.com","password":"p@ssw0rd"})
    assert r.status_code in (200, 201)
    assert "access_token" in r.json()
    r2 = client.post("/login", data={"username":"u1@example.com","password":"p@ssw0rd"})
    assert r2.status_code == 200
    assert "access_token" in r2.json()
EOF
            fi
            # --------------------------------------------------------

            # รันเทส + เก็บ coverage เป็นไฟล์จริง
            pytest -q \
              --maxfail=1 --disable-warnings \
              --cov=my_server --cov-branch \
              --cov-report=xml:coverage.xml
          '''
        }
      }
    }

    stage('SonarQube Analysis') {
      when { expression { fileExists('my-server/coverage.xml') } }
      steps {
        dir('my-server') {
          // ตั้งชื่อให้ตรงกับที่ Configure ใน Jenkins: Manage Jenkins → SonarQube servers
          withSonarQubeEnv('SonarQube') {
            // ใช้ Jenkins Credentials เป็น String (credentialsId: 'tracking')
            withCredentials([string(credentialsId: 'tracking', variable: 'SONAR_TOKEN')]) {
              sh '''
                set -eux
                if command -v sonar-scanner >/dev/null 2>&1; then
                  sonar-scanner \
                    -Dsonar.host.url="$SONAR_HOST_URL" \
                    -Dsonar.token="$SONAR_TOKEN" \
                    -Dsonar.projectBaseDir="$PWD" \
                    -Dsonar.projectKey=health-tracking-backend \
                    -Dsonar.projectName="Health Tracking Backend" \
                    -Dsonar.projectVersion="${BUILD_NUMBER}" \
                    -Dsonar.sources=src/my_server \
                    -Dsonar.tests=tests \
                    -Dsonar.test.inclusions=tests/**/*.py \
                    -Dsonar.python.version=3.13 \
                    -Dsonar.python.coverage.reportPaths=coverage.xml \
                    -Dsonar.exclusions=**/tests/**,**/alembic/**,**/migrations/**,**/*.md \
                    -Dsonar.coverage.exclusions=**/tests/**,**/alembic/**,**/migrations/**
                else
                  echo "Skip Sonar analysis (scanner not installed)."
                fi
              '''
            }
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 10, unit: 'MINUTES') {
          // แสดง metric ที่ตก (ถ้ามี)
          withSonarQubeEnv('SonarQube') {
            withCredentials([string(credentialsId: 'tracking', variable: 'SONAR_TOKEN')]) {
              sh '''
                set -eux
                if [ -n "${SONAR_HOST_URL:-}" ]; then
                  curl -sS -u "${SONAR_TOKEN}:" \
                    "${SONAR_HOST_URL}/api/qualitygates/project_status?projectKey=health-tracking-backend" \
                    | jq -r '.projectStatus.conditions[] | "\\(.status)  \\(.metricKey)  actual=\\(.actualValue)  op=\\(.comparator)  th=\\(.errorThreshold)"' || true
                fi
              '''
            }
          }
          // บันทึกสถานะ QG (ไม่ abort) และเก็บไว้ใช้ข้าม deploy หากต้องการ
          script {
            def qg = waitForQualityGate(abortPipeline: false)
            env.QG_STATUS = qg.status
            echo "Quality Gate status: ${qg.status}"
            if (qg.status != 'OK') {
              currentBuild.result = 'UNSTABLE' // ถ้าอยาก “ผ่านเขียวเสมอ” ให้ลบบรรทัดนี้
            }
          }
        }
      }
    }

    stage('Deploy with Docker Compose') {
      // ถ้าอยากข้าม Deploy เมื่อ QG ไม่ผ่าน ให้ยกคอมเมนต์บรรทัด when นี้
      // when { environment name: 'QG_STATUS', value: 'OK' }
      steps {
        sh 'set -eux; [ -d "${COMPOSE_DIR}" ] || { echo "${COMPOSE_DIR} missing"; exit 1; }'
        // build image from the my-server root so Dockerfile context is correct
        sh 'set -eux; (cd "${WORKSPACE}/my-server" && docker build -t "${IMAGE_NAME}" -f Dockerfile .)'

        // Ensure host port 8000 is free - stop/remove any container binding it and remove old backend containers
        sh '''#!/usr/bin/env bash
set -eux
echo "Checking for containers binding host port 8000..."
CONFLICTING="$(docker ps --format '{{.ID}} {{.Ports}} {{.Names}}' | grep -E '(:|::):?8000->' || true)"
if [ -n "$CONFLICTING" ]; then
  echo "$CONFLICTING" | awk '{print $1}' | xargs -r docker stop || true
  echo "$CONFLICTING" | awk '{print $1}' | xargs -r docker rm -f || true
fi
# remove any existing container with the same docker-compose container name
OLD="$(docker ps -a --filter "name=wellness_backend" --format '{{.ID}}' || true)"
if [ -n "$OLD" ]; then
  echo "$OLD" | xargs -r docker rm -f || true
fi
'''

        // compose up (down first, then up -d)
        sh 'set -eux; (cd "${COMPOSE_DIR}" && docker-compose down || true)'
        sh 'set -eux; (cd "${COMPOSE_DIR}" && docker-compose up -d)'

        // robust health check with retries and diagnostics on failure
        sh '''#!/usr/bin/env bash
set -euo pipefail
cd "${COMPOSE_DIR}"

docker-compose ps

# 1) รอ container 'backend' รายงาน HEALTHCHECK = healthy
CID="$(docker-compose ps -q backend || true)"
if [ -z "${CID}" ]; then
  echo "Cannot find container id for service 'backend'"
  docker-compose ps
  exit 1
fi

echo "Waiting for backend container to be healthy..."
for i in $(seq 1 90); do
  status="$(docker inspect -f '{{.State.Health.Status}}' "$CID" 2>/dev/null || echo starting)"
  if [ "$status" = "healthy" ]; then
    echo "Container health is healthy"
    break
  fi
  if [ "$i" -eq 90 ]; then
    echo "Container did not become healthy in time"
    docker inspect "$CID" || true
    docker-compose logs --no-color --tail=200 || true
    exit 1
  fi
  sleep 2
done

# 2) Probe HTTP /health, break เมื่อสำเร็จ
MAX_TRIES=60
DELAY=2
for i in $(seq 1 "$MAX_TRIES"); do
  if curl -fsS http://localhost:8000/health >/dev/null; then
    echo "HTTP /health OK on attempt $i"
    exit 0
  fi
  echo "Attempt $i/$MAX_TRIES: /health not ready yet"
  sleep "$DELAY"
done

echo "Backend did not respond 200 to /health after $((MAX_TRIES*DELAY))s"
docker-compose logs --no-color --tail=200 || true
exit 1
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
