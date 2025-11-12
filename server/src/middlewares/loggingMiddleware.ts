import { Request, Response, NextFunction } from 'express';

// Request/Response logging middleware
export const requestLogger = (req: Request, res: Response, next: NextFunction) => {
  const startTime = Date.now();

  // Log incoming request
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  console.log(`Query: ${JSON.stringify(req.query)}`);
  if (req.method !== 'GET') {
    console.log(`Body: ${JSON.stringify(req.body)}`);
  }

  // Capture original send function
  const originalSend = res.send;

  // Override send to log response
  res.send = function (data: any) {
    const duration = Date.now() - startTime;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path} - Status: ${res.statusCode} - Duration: ${duration}ms`);
    
    // Call original send
    return originalSend.call(this, data);
  };

  next();
};

// Health check logger
export const healthCheckLogger = (req: Request, res: Response, next: NextFunction) => {
  if (req.path === '/api/health') {
    console.log(`[HEALTH CHECK] ${new Date().toISOString()} - System Status: OK`);
  }
  next();
};
