# Update your Dockerfile:
FROM python:3.9-slim

# Add security updates
RUN apt-get update && apt-get upgrade -y

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5005

# Run as non-root user
RUN useradd -m appuser
USER appuser

CMD ["python", "app.py"]