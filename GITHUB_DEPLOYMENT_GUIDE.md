# 🚀 Complete GitHub Deployment Guide for Python Webserver

This guide will walk you through deploying your Python webserver using GitHub Actions, step by step, even if you're completely new to GitHub.

## 📋 Prerequisites

Before we start, make sure you have:
- A GitHub account (free)
- Git installed on your computer
- Basic understanding of command line (we'll guide you through everything)

## 🎯 What We'll Accomplish

By the end of this guide, you'll have:
- ✅ Your Python webserver automatically deployed when you push code to GitHub
- ✅ Docker containerization for consistent deployments
- ✅ Automated testing and building
- ✅ Professional CI/CD pipeline

---

## 📚 Step 1: Understanding Your Project

Your project contains:
- `simple_server.py` - Python webserver that serves files on port 8000
- `index.html` - Web page that gets served
- `deploy-direct.sh` - Script to run the server locally

We're adding:
- `Dockerfile` - Instructions to build a Docker container
- `.github/workflows/deploy.yml` - GitHub Actions workflow
- `github-deploy.sh` - Deployment script for GitHub Actions
- `requirements.txt` - Python dependencies

---

## 🔧 Step 2: Setting Up GitHub Repository

### 2.1 Create a New Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the **"+"** button in the top right corner
3. Select **"New repository"**
4. Fill in the details:
   - **Repository name**: `python-webserver` (or any name you prefer)
   - **Description**: "Simple Python webserver with GitHub Actions deployment"
   - **Visibility**: Choose Public (free) or Private
   - **Initialize**: Don't check any boxes (we'll upload existing code)
5. Click **"Create repository"**

### 2.2 Connect Your Local Project to GitHub

Open your terminal/command prompt and navigate to your project folder:

```bash
cd /Users/eyal.voulichman/Documents/study/study-aws-01
```

Initialize Git and connect to GitHub:

```bash
# Initialize Git repository
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: Python webserver with GitHub Actions"

# Add GitHub remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/python-webserver.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Note**: Replace `YOUR_USERNAME` with your actual GitHub username in the URL above.

---

## 🐳 Step 3: Understanding Docker (Optional but Helpful)

Docker packages your application with all its dependencies into a "container" that runs the same way everywhere.

### 3.1 What Our Dockerfile Does

```dockerfile
FROM python:3.11-slim          # Start with Python 3.11
WORKDIR /app                   # Set working directory
COPY requirements.txt .        # Copy dependencies file
RUN pip install -r requirements.txt  # Install dependencies
COPY simple_server.py .        # Copy our server
COPY index.html .              # Copy our web page
EXPOSE 8000                    # Make port 8000 available
CMD ["python3", "simple_server.py"]  # Run the server
```

### 3.2 Test Docker Locally (Optional)

If you have Docker installed, you can test locally:

```bash
# Build the Docker image
docker build -t python-webserver .

# Run the container
docker run -p 8000:8000 python-webserver

# Visit http://localhost:8000 in your browser
```

---

## ⚙️ Step 4: Understanding GitHub Actions

GitHub Actions automatically runs tasks when you push code. Our workflow:

1. **Triggers** when you push to `main` or `develop` branches
2. **Tests** your Python code
3. **Builds** a Docker image
4. **Pushes** the image to GitHub Container Registry
5. **Deploys** to different environments

### 4.1 Workflow Triggers

```yaml
on:
  push:
    branches: [ main, develop ]    # Run on push to main/develop
  pull_request:
    branches: [ main ]             # Run on pull requests
  workflow_dispatch:               # Allow manual triggering
```

### 4.2 Jobs in Our Workflow

1. **build-and-test**: Tests Python code
2. **build-docker**: Builds and pushes Docker image
3. **deploy-staging**: Deploys to staging (develop branch)
4. **deploy-production**: Deploys to production (main branch)

---

## 🚀 Step 5: First Deployment

### 5.1 Push Your Code

After setting up the repository, push your code:

```bash
git add .
git commit -m "Add GitHub Actions deployment workflow"
git push origin main
```

### 5.2 Watch the Magic Happen

1. Go to your GitHub repository
2. Click on the **"Actions"** tab
3. You'll see your workflow running!
4. Click on the workflow run to see detailed logs

### 5.3 Understanding the Workflow Run

The workflow will:
- ✅ Check out your code
- ✅ Set up Python 3.11
- ✅ Test your application
- ✅ Build Docker image
- ✅ Push to GitHub Container Registry
- ✅ Deploy (simulated for now)

---

## 🔍 Step 6: Monitoring and Troubleshooting

### 6.1 Viewing Logs

1. Go to **Actions** tab in your repository
2. Click on any workflow run
3. Click on any job to see detailed logs
4. Look for ✅ (success) or ❌ (failure) indicators

### 6.2 Common Issues and Solutions

**Issue**: Workflow fails on "Test application"
- **Solution**: Check that `simple_server.py` has no syntax errors

**Issue**: Docker build fails
- **Solution**: Ensure `Dockerfile` is in the root directory

**Issue**: Permission denied
- **Solution**: Make sure `github-deploy.sh` is executable (`chmod +x github-deploy.sh`)

### 6.3 Manual Workflow Trigger

You can manually trigger workflows:
1. Go to **Actions** tab
2. Select your workflow
3. Click **"Run workflow"**
4. Choose branch and click **"Run workflow"**

---

## 🌐 Step 7: Accessing Your Deployed Application

### 7.1 GitHub Container Registry

Your Docker images are stored in GitHub Container Registry:
- URL: `ghcr.io/YOUR_USERNAME/python-webserver`
- Access: Go to your repository → Packages

### 7.2 Running the Deployed Image

```bash
# Pull and run the latest image
docker pull ghcr.io/YOUR_USERNAME/python-webserver:latest
docker run -p 8000:8000 ghcr.io/YOUR_USERNAME/python-webserver:latest
```

---

## 🔄 Step 8: Making Changes and Re-deploying

### 8.1 Update Your Code

1. Make changes to `simple_server.py` or `index.html`
2. Test locally if needed
3. Commit and push:

```bash
git add .
git commit -m "Update webserver functionality"
git push origin main
```

### 8.2 Automatic Re-deployment

GitHub Actions will automatically:
- Detect the push
- Run tests
- Build new Docker image
- Deploy the updated version

---

## 🎛️ Step 9: Advanced Configuration

### 9.1 Environment Variables

You can add environment variables in your workflow:

```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
  CUSTOM_VAR: "my-value"
```

### 9.2 Secrets Management

For sensitive data, use GitHub Secrets:
1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. Add your secret (e.g., API keys, passwords)
4. Use in workflow: `${{ secrets.SECRET_NAME }}`

### 9.3 Different Deployment Environments

The workflow supports:
- **Staging**: Deploys from `develop` branch
- **Production**: Deploys from `main` branch
- **Manual**: Triggered manually

---

## 📊 Step 10: Monitoring and Maintenance

### 10.1 Health Checks

The Dockerfile includes health checks:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/ || exit 1
```

### 10.2 Logs and Debugging

- **GitHub Actions logs**: Available in the Actions tab
- **Container logs**: Use `docker logs CONTAINER_NAME`
- **Application logs**: Check `webserver.log` file

### 10.3 Updating Dependencies

To update Python or other dependencies:
1. Update `requirements.txt`
2. Update `Dockerfile` if needed
3. Commit and push changes

---

## 🎉 Congratulations!

You now have:
- ✅ Automated CI/CD pipeline
- ✅ Docker containerization
- ✅ Professional deployment workflow
- ✅ Version control with Git
- ✅ Cloud-based container registry

## 🔗 Next Steps

1. **Customize**: Modify the workflow for your specific needs
2. **Scale**: Add more environments or deployment targets
3. **Monitor**: Set up monitoring and alerting
4. **Security**: Add security scanning and compliance checks
5. **Documentation**: Keep this guide updated as you make changes

## 📞 Getting Help

If you encounter issues:
1. Check the GitHub Actions logs
2. Verify your Dockerfile syntax
3. Ensure all files are committed and pushed
4. Check GitHub's documentation for Actions
5. Ask questions in GitHub Discussions

---

**Happy Deploying! 🚀**
