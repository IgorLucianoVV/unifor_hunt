import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

import './widgets/action_buttons_widget.dart';
import './widgets/help_bottom_sheet_widget.dart';
import './widgets/mission_header_widget.dart';
import './widgets/mission_progress_widget.dart';
import './widgets/typewriter_clue_widget.dart';

class MissionDetailScreen extends StatefulWidget {
  const MissionDetailScreen({Key? key}) : super(key: key);

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen>
    with TickerProviderStateMixin {
  final String _baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://127.0.0.1:3000',
  );

  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  String? _missionId; // <-- agora STRING
  Map<String, dynamic>? _mission; // {id,title,description,reward_points,end_at,clues:[...]}
  int _currentClueIndex = 0;
  List<bool> _completedClues = [];

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundAnimationController, curve: Curves.easeInOut),
    );
  }

  // >>> LÊ OS ARGUMENTOS AQUI (garante que já existem mesmo com wrappers)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_missionId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      debugPrint('MissionDetail args: $args');
      if (args is Map && args['missionId'] != null) {
        _missionId = args['missionId'].toString();
        _loadMissionData();
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = 'ID da missão não informado.';
        });
      }
    }
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadMissionData() async {
    if (!mounted || _missionId == null) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // 1) detalhes da missão
      final detailUri = Uri.parse('$_baseUrl/missions/${_missionId!}');
      debugPrint('GET $detailUri');
      final detailRes = await http.get(detailUri);
      if (detailRes.statusCode >= 400) {
        throw Exception('HTTP ${detailRes.statusCode} ao carregar missão');
      }
      final detail = jsonDecode(detailRes.body.isNotEmpty ? detailRes.body : '{}') as Map;

      // 2) progresso (se autenticado)
      int currentIdx = 0;
      try {
        final token = await AuthService().getToken();
        if (token != null && token.isNotEmpty) {
          final progUri = Uri.parse('$_baseUrl/missions/${_missionId!}/progress');
          debugPrint('GET $progUri (auth)');
          final progRes = await http.get(
            progUri,
            headers: {'Authorization': 'Bearer $token'},
          );
          if (progRes.statusCode == 200) {
            final prog = jsonDecode(progRes.body) as Map;
            currentIdx = (prog['current_clue_idx'] as int?) ?? 0;
          } else if (progRes.statusCode != 404) {
            debugPrint('progress HTTP ${progRes.statusCode}: ${progRes.body}');
          }
        }
      } catch (e) {
        debugPrint('progress error: $e');
      }

      final clues = (detail['clues'] as List? ?? [])
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final totalClues = clues.length;
      final completed = List<bool>.generate(totalClues, (i) => i < currentIdx);

      setState(() {
        _mission = {
          'id': detail['id'],
          'title': detail['title'],
          'description': detail['description'],
          'reward_points': detail['reward_points'] ?? 0,
          'end_at': detail['end_at'],
          'clues': clues,
        };
        _currentClueIndex =
            currentIdx.clamp(0, (totalClues == 0 ? 0 : totalClues - 1));
        _completedClues = completed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Erro ao carregar missão. $e';
      });
    }
  }

  Future<void> _handleScanQRCode() async {
    if (_mission == null) return;

    HapticFeedback.mediumImpact();
    final result = await Navigator.pushNamed(context, AppRoutes.qrCodeScanner);
    if (!mounted) return;

    if (result is Map<String, dynamic>) {
      final scannedCode = result['qrCode'] as String?;
      final successFlag = result['success'] as bool? ?? false;

      if (scannedCode == null || scannedCode.isEmpty || !successFlag) {
        _showErrorToast('Leitura cancelada ou inválida.');
        return;
      }

      await _submitAttempt(scannedCode);
    }
  }

  Future<void> _submitAttempt(String payload) async {
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      _showErrorToast('Você precisa estar logado.');
      return;
    }

    try {
      final uri = Uri.parse('$_baseUrl/missions/${_mission!['id']}/attempt');
      debugPrint('POST $uri payload="$payload"');
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'payload': payload}),
      );

      if (res.statusCode >= 400) {
        final data = _safeDecode(res.body);
        throw Exception(data['error'] ?? 'Falha ao validar QR');
      }

      final data = jsonDecode(res.body) as Map;
      final ok = data['ok'] == true;
      final nextIdx =
          (data['current_clue_idx'] as int?) ?? _currentClueIndex;
      final completed = data['completed'] == true;

      if (!ok) {
        _showErrorToast(
            'Código QR incorreto. Tente novamente no local correto.');
        return;
      }

      HapticFeedback.heavyImpact();

      setState(() {
        for (int i = 0; i < _completedClues.length; i++) {
          _completedClues[i] = i < nextIdx;
        }
        _currentClueIndex = nextIdx.clamp(
            0, _completedClues.isEmpty ? 0 : _completedClues.length - 1);
      });

      if (completed) {
        if (!mounted) return;
        Navigator.pushNamed(context, AppRoutes.successCelebration).then((_) {
          Navigator.pushReplacementNamed(context, AppRoutes.missionSelection);
        });
      } else {
        _showSuccessToast('Pista encontrada! Continue para a próxima.');
      }
    } catch (e) {
      _showErrorToast('Erro: $e');
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

  void _handleNeedHelp() {
    if (_mission == null) return;

    final clues = (_mission!['clues'] as List);
    final current = clues.isNotEmpty && _currentClueIndex < clues.length
        ? Map<String, dynamic>.from(clues[_currentClueIndex] as Map)
        : null;

    final hint = (current?['answer_meta'] is Map)
        ? (current?['answer_meta']['hint']?.toString())
        : null;

    HelpBottomSheetWidget.show(
      context,
      missionTitle: (_mission!['title'] as String?) ?? 'Missão',
      helpTips: [
        if (hint != null && hint.isNotEmpty) 'Dica desta pista: $hint',
        'Leia a pista com atenção e visualize o local descrito.',
        'Explore os arredores; o QR fica visível e acessível.',
        'Se travar, peça ajuda a um colega ou funcionário.',
      ],
      contactInfo:
          "Suporte: suporte@uniforhunt.edu.br • (85) 3456-7890 • Seg–Sex, 8h–18h",
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.secondaryDark,
      textColor: AppTheme.onSecondaryDark,
      fontSize: 14.sp,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.errorDark,
      textColor: AppTheme.onErrorDark,
      fontSize: 14.sp,
    );
  }

  String _formatEndAt(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.backgroundDark,
                  AppTheme.backgroundDark.withValues(alpha: 0.9),
                  AppTheme.primaryDark
                      .withValues(alpha: 0.1 * _backgroundAnimation.value),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: _isLoading
                  ? _buildLoading()
                  : _hasError || _mission == null
                      ? _buildError()
                      : _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                AppTheme.glowEffect(
                  color: AppTheme.primaryDark,
                  blurRadius: 20.0,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryDark),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Carregando missão...',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.errorDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.errorDark.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'error_outline',
                color: AppTheme.errorDark,
                size: 48,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Ops! Algo deu errado',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textHighEmphasis,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Erro ao carregar missão',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.textMediumEmphasis,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadMissionData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: AppTheme.onPrimaryDark,
                  padding: EdgeInsets.symmetric(vertical: 1.6.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final clues = (_mission!['clues'] as List);
    final currentClue = _currentClueIndex < clues.length && clues.isNotEmpty
        ? Map<String, dynamic>.from(clues[_currentClueIndex] as Map)
        : (clues.isNotEmpty ? Map<String, dynamic>.from(clues.last as Map) : <String, dynamic>{});

    final endAtText = _formatEndAt(_mission!['end_at']?.toString());

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.dividerDark.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.textHighEmphasis,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Detalhes da Missão',
                  style: GoogleFonts.orbitron(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textHighEmphasis,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 2.h),
            child: Column(
              children: [
                MissionHeaderWidget(
                  missionTitle: (_mission!['title'] as String?) ?? 'Missão',
                  currentClue: (_currentClueIndex + 1)
                      .clamp(1, (clues.isEmpty ? 1 : clues.length)),
                  totalClues: clues.length,
                  points: (_mission!['reward_points'] as int?) ?? 0,
                ),
                if (endAtText.isNotEmpty) ...[
                  SizedBox(height: 0.6.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event, size: 16),
                        SizedBox(width: 1.w),
                        Text(
                          'Encerra em $endAtText',
                          style: GoogleFonts.inter(
                            color: AppTheme.textMediumEmphasis,
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 3.h),

                TypewriterClueWidget(
                  clueText:
                      (currentClue['content'] ?? 'Sem conteúdo').toString(),
                  hintText: (currentClue['answer_meta'] is Map)
                      ? (currentClue['answer_meta']['hint']?.toString())
                      : null,
                ),

                SizedBox(height: 3.h),

                MissionProgressWidget(
                  currentClue: (_currentClueIndex + 1)
                      .clamp(1, (clues.isEmpty ? 1 : clues.length)),
                  totalClues: clues.length,
                  completedClues: _completedClues,
                ),

                SizedBox(height: 4.h),

                ActionButtonsWidget(
                  onScanQRCode: _handleScanQRCode,
                  onNeedHelp: _handleNeedHelp,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
