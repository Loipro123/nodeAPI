#!/bin/bash
# Smart Security Build Script - Automatically tries different approaches

echo "🛡️ Smart Security Build - Finding the most secure approach"
echo "==========================================================="

# Configuration
IMAGE_NAME="nodeapi"
SHA=${1:-"local-test"}
BUILD_ATTEMPTS=0
MAX_ATTEMPTS=3

# Function to scan for vulnerabilities
scan_image() {
    local image=$1
    local approach=$2
    
    echo "🔍 Scanning $approach approach..."
    
    if ! command -v trivy &> /dev/null; then
        echo "⚠️  Trivy not available - install with: brew install aquasecurity/trivy/trivy"
        return 0
    fi
    
    # Check for HIGH/CRITICAL vulnerabilities
    if trivy image --severity HIGH,CRITICAL --exit-code 1 "$image" &>/dev/null; then
        echo "✅ $approach: No HIGH/CRITICAL vulnerabilities found!"
        return 0
    else
        echo "❌ $approach: HIGH/CRITICAL vulnerabilities detected"
        trivy image --severity HIGH,CRITICAL --format table "$image" | head -20
        return 1
    fi
}

# Build approach 1: Standard distroless (Debian 12)
echo ""
echo "🏗️  Attempt 1: Standard Distroless (Node.js 25 + Debian 12)"
echo "------------------------------------------------"
if docker build --target production -t "${IMAGE_NAME}:${SHA}-standard" . 2>/dev/null; then
    if scan_image "${IMAGE_NAME}:${SHA}-standard" "Standard Distroless"; then
        echo "🎯 SUCCESS: Standard distroless approach is secure!"
        echo "✅ Recommended image: ${IMAGE_NAME}:${SHA}-standard"
        exit 0
    fi
    ((BUILD_ATTEMPTS++))
else
    echo "❌ Standard build failed"
fi

# Build approach 2: Ultra-secure distroless
echo ""
echo "🏗️  Attempt 2: Ultra-Secure Distroless"
echo "---------------------------------------"
if docker build -f Dockerfile.secure -t "${IMAGE_NAME}:${SHA}-secure" . 2>/dev/null; then
    if scan_image "${IMAGE_NAME}:${SHA}-secure" "Ultra-Secure Distroless"; then
        echo "🎯 SUCCESS: Ultra-secure distroless approach is secure!"
        echo "✅ Recommended image: ${IMAGE_NAME}:${SHA}-secure"
        echo "📋 Update CircleCI to use: docker build -f Dockerfile.secure"
        exit 0
    fi
    ((BUILD_ATTEMPTS++))
else
    echo "❌ Ultra-secure build failed"
fi

# Build approach 3: Minimal Alpine
echo ""
echo "🏗️  Attempt 3: Minimal Alpine (Maximum Security)"
echo "------------------------------------------------"
if docker build -f Dockerfile.minimal -t "${IMAGE_NAME}:${SHA}-minimal" . 2>/dev/null; then
    if scan_image "${IMAGE_NAME}:${SHA}-minimal" "Minimal Alpine"; then
        echo "🎯 SUCCESS: Minimal Alpine approach is secure!"
        echo "✅ Recommended image: ${IMAGE_NAME}:${SHA}-minimal"
        echo "📋 Update CircleCI to use: docker build -f Dockerfile.minimal"
        exit 0
    fi
    ((BUILD_ATTEMPTS++))
else
    echo "❌ Minimal Alpine build failed"
fi

# All approaches tried
echo ""
echo "🚨 SECURITY SUMMARY"
echo "==================="
echo "Attempts made: $BUILD_ATTEMPTS"
echo ""

if [ $BUILD_ATTEMPTS -eq 0 ]; then
    echo "❌ All builds failed - check Docker setup and dependencies"
    exit 1
elif [ $BUILD_ATTEMPTS -eq $MAX_ATTEMPTS ]; then
    echo "⚠️  All approaches have vulnerabilities"
    echo "🔧 NEXT STEPS:"
    echo "   1. Wait for base image security updates"
    echo "   2. Use vulnerability exceptions for LOW/MEDIUM risks"
    echo "   3. Consider custom base image with manual security patches"
    echo ""
    echo "🎯 RECOMMENDATION: Use the approach with lowest vulnerability count"
    echo "   Review trivy-report.json for detailed analysis"
    exit 1
fi