import express, { Request, Response } from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';

import authRoutes from './routes/auth';
import productRoutes from './routes/products';
import errorMiddleware from './middlewares/errorMiddleware';
import { requestLogger, healthCheckLogger } from './middlewares/loggingMiddleware';

dotenv.config();

const app = express();
app.use(express.json());

// Logging middleware
app.use(requestLogger);
app.use(healthCheckLogger);

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);

// Health check endpoint for deployment verification
app.get('/api/health', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
  });
});

// Root endpoint
app.get('/', (req: Request, res: Response) => {
  res.send('Feriwala E-commerce API');
});

// Error handling middleware (must be last)
app.use(errorMiddleware);

const port = process.env.PORT || 3000;
const mongoURL = process.env.MONGO_URL;

if (!mongoURL) {
  console.error('MONGO_URL is not defined in the .env file');
  process.exit(1);
}

const jwtSecret = process.env.JWT_SECRET;
if (!jwtSecret) {
  console.error('JWT_SECRET is not defined in the .env file');
  process.exit(1);
}

mongoose.connect(mongoURL)
  .then(() => {
    console.log('Connected to MongoDB');
    app.listen(port, () => {
      console.log(`Server is running on port ${port}`);
    });
  })
  .catch((error) => {
    console.error('Error connecting to MongoDB:', error);
  });

app.get('/', (req, res) => {
  res.send('Hello World!');
});
