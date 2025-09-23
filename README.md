# Python Webserver with GitHub Actions Deployment

A simple Python webserver with automated deployment using GitHub Actions and Docker.

## 🚀 Quick Start

### Local Development
```bash
# Run the server directly
./deploy-direct.sh

# Or run with Python
python3 simple_server.py
```

### GitHub Deployment
1. Follow the complete guide: [GITHUB_DEPLOYMENT_GUIDE.md](GITHUB_DEPLOYMENT_GUIDE.md)
2. Push code to trigger automatic deployment
3. Access your deployed application

## 📁 Project Structure

- `simple_server.py` - Python HTTP server
- `index.html` - Web page served by the server
- `Dockerfile` - Docker container configuration
- `.github/workflows/deploy.yml` - GitHub Actions workflow
- `github-deploy.sh` - Deployment script
- `requirements.txt` - Python dependencies

## 🐳 Docker

```bash
# Build image
docker build -t python-webserver .

# Run container
docker run -p 8000:8000 python-webserver
```

## 📚 Documentation

- [Complete Deployment Guide](GITHUB_DEPLOYMENT_GUIDE.md) - Step-by-step GitHub deployment
- [GitHub Actions Workflow](.github/workflows/deploy.yml) - CI/CD configuration

## 🌐 Access

- Local: http://localhost:8000
- GitHub Container Registry: `ghcr.io/YOUR_USERNAME/python-webserver`
