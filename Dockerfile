# Base image with Python; we install Node on top of it.
FROM python:3.11-slim

# Install Node.js (needed for kms_client.js) and basic build tools.
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps first (better layer caching).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Node deps.
COPY package.json .
RUN npm install

# Copy the rest of the app.
COPY . .

# Railway sets $PORT — Gradio needs to bind to it, not a hardcoded 7860.
ENV GRADIO_SERVER_PORT=7860
EXPOSE 7860

CMD ["python", "run_relay.py"]
