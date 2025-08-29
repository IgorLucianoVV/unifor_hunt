import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _glowAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _glowAnimation;

  bool _isInitialized = false;
  String _loadingText = 'Inicializando...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Glow animation controller
    _glowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Glow animation
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoAnimationController.forward();
    _glowAnimationController.repeat(reverse: true);
  }

  Future<void> _startInitialization() async {
    try {
      // Simulate initialization steps with realistic timing
      await _performInitializationSteps();

      // Wait minimum splash duration
      await Future.delayed(const Duration(milliseconds: 3000));

      if (mounted) {
        await _navigateToNextScreen();
      }
    } catch (e) {
      // Handle initialization errors gracefully
      if (mounted) {
        setState(() {
          _loadingText = 'Modo offline ativado';
        });
        await Future.delayed(const Duration(milliseconds: 1000));
        await _navigateToNextScreen();
      }
    }
  }

  Future<void> _performInitializationSteps() async {
    // Step 1: Check authentication status
    setState(() {
      _loadingText = 'Verificando autenticação...';
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 2: Load user preferences
    setState(() {
      _loadingText = 'Carregando preferências...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 3: Fetch mission data with timeout
    setState(() {
      _loadingText = 'Buscando missões...';
    });

    try {
      await Future.any([
        _fetchMissionData(),
        Future.delayed(const Duration(seconds: 5)),
      ]);
    } catch (e) {
      // Switch to mock data mode after timeout
      setState(() {
        _loadingText = 'Carregando dados locais...';
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Step 4: Prepare cached data
    setState(() {
      _loadingText = 'Preparando cache...';
    });
    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      _isInitialized = true;
      _loadingText = 'Pronto!';
    });
  }

  Future<void> _fetchMissionData() async {
    // Mock API call - in real implementation, this would be actual HTTP request
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulate potential network error
    if (DateTime.now().millisecond % 3 == 0) {
      throw Exception('Network timeout');
    }
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final nickname = prefs.getString('user_nickname');
    final hasActiveMission = prefs.getBool('has_active_mission') ?? false;

    // Fade out animation before navigation
    await _logoAnimationController.reverse();

    if (!mounted) return;

    // Navigation logic based on user state
    if (nickname == null || nickname.isEmpty) {
      // New user - go to nickname setup
      Navigator.pushReplacementNamed(context, '/nickname-setup-screen');
    } else if (hasActiveMission) {
      // User with active mission - go to mission detail
      Navigator.pushReplacementNamed(context, '/mission-detail-screen');
    } else {
      // Returning user without active mission - go to mission selection
      Navigator.pushReplacementNamed(context, '/mission-selection-screen');
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildAnimatedLogo(),
              SizedBox(height: 8.h),
              _buildLoadingSection(),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.backgroundDark,
          AppTheme.surfaceDark,
          AppTheme.backgroundDark,
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoAnimationController,
        _glowAnimationController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoOpacityAnimation.value,
            child: Container(
              width: 35.w,
              height: 35.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryDark,
                    AppTheme.primaryVariantDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGlow
                        .withValues(alpha: _glowAnimation.value * 0.6),
                    blurRadius: 30.0 * _glowAnimation.value,
                    spreadRadius: 5.0 * _glowAnimation.value,
                  ),
                  BoxShadow(
                    color: AppTheme.primaryDark
                        .withValues(alpha: _glowAnimation.value * 0.4),
                    blurRadius: 50.0 * _glowAnimation.value,
                    spreadRadius: 10.0 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'star',
                      color: AppTheme.onPrimaryDark,
                      size: 12.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'UNIFOR',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.onPrimaryDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      'HUNT',
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.onPrimaryDark,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        _buildLoadingIndicator(),
        SizedBox(height: 3.h),
        _buildLoadingText(),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 60.w,
      height: 0.8.h,
      child: AnimatedBuilder(
        animation: _glowAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryDark.withValues(alpha: 0.3),
                  AppTheme.primaryDark,
                  AppTheme.primaryVariantDark,
                  AppTheme.primaryDark.withValues(alpha: 0.3),
                ],
                stops: [
                  0.0,
                  _glowAnimation.value * 0.4,
                  _glowAnimation.value * 0.6,
                  1.0,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDark
                      .withValues(alpha: _glowAnimation.value * 0.5),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _loadingText,
        key: ValueKey(_loadingText),
        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.textMediumEmphasis,
          fontSize: 12.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
