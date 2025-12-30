# Security Policy

## Reporting Vulnerabilities
Please report security issues to: security@example.com

## Security Tools in Use

### 1. Secret Scanning
- **Tool:** TruffleHog + GitHub Secret Scanning
- **Frequency:** Every commit
- **Purpose:** Prevent credential leaks

### 2. Container Security  
- **Tool:** Trivy
- **Frequency:** Every build
- **Purpose:** Find OS and package vulnerabilities

### 3. Dependency Security
- **Tool:** Safety + pip-audit
- **Frequency:** Weekly + on changes
- **Purpose:** Find vulnerable Python packages

### 4. Code Security
- **Tool:** GitHub CodeQL
- **Frequency:** Every pull request
- **Purpose:** Find bugs and security issues

## Security Gates
The pipeline will FAIL if:
- Critical vulnerabilities in containers
- Verified secrets in code
- High-risk dependency vulnerabilities