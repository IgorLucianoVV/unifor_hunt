require('dotenv').config();
const express = require('express');

const app = express();
app.use(express.json());

console.log('=== TESTANDO ROTAS INDIVIDUALMENTE ===\n');

// Teste 1: Auth routes
console.log('1. Testando AUTH routes...');
try {
  const authMod = require('./src/auth.routes.js');
  const authRoutes = authMod.router;
  app.use('/auth', authRoutes);
  console.log('✅ AUTH routes OK\n');
} catch (error) {
  console.error('❌ ERRO em AUTH routes:', error.message);
  console.error('Stack:', error.stack);
  process.exit(1);
}

// Teste 2: User routes
console.log('2. Testando USER routes...');
try {
  const userRoutes = require('./src/users.routes.js');
  app.use('/users', userRoutes);
  console.log('✅ USER routes OK\n');
} catch (error) {
  console.error('❌ ERRO em USER routes:', error.message);
  console.error('Stack:', error.stack);
  process.exit(1);
}

// Teste 3: Missions routes
console.log('3. Testando MISSIONS routes...');
try {
  const missionsRoutes = require('./src/missions.routes.js');
  console.log('  - Módulo carregado, agora registrando rotas...');
  app.use('/missions', missionsRoutes);
  console.log('✅ MISSIONS routes OK\n');
} catch (error) {
  console.error('❌ ERRO em MISSIONS routes:', error.message);
  console.error('Stack:', error.stack);
  process.exit(1);
}

console.log('4. Iniciando servidor...');
const port = 3000;
app.listen(port, () => {
  console.log('🎉 TODOS OS TESTES PASSARAM!');
  console.log(`🚀 Servidor funcionando em http://localhost:${port}`);
});