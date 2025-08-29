// server/src/missions.routes.js
const express = require('express');
const router = express.Router();
const db = require('../db');
const crypto = require('crypto');
const { authGuard, isAdmin } = require('./auth.routes.js');

const sha256 = (s) =>
  crypto.createHash('sha256').update(String(s), 'utf8').digest('hex');

/* ===========================================
 *                ROTAS PÚBLICAS
 * ===========================================
 */

// GET /missions -> lista missões ativas
router.get('/', async (_req, res) => {
  try {
    const r = await db.query(
      `SELECT id, title, description, reward_points, is_active, end_at
         FROM missions
        WHERE is_active = TRUE
        ORDER BY sort_order, created_at DESC`
    );
    return res.json({ missions: r.rows });
  } catch (e) {
    console.error('missions list error:', e);
    return res.status(500).json({ error: 'Erro interno' });
  }
});

// GET /missions/:id/progress  (defina ANTES de /:id)
router.get('/:id/progress', authGuard, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.sub;

    const totalQ = await db.query(
      `SELECT COUNT(*)::int AS c FROM mission_clues WHERE mission_id=$1`,
      [id]
    );
    const totalClues = totalQ.rows[0]?.c ?? 0;

    const p = await db.query(
      `SELECT status, current_clue_idx
         FROM user_mission_progress
        WHERE user_id=$1 AND mission_id=$2`,
      [userId, id]
    );

    if (p.rowCount === 0) {
      // Sem progresso ainda: retorna 404 + baseline
      return res.status(404).json({
        current_clue_idx: 0,
        total_clues: totalClues,
        status: 'in_progress',
      });
    }

    return res.json({
      current_clue_idx: p.rows[0].current_clue_idx,
      total_clues: totalClues,
      status: p.rows[0].status,
    });
  } catch (e) {
    console.error('missions progress error:', e);
    return res.status(500).json({ error: 'Erro interno' });
  }
});

// POST /missions/:id/attempt  (defina ANTES de /:id)
router.post('/:id/attempt', authGuard, async (req, res) => {
  const { id } = req.params; // mission id
  const userId = req.user.sub;
  const { payload } = req.body || {};
  if (!payload) return res.status(400).json({ error: 'payload obrigatório' });

  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');

    const totalQ = await client.query(
      `SELECT COUNT(*)::int AS c FROM mission_clues WHERE mission_id=$1`,
      [id]
    );
    const totalClues = totalQ.rows[0]?.c ?? 0;

    // Garante progress record
    await client.query(
      `INSERT INTO user_mission_progress (user_id, mission_id, status, current_clue_idx)
       VALUES ($1,$2,'in_progress',0)
       ON CONFLICT (user_id, mission_id) DO NOTHING`,
      [userId, id]
    );

    // Pega a pista atual (lock de linha)
    const curQ = await client.query(
      `SELECT ump.current_clue_idx, mc.id AS clue_id, mc.answer_hash
         FROM user_mission_progress ump
         JOIN mission_clues mc
           ON mc.mission_id = ump.mission_id
          AND mc.clue_index = ump.current_clue_idx
        WHERE ump.user_id=$1 AND ump.mission_id=$2
        FOR UPDATE`,
      [userId, id]
    );

    if (curQ.rowCount === 0) {
      await client.query('COMMIT');
      return res.status(404).json({
        error: 'Progresso não encontrado',
        current_clue_idx: 0,
        total_clues: totalClues,
      });
    }

    const row = curQ.rows[0];
    const ok = String(row.answer_hash || '') === sha256(payload);

    // Log de tentativa
    await client.query(
      `INSERT INTO user_clue_attempts (user_id, clue_id, attempt, is_correct)
       VALUES ($1,$2,$3,$4)`,
      [userId, row.clue_id, String(payload), ok]
    );

    if (!ok) {
      await client.query('COMMIT');
      return res.json({
        ok: false,
        current_clue_idx: row.current_clue_idx,
        total_clues: totalClues,
        completed: false,
      });
    }

    // Avança para a próxima pista
    const nextIdx = row.current_clue_idx + 1;
    const completed = nextIdx >= totalClues;

    if (completed) {
      // Finaliza missão
      await client.query(
        `UPDATE user_mission_progress
            SET status='completed', completed_at=NOW()
          WHERE user_id=$1 AND mission_id=$2`,
        [userId, id]
      );

      // Premia pontos
      const rewardQ = await client.query(
        `SELECT reward_points FROM missions WHERE id=$1`,
        [id]
      );
      const reward = Number(rewardQ.rows[0]?.reward_points ?? 0);

      if (reward !== 0) {
        await client.query(
          `INSERT INTO user_points_ledger (user_id, mission_id, delta, reason)
           VALUES ($1,$2,$3,'mission_completed')`,
          [userId, id, reward]
        );
        await client.query(
          `UPDATE users SET points_total = points_total + $2 WHERE id=$1`,
          [userId, reward]
        );
      }

      await client.query('COMMIT');
      return res.json({
        ok: true,
        current_clue_idx: nextIdx,
        total_clues: totalClues,
        completed: true,
      });
    } else {
      // Atualiza índice atual
      await client.query(
        `UPDATE user_mission_progress
            SET current_clue_idx=$1
          WHERE user_id=$2 AND mission_id=$3`,
        [nextIdx, userId, id]
      );

      await client.query('COMMIT');
      return res.json({
        ok: true,
        current_clue_idx: nextIdx,
        total_clues: totalClues,
        completed: false,
      });
    }
  } catch (e) {
    await client.query('ROLLBACK');
    console.error('missions attempt error:', e);
    return res.status(500).json({ error: 'Erro interno' });
  } finally {
    client.release();
  }
});

// GET /missions/:id  (depois das rotas acima)
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const m = await db.query(
      `SELECT id, title, description, reward_points, end_at
         FROM missions
        WHERE id=$1 AND is_active=TRUE`,
      [id]
    );
    if (m.rowCount === 0)
      return res.status(404).json({ error: 'Missão não encontrada' });

    const clues = await db.query(
      `SELECT id, clue_index, type, content, answer_meta
         FROM mission_clues
        WHERE mission_id=$1
        ORDER BY clue_index ASC`,
      [id]
    );

    return res.json({
      id: m.rows[0].id,
      title: m.rows[0].title,
      description: m.rows[0].description,
      reward_points: m.rows[0].reward_points,
      end_at: m.rows[0].end_at,
      clues: clues.rows,
    });
  } catch (e) {
    console.error('missions get detail error:', e);
    return res.status(500).json({ error: 'Erro interno' });
  }
});

/* ===========================================
 *              ROTAS DE ADMIN
 * ===========================================
 */

// POST /missions -> cria missão (aceita end_at)
router.post('/', authGuard, isAdmin, async (req, res) => {
  try {
    const { title, description, reward_points, end_at } = req.body || {};
    if (!title || String(title).trim().length < 3)
      return res.status(400).json({ error: 'Título inválido' });

    // Validar end_at se veio string
    let endAtValue = null;
    if (end_at != null) {
      const d = new Date(end_at);
      if (isNaN(d.getTime())) {
        return res.status(400).json({ error: 'end_at inválido (use ISO-8601)' });
      }
      endAtValue = d.toISOString(); // salva em UTC
    }

    const r = await db.query(
      `INSERT INTO missions (title, description, reward_points, is_active, sort_order, end_at)
       VALUES ($1,$2,$3,TRUE,0,$4)
       RETURNING id, title, description, reward_points, is_active, end_at`,
      [String(title).trim(), description || null, Number(reward_points || 0), endAtValue]
    );

    return res.status(201).json({ mission: r.rows[0] });
  } catch (e) {
    console.error('create mission error:', e);
    return res.status(500).json({ error: 'Erro interno' });
  }
});

// POST /missions/:id/clues -> cria pista
router.post('/:id/clues', authGuard, isAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const {
      clue_index,
      type,
      content,
      answerPlain,
      answerHash,
      answer_meta,
    } = req.body || {};

    if (typeof clue_index !== 'number') {
      return res.status(400).json({ error: 'clue_index numérico é obrigatório' });
    }
    if (!type || !content) {
      return res.status(400).json({ error: 'type e content são obrigatórios' });
    }

    const hash = answerHash || sha256(answerPlain ?? '');
    const meta =
      answer_meta && typeof answer_meta === 'object' ? answer_meta : {};

    const r = await db.query(
      `INSERT INTO mission_clues (mission_id, clue_index, type, content, answer_hash, answer_meta)
       VALUES ($1,$2,$3,$4,$5,$6)
       RETURNING id, mission_id, clue_index, type, content, answer_meta`,
      [id, clue_index, String(type), String(content), hash, meta]
    );

    return res.status(201).json({ clue: r.rows[0] });
  } catch (e) {
    console.error('create clue error:', e);
    return res.status(500).json({ error: 'Erro interno' });
  }
});

module.exports = router;
