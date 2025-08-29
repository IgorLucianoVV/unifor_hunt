import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/confetti_animation_widget.dart';
import './widgets/points_counter_widget.dart';
import './widgets/progress_summary_widget.dart';
import './widgets/success_icon_widget.dart';

class SuccessCelebrationScreen extends StatefulWidget {
  const SuccessCelebrationScreen({super.key});

  @override
  State<SuccessCelebrationScreen> createState() =>
      _SuccessCelebrationScreenState();
}

class _SuccessCelebrationScreenState extends State<SuccessCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  late AnimationController _titleController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;

  Timer? _autoDismissTimer;
  bool _isAnimating = false;
  bool _showButtons = false;

  // Mock celebration data
  final Map<String, dynamic> _celebrationData = {
    "pointsEarned": 150,
    "completedClues": 3,
    "totalClues": 5,
    "isMissionComplete": false,
    "missionTitle": "Caça ao Tesouro do Campus",
    "nextClueAvailable": true,
    "achievementUnlocked": "Explorador Iniciante",
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCelebrationSequence();
    _setupAutoDismiss();
    _updateUserProgress();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutBack,
    ));

    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeIn,
    ));
  }

  void _startCelebrationSequence() {
    // Start background animation immediately
    _backgroundController.repeat(reverse: true);

    // Trigger haptic feedback
    HapticFeedback.heavyImpact();

    // Start main animation sequence
    setState(() {
      _isAnimating = true;
    });

    // Show title after brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _titleController.forward();
    });

    // Show buttons after all animations
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _showButtons = true;
        });
      }
    });
  }

  void _setupAutoDismiss() {
    _autoDismissTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _updateUserProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update local progress
      final currentPoints = prefs.getInt('user_points') ?? 0;
      final newPoints =
          currentPoints + (_celebrationData['pointsEarned'] as int);
      await prefs.setInt('user_points', newPoints);

      // Update mission progress
      final missionId = prefs.getString('current_mission_id') ?? 'mission_1';
      await prefs.setInt('${missionId}_completed_clues',
          _celebrationData['completedClues'] as int);

      // If mission complete, unlock next mission
      if (_celebrationData['isMissionComplete'] as bool) {
        final nextMissionId = _getNextMissionId(missionId);
        await prefs.setString('unlocked_missions', nextMissionId);
      }

      // Sync with backend (mock implementation)
      _syncWithBackend();
    } catch (e) {
      debugPrint('Error updating user progress: $e');
    }
  }

  String _getNextMissionId(String currentMissionId) {
    final missionIds = [
      'mission_1',
      'mission_2',
      'mission_3',
      'mission_4',
      'mission_5'
    ];
    final currentIndex = missionIds.indexOf(currentMissionId);
    return currentIndex < missionIds.length - 1
        ? missionIds[currentIndex + 1]
        : currentMissionId;
  }

  Future<void> _syncWithBackend() async {
    // Mock backend sync - in real app, this would be an API call
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Progress synced with backend successfully');
  }

  void _navigateToNextScreen() {
    _autoDismissTimer?.cancel();

    if (_celebrationData['isMissionComplete'] as bool) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/mission-selection-screen',
        (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/mission-detail-screen',
        (route) => false,
      );
    }
  }

  void _handleShareAchievement() {
    final missionTitle = _celebrationData['missionTitle'] as String;
    final pointsEarned = _celebrationData['pointsEarned'] as int;
    final completedClues = _celebrationData['completedClues'] as int;

    final shareText = '''
🎉 Acabei de conquistar +$pointsEarned pontos no Unifor Hunt!

📍 Missão: $missionTitle
🔍 Pistas descobertas: $completedClues
🏆 Conquista desbloqueada: ${_celebrationData['achievementUnlocked']}

Venha participar desta aventura incrível! 🚀

#UniforHunt #CacaAoTesouro #Campus
    '''
        .trim();

    // In a real app, this would open the native share sheet
    // For now, we'll show a toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Conquista copiada para compartilhar!',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _titleController.dispose();
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToNextScreen();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: GestureDetector(
          onTap: () => _navigateToNextScreen(),
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 0) {
              _navigateToNextScreen();
            }
          },
          child: Stack(
            children: [
              // Animated gradient background
              AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.backgroundDark,
                          AppTheme.lightTheme.primaryColor.withValues(
                            alpha: 0.1 + (_backgroundAnimation.value * 0.1),
                          ),
                          AppTheme.accentGlow.withValues(
                            alpha: 0.05 + (_backgroundAnimation.value * 0.05),
                          ),
                          AppTheme.backgroundDark,
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  );
                },
              ),

              // Confetti animation
              ConfettiAnimationWidget(
                isActive: _isAnimating,
                onAnimationComplete: () {
                  // Additional haptic feedback when confetti completes
                  HapticFeedback.lightImpact();
                },
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Success icon
                          SuccessIconWidget(
                            isAnimating: _isAnimating,
                          ),

                          SizedBox(height: 4.h),

                          // Congratulations title
                          SlideTransition(
                            position: _titleSlideAnimation,
                            child: FadeTransition(
                              opacity: _titleFadeAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    'Parabéns!',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textHighEmphasis,
                                      shadows: [
                                        Shadow(
                                          color: AppTheme
                                              .lightTheme.primaryColor
                                              .withValues(alpha: 0.6),
                                          blurRadius: 12,
                                        ),
                                        Shadow(
                                          color: AppTheme.accentGlow
                                              .withValues(alpha: 0.4),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'QR Code validado com sucesso!',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textMediumEmphasis,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 4.h),

                          // Points counter
                          PointsCounterWidget(
                            targetPoints:
                                _celebrationData['pointsEarned'] as int,
                            isAnimating: _isAnimating,
                            onCountComplete: () {
                              // Additional celebration when points finish counting
                              HapticFeedback.mediumImpact();
                            },
                          ),

                          SizedBox(height: 4.h),

                          // Progress summary
                          ProgressSummaryWidget(
                            completedClues:
                                _celebrationData['completedClues'] as int,
                            totalClues: _celebrationData['totalClues'] as int,
                            isAnimating: _isAnimating,
                            isMissionComplete:
                                _celebrationData['isMissionComplete'] as bool,
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    ActionButtonsWidget(
                      isMissionComplete:
                          _celebrationData['isMissionComplete'] as bool,
                      onContinuePressed: _navigateToNextScreen,
                      onSharePressed: _handleShareAchievement,
                      isVisible: _showButtons,
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),

              // Dismiss hint
              if (_showButtons)
                Positioned(
                  top: 8.h,
                  right: 4.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.textDisabled,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'touch_app',
                          color: AppTheme.textMediumEmphasis,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Toque para continuar',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textMediumEmphasis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}