// server/src/auth.routes.js
const express = require('express');
const router = express.Router();
const db = require('../db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Rate limiting
const rateLimitModule = require('express-rate-limit');
const rateLimit = rateLimitModule.rateLimit || rateLimitModule;

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Muitas tentativas, tente mais tarde.' },
});

function isValidEmail(email){ return typeof email === 'string' && /\S+@\S+\.\S+/.test(email); }
function isValidPassword(pwd){ return typeof pwd === 'string' && pwd.length >= 6; }
function signToken(payload){ return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '2h' }); }

function authGuard(req,res,next){
  try{
    const header = req.headers.authorization || '';
    const [, token] = header.split(' ');
    if(!token) return res.status(401).json({ error: 'Token ausente' });
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  }catch(e){
    return res.status(401).json({ error: 'Token inválido ou expirado' });
  }
}

function isAdmin(req,res,next){
  if (req.user?.is_admin) return next();
  return res.status(403).json({ error: 'Apenas administradores' });
}

// POST /auth/register
router.post('/register', async (req,res)=>{
  try{
    const { email, password, nickname } = req.body || {};
    if(!isValidEmail(email)) return res.status(400).json({ error: 'Email inválido' });
    if(!isValidPassword(password)) return res.status(400).json({ error: 'Senha muito curta' });

    const exists = await db.query('SELECT 1 FROM users WHERE email = $1', [email.toLowerCase()]);
    if (exists.rowCount > 0) return res.status(409).json({ error: 'Email já cadastrado' });

    const hash = await bcrypt.hash(password, 12);
    const insert = await db.query(
      `INSERT INTO users (email, password_hash, nickname)
       VALUES ($1,$2,$3)
       RETURNING id, email, nickname, is_admin, created_at`,
      [email.toLowerCase(), hash, nickname || null]
    );
    const user = insert.rows[0];
    const token = signToken({ sub: user.id, email: user.email, is_admin: user.is_admin });
    return res.status(201).json({ user, token });
  }catch(e){
    console.error('register error:', e);
    return res.status(500).json({ error: 'Erro interno' });
  }
});

// POST /auth/login - COM RATE LIMITING
router.post('/login', loginLimiter, async (req,res)=>{
  try{
    const { email, password } = req.body || {};
    if(!isValidEmail(email) || typeof password !== 'string')
      return res.status(400).json({ error: 'Credenciais inválidas' });

    const r = await db.query(
      'SELECT id, email, password_hash, nickname, is_admin FROM users WHERE email=$1',
      [email.toLowerCase()]
    );
    if (r.rowCount === 0) return res.status(401).json({ error: 'Email ou senha incorretos' });

    const user = r.rows[0];
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ error: 'Email ou senha incorretos' });

    const token = signToken({ sub: user.id, email: user.email, is_admin: user.is_admin });
    delete user.password_hash;
    return res.json({ user, token });
  }catch(e){
    console.error('login error:', e);
    return res.status(500).json({ error: 'Erro interno' });
  }
});

// GET /auth/me
router.get('/me', authGuard, async (req,res)=>{
  try{
    const r = await db.query('SELECT id, email, nickname, points_total, is_admin, created_at FROM users WHERE id=$1', [req.user.sub]);
    if (r.rowCount === 0) return res.status(404).json({ error: 'Usuário não encontrado' });
    return res.json({ user: r.rows[0] });
  }catch(e){
    return res.status(500).json({ error: 'Erro interno' });
  }
});

module.exports = { router, authGuard, isAdmin };