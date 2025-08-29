import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_background_widget.dart';
import './widgets/confetti_animation_widget.dart';
import './widgets/game_logo_widget.dart';
import './widgets/nickname_input_widget.dart';
import './widgets/start_adventure_button_widget.dart';

class NicknameSetupScreen extends StatefulWidget {
  const NicknameSetupScreen({super.key});

  @override
  State<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isNicknameValid = false;
  bool _isLoading = false;
  bool _showConfetti = false;
  String? _errorMessage;

  // Mock existing nicknames for validation
  final List<String> _existingNicknames = [
    'admin',
    'test',
    'user',
    'player1',
    'hunter',
    'explorer',
    'adventurer',
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_validateNickname);
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_validateNickname);
    _nicknameController.dispose();
    super.dispose();
  }

  void _validateNickname() {
    final nickname = _nicknameController.text.trim();
    setState(() {
      _errorMessage = null;

      if (nickname.isEmpty) {
        _isNicknameValid = false;
      } else if (nickname.length < 3) {
        _isNicknameValid = false;
      } else if (nickname.length > 20) {
        _isNicknameValid = false;
        _errorMessage = 'Nome muito longo (máximo 20 caracteres)';
      } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(nickname)) {
        _isNicknameValid = false;
        _errorMessage = 'Use apenas letras e números';
      } else if (_existingNicknames.contains(nickname.toLowerCase())) {
        _isNicknameValid = false;
        _errorMessage = 'Este nome já está em uso';
      } else {
        _isNicknameValid = true;
      }
    });
  }

  String _generateUUID() {
    final random = math.Random();
    const chars = '0123456789abcdef';
    final uuid = List.generate(32, (index) {
      if (index == 8 || index == 12 || index == 16 || index == 20) {
        return '-';
      }
      return chars[random.nextInt(chars.length)];
    }).join();

    return '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-${uuid.substring(20)}';
  }

  Future<void> _startAdventure() async {
    if (!_isNicknameValid || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Generate unique UUID
      final uuid = _generateUUID();
      final nickname = _nicknameController.text.trim();

      // Store user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nickname', nickname);
      await prefs.setString('user_uuid', uuid);
      await prefs.setBool('is_first_time', false);
      await prefs.setInt('user_points', 0);
      await prefs.setString('active_mission_id', '');
      await prefs.setInt('active_mission_clue_index', 0);

      // Show success animation
      setState(() {
        _isLoading = false;
        _showConfetti = true;
      });

      // Haptic feedback for success
      HapticFeedback.heavyImpact();

      // Wait for confetti animation to complete
      await Future.delayed(const Duration(milliseconds: 2000));
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao criar perfil. Tente novamente.';
      });
      HapticFeedback.lightImpact();
    }
  }

  void _onConfettiComplete() {
    // Navigate to mission selection screen
    Navigator.pushReplacementNamed(context, '/mission-selection-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated background
          const AnimatedBackgroundWidget(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 94.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 8.h),

                    // Game logo
                    const GameLogoWidget(),

                    SizedBox(height: 6.h),

                    // Title
                    Text(
                      'Escolha Seu Nome de\nCaçador de Tesouros',
                      textAlign: TextAlign.center,
                      style:
                          AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Subtitle
                    Text(
                      'Crie uma identidade única para sua aventura',
                      textAlign: TextAlign.center,
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMediumEmphasis,
                        fontSize: 14.sp,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // Nickname input
                    NicknameInputWidget(
                      controller: _nicknameController,
                      onChanged: (_) => _validateNickname(),
                      isValid: _isNicknameValid,
                      errorMessage: _errorMessage,
                    ),

                    SizedBox(height: 8.h),

                    // Start adventure button
                    StartAdventureButtonWidget(
                      isEnabled: _isNicknameValid,
                      isLoading: _isLoading,
                      onPressed: _startAdventure,
                    ),

                    SizedBox(height: 4.h),

                    // Info text
                    Text(
                      'Seu nome será usado para identificar você\ndurante toda a caça ao tesouro',
                      textAlign: TextAlign.center,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasis,
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ),

          // Confetti animation overlay
          ConfettiAnimationWidget(
            isVisible: _showConfetti,
            onAnimationComplete: _onConfettiComplete,
          ),
        ],
      ),
    );
  }
}
