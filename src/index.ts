import express, { Request, Response } from 'express';

const app = express();
const PORT = Number(process.env.PORT) || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req: Request, res: Response) => {
  res.json({
    message: 'Hello World! Welcome to your Node.js TypeScript API',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

app.get('/api/health', (req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

app.get('/api/users', (req: Request, res: Response) => {
  const users = [
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
    { id: 3, name: 'Bob Johnson', email: 'bob@example.com' },
  ];

  res.json({
    success: true,
    data: users,
    count: users.length,
  });
});

app.post('/api/users', (req: Request, res: Response): void => {
  const { name, email } = req.body;

  if (!name || !email) {
    res.status(400).json({
      success: false,
      message: 'Name and email are required',
    });
    return;
  }

  const newUser = {
    id: Date.now(),
    name,
    email,
  };

  res.status(201).json({
    success: true,
    message: 'User created successfully',
    data: newUser,
  });
});

// 404 handler
app.use('*', (req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// Start server only if this file is run directly
if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server is running on http://0.0.0.0:${PORT}`);
  });
}

export default app;
