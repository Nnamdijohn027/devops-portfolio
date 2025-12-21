PROJECT: A Todo List Web App with full DevOps pipeline.

Step 1: The App
- Made a simple flask web app (app.py)
- Shows a todo list, can add new items
- Runs on my computer at localhost:5005

Step 2: Containerize
- containerize the app using docker
- created dockerfile
- can run anywhere with Docker installed

Step 3: Security Check
- Added Trivy Scanner
- Checks Docker images for security holes
- found vulnerabilities
- used AI to fix it 🫢

Step 4: Cloud infrastructure
- used Terraform to create AWS resources
- Made an EC2 virtual server (free tier)

Step 5: Deploy to cloud
- connected to AWS server via ssh
- installed docker on the server
- Ran the app on the internet

Step 6: Automation
- set up Github Actions pipeline
- Every code push automatically

TOOLS USED:
1. Python + Flask
2. Docker
3. Terraform
4. AWS EC2
5. Github Actions
6. Trivy