#!/bin/bash

# Deploy Python Webserver Directly (No Kubernetes)
echo "🚀 Deploying Python Webserver directly..."

# Step 1: Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python3 first."
    exit 1
fi

# Step 2: Check if port 8000 is available
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Port 8000 is already in use. Please stop the service using that port first."
    echo "   You can find the process using: lsof -i :8000"
    exit 1
fi

# Step 3: Start the Python server
echo "🌐 Starting Python webserver on port 8000..."
echo "📁 Serving files from: $(pwd)"
echo "🔗 Access your webserver at: http://localhost:8000"
echo "⏹️  Press Ctrl+C to stop the server"
echo ""

# Start the server
python3 simple_server.py
