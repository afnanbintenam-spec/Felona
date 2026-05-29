require('dotenv').config();

// ─── Environment Validation ──────────────────────────────────
const requiredEnvVars = ['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'JWT_SECRET', 'GEMINI_API_KEY'];
const missingVars = requiredEnvVars.filter(v => !process.env[v]);
if (missingVars.length > 0) {
  console.error(`❌ Missing required environment variables: ${missingVars.join(', ')}`);
  console.error('   Copy backend/.env.example to backend/.env and fill in your values.');
  process.exit(1);
}

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

const { sequelize } = require('./models');

// Routes
const authRoutes = require('./routes/auth');
const listingsRoutes = require('./routes/listings');
const pickupsRoutes = require('./routes/pickups');
const ecoRoutes = require('./routes/eco');
const aiRoutes = require('./routes/ai');

const app = express();
const PORT = process.env.PORT || 3000;

// ─── Rate Limiting (in-memory, simple) ───────────────────────
const rateLimitMap = new Map();
const RATE_LIMIT_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const RATE_LIMIT_MAX_REQUESTS = 100; // per window per IP
const AUTH_RATE_LIMIT_MAX = 10; // stricter for auth endpoints

function rateLimiter(maxRequests) {
  return (req, res, next) => {
    const key = `${req.ip}:${req.baseUrl}`;
    const now = Date.now();
    const entry = rateLimitMap.get(key);

    if (!entry || now - entry.start > RATE_LIMIT_WINDOW_MS) {
      rateLimitMap.set(key, { start: now, count: 1 });
      return next();
    }

    entry.count++;
    if (entry.count > maxRequests) {
      return res.status(429).json({
        error: 'Too many requests. Please try again later.',
        retryAfter: Math.ceil((entry.start + RATE_LIMIT_WINDOW_MS - now) / 1000),
      });
    }
    next();
  };
}

// ─── Middleware ───────────────────────────────────────────────
const allowedOrigins = process.env.CORS_ORIGINS
  ? process.env.CORS_ORIGINS.split(',').map(s => s.trim())
  : null; // null = allow all in development

app.use(cors({
  origin: allowedOrigins || true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
}));
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
  crossOriginOpenerPolicy: false,
}));
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files (uploads)
const uploadDir = process.env.UPLOAD_DIR || './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}
app.use('/uploads', express.static(path.resolve(uploadDir)));

// ─── Routes ──────────────────────────────────────────────────
app.use('/auth', rateLimiter(AUTH_RATE_LIMIT_MAX), authRoutes);
app.use('/listings', rateLimiter(RATE_LIMIT_MAX_REQUESTS), listingsRoutes);
app.use('/pickups', rateLimiter(RATE_LIMIT_MAX_REQUESTS), pickupsRoutes);
app.use('/eco', rateLimiter(RATE_LIMIT_MAX_REQUESTS), ecoRoutes);
app.use('/ai', rateLimiter(AUTH_RATE_LIMIT_MAX), aiRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ─── Error Handler ───────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error',
  });
});

// 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// ─── Start Server ────────────────────────────────────────────
const start = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connected');

    // Sync models (creates tables if they don't exist)
    await sequelize.sync({ alter: process.env.NODE_ENV === 'development' });
    console.log('✅ Models synced');

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 FeloNa API running on http://0.0.0.0:${PORT}`);
      console.log(`📋 Environment: ${process.env.NODE_ENV}`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error.message);
    console.log('\n💡 Make sure PostgreSQL is running and the database exists.');
    console.log('   Run: createdb felona');
    process.exit(1);
  }
};

start();
