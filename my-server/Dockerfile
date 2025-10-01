# Minimal Dockerfile for my-server
# Uses Python 3.13 and runs Uvicorn for the FastAPI app located under src/my_server

FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system deps for building wheels and curl for health checks
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
  && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . /app

# Prefer installing via pyproject (poetry) if present
RUN python -m pip install --upgrade pip setuptools wheel
RUN if [ -f pyproject.toml ]; then \
      pip install "poetry==1.8.1" || pip install poetry; \
      poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi; \
    elif [ -f requirements.txt ]; then \
      pip install -r requirements.txt; \
    else \
      echo "No pyproject.toml or requirements.txt found; image may be missing dependencies"; \
    fi

# Expose port expected by pipeline and run uvicorn
EXPOSE 8000

CMD ["uvicorn", "my_server.main:app", "--host", "0.0.0.0", "--port", "8000"]
