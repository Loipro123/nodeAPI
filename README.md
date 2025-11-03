# Node.js TypeScript API

A production-ready Node.js TypeScript API with comprehensive tooling, testing, security scanning, and CI/CD pipeline.

## ✨ Features

- 🚀 Express.js server with TypeScript
- 📝 Type safety with TypeScript
- 🛠️ Development and production builds
- 🔍 Health check endpoint
- 📦 Sample API endpoints
- 💅 Code formatting with Prettier
- 🔍 Code linting with ESLint
- 🔐 Security scanning with Snyk
- 🐳 Docker containerization
- 🏗️ Multi-stage Docker builds
- 🔧 Docker Compose for development

## 🚀 Getting Started

### Prerequisites

- Node.js (version 18 or higher)
- npm
- Docker (optional, for containerization)

### Installation

1. Install dependencies:
   ```bash
   npm install
   ```

### Development

Run in development mode with hot reload:

```bash
npm run dev
```

### Code Quality

Format code with Prettier:

```bash
npm run format
```

Check code formatting:

```bash
npm run format:check
```

Lint code with ESLint:

```bash
npm run lint
```

Auto-fix linting issues:

```bash
npm run lint:fix
```

### Security

Run security audit:

```bash
npm run security:audit
```

**Snyk Security Scanning:**

First-time setup (authenticate with your Snyk token):

```bash
npm run security:snyk:auth
```

Run Snyk security scan:

```bash
npm run security:snyk
```

Monitor project in Snyk dashboard:

```bash
npm run security:snyk:monitor
```

> 📋 **See [SNYK_SETUP.md](./SNYK_SETUP.md) for detailed Snyk configuration instructions**

### Build and Run

Build the project:

```bash
npm run build
```

Run the built application:

```bash
npm start
```

Clean build artifacts:

```bash
npm run clean
```

## 🐳 Docker Usage

### Build Docker Images

Build production image:

```bash
npm run docker:build
```

Build development image:

```bash
npm run docker:build:dev
```

### Run with Docker

Run production container:

```bash
npm run docker:run
```

Run development container with volume mounting:

```bash
npm run docker:run:dev
```

### Docker Compose

Run development environment:

```bash
npm run docker:compose:dev
```

Run production environment:

```bash
npm run docker:compose:prod
```

## API Endpoints

- `GET /` - Welcome message
- `GET /api/health` - Health check
- `GET /api/users` - Get all users
- `POST /api/users` - Create a new user

## 📁 Project Structure

```
nodeAPI/
├── src/
│   └── index.ts          # Main application file
├── dist/                 # Compiled JavaScript (generated)
├── node_modules/         # Dependencies
├── .eslintrc.json        # ESLint configuration
├── .prettierrc           # Prettier configuration
├── .prettierignore       # Prettier ignore rules
├── .snyk                 # Snyk security policy
├── .dockerignore         # Docker ignore rules
├── .gitignore           # Git ignore rules
├── Dockerfile           # Docker configuration
├── docker-compose.yml   # Docker Compose configuration
├── package.json         # Project dependencies and scripts
├── tsconfig.json        # TypeScript configuration
└── README.md           # Project documentation
```

## 📜 Available Scripts

| Script                          | Description                                       |
| ------------------------------- | ------------------------------------------------- |
| `npm run dev`                   | Start development server with hot reload          |
| `npm run build`                 | Compile TypeScript to JavaScript                  |
| `npm start`                     | Run the compiled application                      |
| `npm run clean`                 | Remove build artifacts                            |
| `npm run lint`                  | Run ESLint on source code                         |
| `npm run lint:fix`              | Auto-fix ESLint issues                            |
| `npm run format`                | Format code with Prettier                         |
| `npm run format:check`          | Check if code is properly formatted               |
| `npm run security:audit`        | Run npm security audit                            |
| `npm run security:snyk:auth`    | Authenticate with Snyk (first-time setup)         |
| `npm run security:snyk`         | Run Snyk security scan                            |
| `npm run security:snyk:monitor` | Monitor project in Snyk dashboard                 |
| `npm run security:snyk:config`  | Check Snyk configuration                          |
| `npm run docker:build`          | Build production Docker image                     |
| `npm run docker:run`            | Run production Docker container                   |
| `npm run docker:compose:dev`    | Start development environment with Docker Compose |

## Environment Variables

- `PORT` - Server port (default: 3000)

## 🔧 Configuration

### ESLint

The project uses ESLint with TypeScript support and Prettier integration. Configuration is in `.eslintrc.json`.

### Prettier

Code formatting rules are defined in `.prettierrc`. The configuration enforces consistent code style across the project.

### Snyk

Security scanning configuration is in `.snyk`. Run `snyk auth` first to authenticate before using Snyk commands.

### Docker

- **Dockerfile**: Multi-stage build with separate development and production targets
- **docker-compose.yml**: Orchestration for both development and production environments

## 🌐 Development

The server will start on `http://localhost:3000` by default.

### Example API calls:

Get all users:

```bash
curl http://localhost:3000/api/users
```

Create a user:

```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

Health check:

```bash
curl http://localhost:3000/api/health
```

## 🔐 Security

This project includes several security measures:

- **Snyk**: Vulnerability scanning for dependencies
- **npm audit**: Built-in npm security audit
- **ESLint**: Code quality and security linting rules
- **Docker**: Containerized deployment with non-root user
- **Dependencies**: Minimal production dependencies

## 🚢 Deployment

### Using Docker

1. Build the production image:

   ```bash
   docker build -t nodeapi .
   ```

2. Run the container:
   ```bash
   docker run -p 3000:3000 nodeapi
   ```

### Using Docker Compose

For production deployment:

```bash
docker-compose --profile production up -d
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run linting and formatting: `npm run lint:fix && npm run format`
5. Test your changes: `npm run build && npm start`
6. Run security checks: `npm run security:audit`
7. Submit a pull request

## 📄 License

MIT
