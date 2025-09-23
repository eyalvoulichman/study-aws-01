#!/bin/bash

# GitHub Actions Deployment Script for Python Webserver
# This script can be used in GitHub Actions workflows or locally

set -e  # Exit on any error

# Configuration
APP_NAME="python-webserver"
DOCKER_IMAGE="${DOCKER_IMAGE:-python-webserver}"
DOCKER_TAG="${DOCKER_TAG:-latest}"
DEPLOYMENT_TYPE="${DEPLOYMENT_TYPE:-docker}"  # docker, direct, systemd
TARGET_HOST="${TARGET_HOST:-localhost}"
TARGET_PORT="${TARGET_PORT:-8000}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running in GitHub Actions
is_github_actions() {
    [ -n "$GITHUB_ACTIONS" ] && [ "$GITHUB_ACTIONS" = "true" ]
}

# Deploy using Docker
deploy_docker() {
    log_info "Deploying using Docker..."
    
    if is_github_actions; then
        # In GitHub Actions, use registry image
        log_info "Running in GitHub Actions environment"
        docker run -d \
            --name ${APP_NAME}-${GITHUB_RUN_ID} \
            -p ${TARGET_PORT}:8000 \
            --restart unless-stopped \
            ${DOCKER_IMAGE}:${DOCKER_TAG}
    else
        # Local deployment
        log_info "Building Docker image locally..."
        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
        
        # Stop existing container if running
        if [ "$(docker ps -q -f name=${APP_NAME})" ]; then
            log_warning "Stopping existing container..."
            docker stop ${APP_NAME}
            docker rm ${APP_NAME}
        fi
        
        # Run new container
        docker run -d \
            --name ${APP_NAME} \
            -p ${TARGET_PORT}:8000 \
            --restart unless-stopped \
            ${DOCKER_IMAGE}:${DOCKER_TAG}
    fi
    
    log_success "Docker deployment completed!"
}

# Deploy directly with Python
deploy_direct() {
    log_info "Deploying directly with Python..."
    
    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 is not installed"
        exit 1
    fi
    
    # Check if port is available
    if lsof -Pi :${TARGET_PORT} -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "Port ${TARGET_PORT} is already in use"
        exit 1
    fi
    
    # Start Python server
    log_info "Starting Python webserver on port ${TARGET_PORT}..."
    nohup python3 simple_server.py > webserver.log 2>&1 &
    echo $! > webserver.pid
    
    log_success "Direct deployment completed!"
}

# Deploy as systemd service
deploy_systemd() {
    log_info "Deploying as systemd service..."
    
    if [ "$EUID" -ne 0 ]; then
        log_error "This deployment method requires root privileges"
        exit 1
    fi
    
    # Create service directory
    mkdir -p /opt/${APP_NAME}
    cp simple_server.py /opt/${APP_NAME}/
    cp index.html /opt/${APP_NAME}/
    chown -R www-data:www-data /opt/${APP_NAME}
    
    # Create systemd service
    cat > /etc/systemd/system/${APP_NAME}.service << EOF
[Unit]
Description=Python Webserver
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/${APP_NAME}
ExecStart=/usr/bin/python3 /opt/${APP_NAME}/simple_server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # Enable and start service
    systemctl daemon-reload
    systemctl enable ${APP_NAME}
    systemctl start ${APP_NAME}
    
    log_success "Systemd service deployment completed!"
}

# Health check
health_check() {
    log_info "Performing health check..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s http://${TARGET_HOST}:${TARGET_PORT} > /dev/null 2>&1; then
            log_success "Health check passed! Service is responding."
            return 0
        fi
        
        log_info "Health check attempt $attempt/$max_attempts - waiting..."
        sleep 2
        ((attempt++))
    done
    
    log_error "Health check failed after $max_attempts attempts"
    return 1
}

# Main deployment function
main() {
    log_info "Starting deployment of ${APP_NAME}..."
    log_info "Deployment type: ${DEPLOYMENT_TYPE}"
    log_info "Target: ${TARGET_HOST}:${TARGET_PORT}"
    
    if is_github_actions; then
        log_info "Running in GitHub Actions environment"
        log_info "Workflow: ${GITHUB_WORKFLOW}"
        log_info "Run ID: ${GITHUB_RUN_ID}"
    fi
    
    case $DEPLOYMENT_TYPE in
        "docker")
            deploy_docker
            ;;
        "direct")
            deploy_direct
            ;;
        "systemd")
            deploy_systemd
            ;;
        *)
            log_error "Unknown deployment type: ${DEPLOYMENT_TYPE}"
            log_info "Supported types: docker, direct, systemd"
            exit 1
            ;;
    esac
    
    # Perform health check
    if health_check; then
        log_success "Deployment completed successfully!"
        log_info "🌐 Access your webserver at: http://${TARGET_HOST}:${TARGET_PORT}"
    else
        log_error "Deployment completed but health check failed"
        exit 1
    fi
}

# Run main function
main "$@"
