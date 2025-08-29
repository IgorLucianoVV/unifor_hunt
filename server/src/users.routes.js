const express = require('express');
const router = express.Router();
const db = require('../db');
const { authGuard } = require('./auth.routes');

// PUT /users/me  { nickname }
router.put('/me', authGuard, async (req, res) => {
  try {
    const { nickname } = req.body || {};
    if (!nickname || String(nickname).trim().length < 3)
      return res.status(400).json({ error: 'Nickname inválido' });

    const r = await db.query(
      `UPDATE users
         SET nickname = $1, updated_at = NOW()
       WHERE id = $2
       RETURNING id, email, nickname, points_total, created_at`,
      [String(nickname).trim(), req.user.sub]
    );
    return res.json({ user: r.rows[0] });
  } catch (e) {
    // conflito de UNIQUE em nickname
    if (e.code === '23505') return res.status(409).json({ error: 'Nickname já em uso' });
    console.error('update nickname error:', e);
    return res.status(500).json({ error: 'Erro interno' });
  }
});

module.exports = router;
