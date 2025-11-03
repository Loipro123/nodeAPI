#!/usr/bin/env bash
set -euo pipefail

# Docker Security Scanner Script for Local Development
# This script mirrors the docker-security-scan job from CircleCI

IMAGE_NAME="nodeapi-local"
REPORT_FILE="trivy-report.json"

echo "🔒 Running local Docker security scan..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Error: Docker is not running. Please start Docker and try again."
  exit 1
fi

# Check if Trivy is installed
if ! command -v trivy &> /dev/null; then
  echo "📦 Trivy not found. Installing..."
  
  # Detect OS and install Trivy
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v brew &> /dev/null; then
      brew install trivy
    else
      echo "❌ Homebrew not found. Please install Trivy manually:"
      echo "   Visit: https://aquasecurity.github.io/trivy/latest/getting-started/installation/"
      exit 1
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    sudo apt-get update
    sudo apt-get install wget apt-transport-https gnupg lsb-release -y
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install trivy -y
  else
    echo "❌ Unsupported OS. Please install Trivy manually:"
    echo "   Visit: https://aquasecurity.github.io/trivy/latest/getting-started/installation/"
    exit 1
  fi
fi

echo "🏗️ Building Docker image for security scanning..."
docker build -t "$IMAGE_NAME:latest" .

echo "🔍 Scanning Docker image for vulnerabilities..."

# Run Trivy scan with JSON output
trivy image --severity HIGH,CRITICAL --format json --output "$REPORT_FILE" "$IMAGE_NAME:latest" || true

# Run Trivy scan with table output for immediate viewing
echo ""
echo "📊 Security Scan Results:"
echo "========================"
trivy image --severity HIGH,CRITICAL "$IMAGE_NAME:latest" || {
  echo ""
  echo "⚠️  High or critical vulnerabilities found in Docker image"
  echo "📄 Detailed report saved to: $REPORT_FILE"
  echo ""
  
  # Show summary if jq is available
  if command -v jq &> /dev/null && [ -f "$REPORT_FILE" ]; then
    echo "📈 Vulnerability Summary:"
    jq -r '.Results[]? | select(.Vulnerabilities) | "  " + .Target + ": " + (.Vulnerabilities | length | tostring) + " vulnerabilities"' "$REPORT_FILE" 2>/dev/null || true
  fi
  
  echo ""
  echo "💡 To view the full report:"
  echo "   cat $REPORT_FILE | jq ."
  echo ""
  
  # Don't exit with error for now, just warn
  exit 0
}

echo ""
echo "✅ Docker security scan completed"
echo "📄 Report saved to: $REPORT_FILE"

# Clean up the image
docker rmi "$IMAGE_NAME:latest" 2>/dev/null || true

echo "🧹 Cleanup completed"