// server/server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const { router: authRoutes } = require('./src/auth.routes.js');
const userRoutes = require('./src/users.routes.js');
const missionsRoutes = require('./src/missions.routes.js');

const app = express();

// Log simples
app.use((req, _res, next) => { console.log(req.method, req.url); next(); });

// CORS + JSON
app.use(cors({ origin: true }));
app.use(express.json());

// Limitador só no POST /auth/login
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Muitas tentativas, tente mais tarde.' },
});

// Montagem das rotas (caminhos FIXOS)
app.use('/auth/login', loginLimiter);
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/missions', missionsRoutes);

// Health
app.get('/health', (_req, res) => res.json({ ok: true }));

const port = process.env.PORT || 3000;
app.listen(port, '0.0.0.0', () => console.log(`API rodando em http://localhost:${port}`));
