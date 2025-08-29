// lib/routes/app_routes.dart
import 'package:flutter/material.dart';

// Screens
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/nickname_setup_screen/nickname_setup_screen.dart';
import '../presentation/mission_selection_screen/mission_selection_screen.dart';
import '../presentation/mission_detail_screen/mission_detail_screen.dart';
import '../presentation/qr_code_scanner_screen/qr_code_scanner_screen.dart';
import '../presentation/success_celebration_screen/success_celebration_screen.dart';

// Guards
import '../presentation/_guards/protected_route.dart';

// Auth
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';

// Admin
import '../presentation/admin/admin_create_mission_screen.dart';

class AppRoutes {
  // Rotas nomeadas
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String login = '/login';
  static const String register = '/register';
  static const String nicknameSetup = '/nickname-setup-screen';
  static const String missionSelection = '/mission-selection-screen';
  static const String missionDetail = '/mission-detail-screen';
  static const String qrCodeScanner = '/qr-code-scanner-screen';
  static const String adminCreateMission = '/admin-create-mission';
  static const String successCelebration = '/success_celebration';

  // Mapa de rotas
  static Map<String, WidgetBuilder> routes = {
    // públicas
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),

    // protegidas (exigem token; o botão de acesso à rota de admin só deve aparecer se is_admin == true)
    nicknameSetup: (context)   => const ProtectedRoute(child: NicknameSetupScreen()),
    missionSelection: (context)=> const ProtectedRoute(child: MissionSelectionScreen()),
    missionDetail: (context)   => const ProtectedRoute(child: MissionDetailScreen()),
    qrCodeScanner: (context)   => const ProtectedRoute(child: QrCodeScannerScreen()),
    adminCreateMission: (context) => const ProtectedRoute(child: AdminCreateMissionScreen()),
  };
}
