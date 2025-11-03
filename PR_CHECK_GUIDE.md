# PR Check Scripts Documentation

This document explains the comprehensive quality check scripts available in this project.

## 🚀 Main PR Check Scripts

### `npm run pr-check`

**Purpose**: Complete pre-deployment quality check  
**Use**: Run before creating a pull request or deploying

**What it does:**

1. 🧹 **Clean**: Removes old build artifacts
2. 🔍 **Type Check**: Validates TypeScript types without emitting files
3. 💅 **Format Check**: Ensures code follows Prettier formatting rules
4. 🔍 **Lint**: Checks code quality with ESLint
5. 🧪 **Test**: Runs unit tests with coverage reporting
6. 🔒 **Security Audit**: Checks for npm vulnerabilities
7. 🛡️ **Snyk Check**: Scans for security vulnerabilities
8. 🏗️ **Build**: Compiles TypeScript to ensure no build errors

**Command:**

```bash
npm run pr-check
```

### `npm run pr-check:fix`

**Purpose**: Auto-fix issues where possible, then run checks  
**Use**: When you want to automatically fix formatting and linting issues

**What it does:**

1. 🧹 **Clean**: Removes old build artifacts
2. 💅 **Format**: Auto-formats code with Prettier
3. 🔧 **Lint Fix**: Auto-fixes ESLint issues where possible
4. 🧪 **Test**: Runs unit tests with coverage
5. 🔒 **Security Audit**: Checks for npm vulnerabilities
6. 🛡️ **Snyk Check**: Scans for security vulnerabilities
7. 🏗️ **Build**: Compiles TypeScript

**Command:**

```bash
npm run pr-check:fix
```

### `npm run pre-commit`

**Purpose**: Lightweight check for commit hooks  
**Use**: Quick validation before committing code

**What it does:**

1. 💅 **Format Check**: Ensures proper formatting
2. 🔍 **Lint**: Checks code quality
3. 🔍 **Type Check**: Validates TypeScript types

**Command:**

```bash
npm run pre-commit
```

## 🧪 Testing Scripts

| Script                  | Purpose                             | Coverage |
| ----------------------- | ----------------------------------- | -------- |
| `npm test`              | Run all tests                       | Basic    |
| `npm run test:watch`    | Run tests in watch mode             | Basic    |
| `npm run test:coverage` | Run tests with coverage report      | Full     |
| `npm run test:ci`       | Run tests for CI (no watch, silent) | Full     |

## 🔍 Quality Check Scripts

| Script                 | Purpose                   | Auto-fix |
| ---------------------- | ------------------------- | -------- |
| `npm run typecheck`    | TypeScript type checking  | ❌       |
| `npm run lint`         | ESLint code quality check | ❌       |
| `npm run lint:fix`     | ESLint with auto-fix      | ✅       |
| `npm run format:check` | Prettier format check     | ❌       |
| `npm run format`       | Auto-format with Prettier | ✅       |

## 🔒 Security Scripts

| Script                   | Purpose                 | Requirements |
| ------------------------ | ----------------------- | ------------ |
| `npm run security:audit` | npm security audit      | None         |
| `npm run security:snyk`  | Snyk vulnerability scan | Snyk auth    |

## 📋 Recommended Workflow

### Before Creating a PR:

```bash
# Option 1: Auto-fix and check everything
npm run pr-check:fix

# Option 2: Check everything (fails if issues found)
npm run pr-check
```

### During Development:

```bash
# Quick pre-commit check
npm run pre-commit

# Run tests in watch mode
npm run test:watch
```

### CI/CD Pipeline:

```bash
# Use in your GitHub Actions or CI
npm run pr-check
```

## ⚠️ Important Notes

1. **Snyk Authentication**: Ensure you're authenticated with Snyk (`npm run security:snyk:auth`)
2. **Coverage Thresholds**: Tests must maintain 70% coverage (configured in jest.config.js)
3. **Format Standards**: Code must pass Prettier formatting checks
4. **Lint Rules**: Code must pass ESLint quality checks
5. **Type Safety**: All TypeScript types must be valid

## 🚫 What Causes Failures

- **Format Check**: Code not formatted according to Prettier rules
- **Lint Check**: ESLint errors or warnings
- **Type Check**: TypeScript compilation errors
- **Tests**: Failed unit tests or coverage below threshold
- **Security**: Known vulnerabilities in dependencies
- **Build**: TypeScript compilation fails

## 🔧 Fixing Issues

1. **Formatting Issues**: Run `npm run format`
2. **Linting Issues**: Run `npm run lint:fix`
3. **Test Failures**: Fix failing tests in `/tests` directory
4. **Type Errors**: Fix TypeScript errors in source code
5. **Security Issues**: Update vulnerable dependencies
6. **Build Errors**: Fix TypeScript compilation errors

## 📊 Coverage Reports

After running tests with coverage, view reports:

- **Terminal**: Displayed automatically
- **HTML**: Open `coverage/lcov-report/index.html` in browser
- **LCOV**: `coverage/lcov.info` for CI integration
