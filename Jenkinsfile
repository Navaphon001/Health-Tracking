pipeline {
  agent { docker { image 'python:3.13'; args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock' } }

  options { timestamps() }

  environment {
    PROJECT_DIR = "${WORKSPACE}"
    COMPOSE_DIR = "${WORKSPACE}/my-server/src/my_server/db"
  }

  stages {
    stage('Checkout') {
      steps { git branch: 'feat/jenkins-ci', url: 'https://github.com/Navaphon001/Health-Tracking.git' }
    }

    stage('Compose sanity') {
      steps {
        sh '''
          set -eux
          if [ ! -d "${COMPOSE_DIR}" ]; then
            echo "ERROR: compose directory ${COMPOSE_DIR} not found"
            ls -la || true
            exit 1
          fi
          echo "Compose dir:"; ls -la "${COMPOSE_DIR}"
        '''
      }
    }

    stage('Smoke test import') {
      steps {
        dir('my-server') {
          sh '''
            set -eux
            python -m pip install --upgrade pip
            pip install pytest
            export PYTHONPATH="$PWD/src${PYTHONPATH:+:$PYTHONPATH}"
            mkdir -p tests
            if [ ! -f tests/test_main.py ]; then
              cat > tests/test_main.py <<'EOF'
from fastapi.testclient import TestClient
from my_server.main import app
client = TestClient(app)
def test_import():
    assert app is not None
EOF
            fi
            python -m pytest -q tests/
          '''
        }
      }
    }
  }

  post { always { echo 'Jenkinsfile parsed and basic checks ran' } }
}
pipeline {
  agent { docker { image 'python:3.13'; args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock' } }
pipeline {
  agent { docker { image 'python:3.13'; args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock' } }

  options { timestamps() }

  environment {
    PROJECT_DIR = "${WORKSPACE}"
    COMPOSE_DIR = "${WORKSPACE}/my-server/src/my_server/db"
  }

  stages {
    stage('Checkout') {
      steps { git branch: 'feat/jenkins-ci', url: 'https://github.com/Navaphon001/Health-Tracking.git' }
    }

    stage('Compose sanity') {
      steps {
        sh '''
          set -eux
          if [ ! -d "${COMPOSE_DIR}" ]; then
            echo "ERROR: compose directory ${COMPOSE_DIR} not found"
            ls -la || true
            exit 1
          fi
          pipeline {
            agent { docker { image 'python:3.13'; args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock' } }

            options { timestamps() }

            environment {
              PROJECT_DIR = "${WORKSPACE}"
              COMPOSE_DIR = "${WORKSPACE}/my-server/src/my_server/db"
            }

            stages {
              stage('Checkout') {
                steps { git branch: 'feat/jenkins-ci', url: 'https://github.com/Navaphon001/Health-Tracking.git' }
              }

              stage('Compose sanity') {
                steps {
                  sh '''
                    set -eux
                    if [ ! -d "${COMPOSE_DIR}" ]; then
                      echo "ERROR: compose directory ${COMPOSE_DIR} not found"
                      ls -la || true
                      exit 1
                    fi
                    echo "Compose dir:"; ls -la "${COMPOSE_DIR}"
                  '''
                }
              }

              stage('Smoke test import') {
                steps {
                  dir('my-server') {
                    sh '''
                      set -eux
                      python -m pip install --upgrade pip
                      pip install pytest
                      export PYTHONPATH="$PWD/src${PYTHONPATH:+:$PYTHONPATH}"
                      mkdir -p tests
                      if [ ! -f tests/test_main.py ]; then
                        cat > tests/test_main.py <<'EOF'
          from fastapi.testclient import TestClient
          from my_server.main import app
          client = TestClient(app)
          def test_import():
              assert app is not None
          EOF
                      fi
                      python -m pytest -q tests/
                    '''
                  }
                }
              }
            }

            post { always { echo 'Jenkinsfile parsed and basic checks ran' } }
          }
