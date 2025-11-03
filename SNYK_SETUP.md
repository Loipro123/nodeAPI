# Snyk Setup Guide

This guide explains how to configure Snyk for local development with your authentication token.

## Method 1: CLI Authentication (Recommended)

This is the easiest method and stores your credentials securely.

```bash
# Authenticate with Snyk (opens browser)
npm run security:snyk:auth
```

Or manually:
```bash
npx snyk auth
```

This will:
- Open your browser to authenticate with Snyk
- Store your credentials locally in `~/.config/configstore/snyk.json`
- Work across all projects on your machine

## Method 2: Environment Variable

If you prefer to use environment variables or for CI/CD environments:

1. **Create a `.env` file** (copy from `.env.example`):
   ```bash
   cp .env.example .env
   ```

2. **Add your Snyk token** to `.env`:
   ```env
   SNYK_TOKEN=your_actual_snyk_token_here
   NODE_ENV=development
   PORT=3000
   ```

3. **Load environment variables** in your application:
   ```bash
   # For testing with environment variables
   export SNYK_TOKEN=your_actual_token_here
   npm run security:snyk
   ```

## Method 3: Direct Token Configuration

You can also set the token directly using Snyk CLI:

```bash
# Set token directly
npx snyk config set api=your_snyk_token_here

# Verify configuration
npm run security:snyk:config
```

## Available Snyk Commands

After authentication, you can use these commands:

```bash
# Test for vulnerabilities
npm run security:snyk

# Monitor project (sends results to Snyk dashboard)
npm run security:snyk:monitor

# Re-authenticate if needed
npm run security:snyk:auth

# Check current configuration
npm run security:snyk:config
```

## Verification

Test that Snyk is working correctly:

```bash
# This should now work without authentication errors
npm run security:snyk
```

## CI/CD Integration

For automated environments, use the `SNYK_TOKEN` environment variable:

```yaml
# GitHub Actions example
env:
  SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

```dockerfile
# Docker example
ENV SNYK_TOKEN=your_token_here
RUN npx snyk test
```

## Security Notes

- ⚠️ **Never commit** your `.env` file or actual tokens to version control
- 🔒 The `.env.example` file is safe to commit (contains no real credentials)
- 🏠 CLI authentication stores credentials in your home directory securely
- 🔄 You can re-authenticate anytime with `npm run security:snyk:auth`

## Troubleshooting

### Authentication Error 401
- Run `npm run security:snyk:auth` to re-authenticate
- Check if your token is valid in the Snyk dashboard
- Verify environment variables are loaded correctly

### Command Not Found
- Use `npx snyk` instead of `snyk` directly
- Ensure Snyk is installed: `npm list snyk`

### Token Issues
- Generate a new token from: https://app.snyk.io/account
- Use the Service Account token for CI/CD environments