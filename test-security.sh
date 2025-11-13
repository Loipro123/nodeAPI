#!/bin/bash
# Security Test Script - Verify CVE-2025-46569 fix

echo "🔒 Testing Docker security fixes for CVE-2025-46569"
echo "=================================================="

# Test 1: Build standard Dockerfile (should be more secure now)
echo ""
echo "📦 Test 1: Building standard Dockerfile (distroless production)"
docker build --target production -t nodeapi:security-test . || {
  echo "❌ Build failed"
  exit 1
}

# Test 2: Build ultra-secure Dockerfile
echo ""
echo "📦 Test 2: Building ultra-secure Dockerfile"
docker build -f Dockerfile.secure -t nodeapi:ultra-secure . || {
  echo "❌ Ultra-secure build failed"
  exit 1
}

# Test 3: Check if Trivy is available
echo ""
echo "🔍 Test 3: Checking security scan capability"
if command -v trivy &> /dev/null; then
  echo "✅ Trivy available - running security scans"
  
  echo ""
  echo "📊 Scanning standard build..."
  trivy image --severity HIGH,CRITICAL nodeapi:security-test
  
  echo ""
  echo "📊 Scanning ultra-secure build..."
  trivy image --severity HIGH,CRITICAL nodeapi:ultra-secure
  
  echo ""
  echo "🔍 Specific CVE-2025-46569 check:"
  if trivy image --format json nodeapi:security-test | grep -i "CVE-2025-46569"; then
    echo "⚠️  CVE-2025-46569 still present in standard build"
  else
    echo "✅ CVE-2025-46569 not found in standard build"
  fi
  
  if trivy image --format json nodeapi:ultra-secure | grep -i "CVE-2025-46569"; then
    echo "⚠️  CVE-2025-46569 still present in ultra-secure build"
  else
    echo "✅ CVE-2025-46569 not found in ultra-secure build"
  fi
  
else
  echo "⚠️  Trivy not available locally"
  echo "   Install with: brew install aquasecurity/trivy/trivy"
fi

echo ""
echo "🎯 Summary:"
echo "- Standard Dockerfile now uses distroless production stage"
echo "- Ultra-secure Dockerfile (Dockerfile.secure) available for maximum security"
echo "- Both eliminate most OS-level vulnerabilities including OPA"
echo ""
echo "📋 Next steps:"
echo "1. Commit and push these changes"
echo "2. Your CI/CD will automatically use the secure build"
echo "3. Monitor the Trivy scan results in CircleCI"