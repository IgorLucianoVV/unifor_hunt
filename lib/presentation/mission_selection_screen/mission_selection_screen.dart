import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../_guards/profile_gate.dart'; // opcional, se usar
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart'; // <-- IMPORTANTE

import './widgets/empty_state_widget.dart';
import './widgets/mission_card_widget.dart';
import './widgets/offline_indicator_widget.dart';
import './widgets/user_header_widget.dart';

class MissionSelectionScreen extends StatefulWidget {
  const MissionSelectionScreen({Key? key}) : super(key: key);

  @override
  State<MissionSelectionScreen> createState() => _MissionSelectionScreenState();
}

class _MissionSelectionScreenState extends State<MissionSelectionScreen>
    with TickerProviderStateMixin {
  final String _baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://127.0.0.1:3000',
  );

  String _nickname = 'Jogador';
  int _totalPoints = 0;
  List<Map<String, dynamic>> _missions = [];
  bool _isLoading = true;
  bool _isOffline = false;
  DateTime? _lastUpdated;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // >>> NEW: admin flag
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadUserData();
    await _checkConnectivity();
    await Future.wait([
      _loadMissions(),
      _loadAdmin(), // >>> NEW: checa se é admin
    ]);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _nickname = prefs.getString('user_nickname') ?? 'Jogador';
        _totalPoints = prefs.getInt('total_points') ?? 0;
      });
    } catch (_) {
      setState(() {
        _nickname = 'Jogador';
        _totalPoints = 0;
      });
    }
  }

  // >>> NEW: carrega /auth/me para saber se é admin
  Future<void> _loadAdmin() async {
    try {
      final me = await AuthService().getMe();
      final user = (me['user'] as Map?) ?? {};
      setState(() {
        _isAdmin = user['is_admin'] == true;
      });
    } catch (_) {
      // se não estiver logado ou a chamada falhar, mantém _isAdmin = false
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        _isOffline = connectivityResult == ConnectivityResult.none;
      });
    } catch (_) {
      setState(() {
        _isOffline = true;
      });
    }
  }

  Future<void> _loadMissions() async {
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$_baseUrl/missions');
      final res = await http.get(uri);
      if (res.statusCode >= 400) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final data = jsonDecode(res.body.isNotEmpty ? res.body : '{}') as Map;
      final list = (data['missions'] as List? ?? [])
          .map<Map<String, dynamic>>((e) => _mapApiMissionToUi(e as Map))
          .toList();

      setState(() {
        _missions = list;
        _lastUpdated = DateTime.now();
        _isLoading = false;
        _isOffline = false;
      });

      _calculateTotalPointsFromCompleted(list);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isOffline = true;
        _lastUpdated = DateTime.now();
      });
    }
  }

  Map<String, dynamic> _mapApiMissionToUi(Map api) {
    final id = api['id']?.toString() ?? '';
    final title = (api['title'] ?? '').toString();
    final description = (api['description'] ?? '').toString();
    final points = (api['reward_points'] ?? 0) as int;
    final endAtIso = api['end_at']?.toString();

    final isExpired = _isExpired(endAtIso);
    final status = isExpired ? 'locked' : 'active';

    final difficulty = points >= 300
        ? 'hard'
        : points >= 200
            ? 'medium'
            : 'easy';

    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'points': points,
      'status': status,
      'completedClues': 0,
      'totalClues': 0,
      'unlockRequirement': null,
      'end_at': endAtIso,
    };
  }

  bool _isExpired(String? iso) {
    if (iso == null || iso.isEmpty) return false;
    final d = DateTime.tryParse(iso);
    if (d == null) return false;
    return DateTime.now().isAfter(d);
  }

  void _calculateTotalPointsFromCompleted(List<Map<String, dynamic>> list) {
    final total = list.fold<int>(0, (acc, m) {
      if (m['status'] == 'completed') return acc + (m['points'] as int? ?? 0);
      return acc;
    });
    _saveTotalPoints(total);
    setState(() => _totalPoints = total);
  }

  Future<void> _saveTotalPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('total_points', points);
    } catch (_) {}
  }

  Future<void> _refreshMissions() async {
    HapticFeedback.lightImpact();
    await _checkConnectivity();
    await _loadMissions();
    await _loadAdmin(); // >>> NEW: atualiza admin também no refresh
  }

  void _onMissionTap(Map<String, dynamic> mission) {
    final String status = (mission['status'] as String?) ?? 'locked';
    if (status == 'locked') return;

    HapticFeedback.selectionClick();

    Navigator.pushNamed(
      context,
      AppRoutes.missionDetail,
      arguments: {'missionId': mission['id'] as String},
    );
  }

  Future<void> _goCreateMission() async {
    final res = await Navigator.pushNamed(context, AppRoutes.adminCreateMission);
    // se voltar com sucesso, recarrega a lista
    if (res is Map && res['created'] == true) {
      await _refreshMissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,

      // >>> NEW: FAB só para admins
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _isOffline ? null : _goCreateMission,
              icon: const Icon(Icons.add),
              label: const Text('Criar missão'),
              backgroundColor:
                  _isOffline ? AppTheme.dividerDark : AppTheme.primaryDark,
              foregroundColor: AppTheme.onPrimaryDark,
            )
          : null,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.backgroundDark,
              AppTheme.surfaceDark.withValues(alpha: 0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            UserHeaderWidget(
              nickname: _nickname,
              totalPoints: _totalPoints,
              onUserSwitch: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.nicknameSetup,
              ),
            ),
            if (_isOffline) OfflineIndicatorWidget(lastUpdated: _lastUpdated),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _missions.isEmpty
                      ? EmptyStateWidget(onRefresh: _refreshMissions)
                      : _buildMissionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryDark
                          .withValues(alpha: _glowAnimation.value * 0.5),
                      AppTheme.primaryVariantDark
                          .withValues(alpha: _glowAnimation.value * 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.w),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark
                          .withValues(alpha: _glowAnimation.value * 0.3),
                      blurRadius: 20.0,
                      spreadRadius: 5.0,
                      offset: Offset.zero,
                    ),
                  ],
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryDark),
                    strokeWidth: 3.0,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 4.h),
          Text(
            'Carregando Missões...',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textMediumEmphasis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsList() {
    return RefreshIndicator(
      onRefresh: _refreshMissions,
      backgroundColor: AppTheme.surfaceDark,
      color: AppTheme.primaryDark,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 2.h, bottom: 10.h), // espaço p/ FAB
        itemCount: _missions.length,
        itemBuilder: (context, index) {
          final mission = _missions[index];
          return MissionCardWidget(
            mission: mission,
            onTap: () => _onMissionTap(mission),
          );
        },
      ),
    );
  }
}
