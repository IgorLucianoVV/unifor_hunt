import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class AdminCreateMissionScreen extends StatefulWidget {
  const AdminCreateMissionScreen({super.key});

  @override
  State<AdminCreateMissionScreen> createState() => _AdminCreateMissionScreenState();
}

class _AdminCreateMissionScreenState extends State<AdminCreateMissionScreen> {
  final String _baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://127.0.0.1:3000',
  );

  final _formKey = GlobalKey<FormState>();

  // Campos da missão
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController(text: '100');

  String _difficulty = 'easy'; // easy | medium | hard
  DateTime? _endDate; // data + hora

  bool _submitting = false;
  String? _authError;
  bool _isAdmin = false;

  // Lista de pistas
  final List<_ClueModel> _clues = [
    _ClueModel(), // começa com 1 pista por padrão
  ];

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    for (final c in _clues) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _checkAdmin() async {
    try {
      final me = await AuthService().getMe();
      final user = (me['user'] as Map?) ?? {};
      setState(() {
        _isAdmin = user['is_admin'] == true;
      });
    } catch (e) {
      setState(() {
        _authError = 'Você precisa estar autenticado como administrador.';
      });
    }
  }

  Future<void> _pickEndDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      helpText: 'Escolha a data de encerramento',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryDark,
              surface: AppTheme.surfaceDark,
              onSurface: AppTheme.onPrimaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _endDate != null
          ? TimeOfDay(hour: _endDate!.hour, minute: _endDate!.minute)
          : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      helpText: 'Escolha a hora de encerramento',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryDark,
              surface: AppTheme.surfaceDark,
              onSurface: AppTheme.onPrimaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

    setState(() {
      _endDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  String _formatEndAt(DateTime? d) {
    if (d == null) return 'Sem data definida';
    String two(int v) => v < 10 ? '0$v' : '$v';
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
    }

  Future<void> _submit() async {
    if (!_isAdmin) {
      _snack('Acesso negado. Apenas administradores podem criar missões.', isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _snack('Preencha os campos obrigatórios.');
      return;
    }

    if (_clues.isEmpty || _clues.any((c) => !c.isValid())) {
      _snack('Verifique as pistas. Todas precisam de texto e resposta do QR.', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token ausente. Faça login novamente.');
      }

      // 1) Cria missão
      final missionRes = await http.post(
        Uri.parse('$_baseUrl/missions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'reward_points': int.tryParse(_pointsCtrl.text.trim()) ?? 0,
          if (_endDate != null) 'end_at': _endDate!.toUtc().toIso8601String(),
          // Enviado mas backend pode ignorar se não houver coluna:
          'difficulty': _difficulty,
        }),
      );
      if (missionRes.statusCode >= 400) {
        final data = _safeDecode(missionRes.body);
        throw Exception(data['error'] ?? 'Falha ao criar missão (${missionRes.statusCode})');
      }
      final mission = _safeDecode(missionRes.body);
      final missionId = mission['mission']?['id']?.toString() ?? mission['id']?.toString();
      if (missionId == null || missionId.isEmpty) {
        throw Exception('Resposta inválida do servidor ao criar missão.');
      }

      // 2) Cria pistas
      for (int i = 0; i < _clues.length; i++) {
        final c = _clues[i];
        final meta = {
          'difficulty': _difficulty, // guardamos a dificuldade aqui por compatibilidade
          if (c.hints.isNotEmpty) 'hints': c.hints,
          if (c.hint.isNotEmpty) 'hint': c.hint, // dica principal opcional
        };

        final clueRes = await http.post(
          Uri.parse('$_baseUrl/missions/$missionId/clues'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'clue_index': i,
            'type': c.type,
            'content': c.contentCtrl.text.trim(),
            'answerPlain': c.answerCtrl.text.trim(), // backend fará hash SHA-256
            'answer_meta': meta,
          }),
        );
        if (clueRes.statusCode >= 400) {
          final data = _safeDecode(clueRes.body);
          throw Exception(data['error'] ?? 'Falha ao criar pista #$i');
        }
      }

      _snack('Missão criada com sucesso!');
      if (!mounted) return;
      Navigator.pop(context, {'created': true, 'id': missionId});
    } catch (e) {
      _snack('Erro: $e', isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Map<String, dynamic> _safeDecode(String body) {
    if (body.isEmpty) return {};
    try {
      final d = jsonDecode(body);
      return (d is Map) ? d.cast<String, dynamic>() : {};
    } catch (_) {
      return {};
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.errorDark : AppTheme.primaryDark,
      ),
    );
  }

  void _addClue() {
    setState(() {
      _clues.add(_ClueModel());
    });
  }

  void _removeClue(int idx) {
    setState(() {
      _clues.removeAt(idx).dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authError != null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          title: const Text('Criar missão'),
        ),
        body: Center(child: Text(_authError!)),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          title: const Text('Criar missão'),
        ),
        body: const Center(
          child: Text('Apenas administradores podem criar missões.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Criar missão',
          style: TextStyle(
            color: AppTheme.textHighEmphasis,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(5.w),
            children: [
              _section(
                title: 'Informações da missão',
                child: Column(
                  children: [
                    _input(
                      label: 'Título *',
                      controller: _titleCtrl,
                      validator: (v) =>
                          (v == null || v.trim().length < 3) ? 'Informe um título válido' : null,
                    ),
                    SizedBox(height: 1.6.h),
                    _input(
                      label: 'Descrição',
                      controller: _descCtrl,
                      maxLines: 4,
                    ),
                    SizedBox(height: 1.6.h),
                    Row(
                      children: [
                        Expanded(
                          child: _input(
                            label: 'Pontos (recompensa) *',
                            controller: _pointsCtrl,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                (int.tryParse((v ?? '').trim()) == null) ? 'Informe um número' : null,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _difficultyPicker(),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.6.h),
                    _endAtPicker(),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              _section(
                title: 'Pistas (clues)',
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addClue,
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _clues.length; i++) _clueCard(i),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar missão'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    foregroundColor: AppTheme.onPrimaryDark,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 2.h),
              Text(
                'Campos obrigatórios: Título, Pontos, pelo menos 1 Pista (com Texto e QR).',
                style: TextStyle(color: AppTheme.textMediumEmphasis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({required String title, Widget? trailing, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textHighEmphasis,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5.sp,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 1.6.h),
          child,
        ],
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: AppTheme.onPrimaryDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textMediumEmphasis),
        filled: true,
        fillColor: AppTheme.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryDark),
        ),
      ),
    );
  }

  Widget _difficultyPicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _difficulty,
          items: const [
            DropdownMenuItem(value: 'easy', child: Text('Fácil')),
            DropdownMenuItem(value: 'medium', child: Text('Médio')),
            DropdownMenuItem(value: 'hard', child: Text('Difícil')),
          ],
          onChanged: (v) => setState(() => _difficulty = v ?? 'easy'),
          dropdownColor: AppTheme.surfaceDark,
          style: TextStyle(color: AppTheme.onPrimaryDark),
          iconEnabledColor: AppTheme.textMediumEmphasis,
        ),
      ),
    );
  }

  Widget _endAtPicker() {
    return InkWell(
      onTap: _pickEndDateTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerDark),
        ),
        child: Row(
          children: [
            const Icon(Icons.event, size: 20),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                _endDate == null ? 'Data de encerramento (opcional)' : _formatEndAt(_endDate),
                style: TextStyle(
                  color: _endDate == null ? AppTheme.textMediumEmphasis : AppTheme.onPrimaryDark,
                ),
              ),
            ),
            const Icon(Icons.edit_calendar, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _clueCard(int index) {
    final clue = _clues[index];
    return Container(
      margin: EdgeInsets.only(bottom: 1.6.h),
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Pista ${index + 1}',
                style: TextStyle(
                  color: AppTheme.textHighEmphasis,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_clues.length > 1)
                IconButton(
                  onPressed: () => _removeClue(index),
                  icon: const Icon(Icons.delete_forever),
                  color: AppTheme.errorDark,
                ),
            ],
          ),
          SizedBox(height: 1.h),
          _clueTypePicker(clue),
          SizedBox(height: 1.2.h),
          _input(
            label: 'Texto da pista *',
            controller: clue.contentCtrl,
            maxLines: 3,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe o texto da pista' : null,
          ),
          SizedBox(height: 1.2.h),
          _input(
            label: 'Texto lido do QR desta pista *',
            controller: clue.answerCtrl,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe a resposta do QR' : null,
          ),
          SizedBox(height: 1.2.h),
          _hintEditor(clue),
        ],
      ),
    );
  }

  Widget _clueTypePicker(_ClueModel clue) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: clue.type,
          items: const [
            DropdownMenuItem(value: 'text', child: Text('Texto')),
            DropdownMenuItem(value: 'qr', child: Text('QR')),
          ],
          onChanged: (v) => setState(() => clue.type = v ?? 'text'),
          dropdownColor: AppTheme.backgroundDark,
          style: TextStyle(color: AppTheme.onPrimaryDark),
          iconEnabledColor: AppTheme.textMediumEmphasis,
        ),
      ),
    );
  }

  Widget _hintEditor(_ClueModel clue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dicas (opcional)', style: TextStyle(color: AppTheme.textMediumEmphasis)),
        SizedBox(height: 0.8.h),
        _input(
          label: 'Dica principal (aparece primeiro)',
          controller: clue.hintCtrl,
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 1.w,
          runSpacing: 1.w,
          children: [
            for (int i = 0; i < clue.hints.length; i++)
              Chip(
                label: Text(clue.hints[i]),
                onDeleted: () => setState(() => clue.hints.removeAt(i)),
                backgroundColor: AppTheme.cardDark,
                deleteIconColor: AppTheme.errorDark,
                labelStyle: TextStyle(color: AppTheme.onPrimaryDark),
              ),
          ],
        ),
        SizedBox(height: 0.8.h),
        Row(
          children: [
            Expanded(
              child: _input(
                label: 'Adicionar dica (+)',
                controller: clue.newHintCtrl,
              ),
            ),
            SizedBox(width: 2.w),
            ElevatedButton.icon(
              onPressed: () {
                final t = clue.newHintCtrl.text.trim();
                if (t.isEmpty) return;
                setState(() {
                  clue.hints.add(t);
                  clue.newHintCtrl.clear();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: AppTheme.onPrimaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ======== Modelo simples para o formulário de pistas ========

class _ClueModel {
  String type = 'text'; // 'text' | 'qr'
  final TextEditingController contentCtrl = TextEditingController();
  final TextEditingController answerCtrl = TextEditingController(); // texto que o QR deve conter
  final TextEditingController hintCtrl = TextEditingController();   // dica principal
  final TextEditingController newHintCtrl = TextEditingController();// input para adicionar dicas
  final List<String> hints = [];

  String get hint => hintCtrl.text.trim();

  bool isValid() {
    return contentCtrl.text.trim().isNotEmpty && answerCtrl.text.trim().isNotEmpty;
  }

  void dispose() {
    contentCtrl.dispose();
    answerCtrl.dispose();
    hintCtrl.dispose();
    newHintCtrl.dispose();
  }
}
