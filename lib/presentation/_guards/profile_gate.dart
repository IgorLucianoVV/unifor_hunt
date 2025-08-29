import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileGate extends StatefulWidget {
  final Widget child;
  final bool requireNicknameMissing; // true = só entra se NÃO tiver nickname
  const ProfileGate({super.key, required this.child, this.requireNicknameMissing = false});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  final _auth = AuthService();
  bool _canEnter = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final me = await _auth.getMe(); // { user: {...} }

      final hasNickname = (me['nickname'] != null && (me['nickname'] as String).trim().isNotEmpty);

      if (widget.requireNicknameMissing) {
        if (hasNickname) {
          // já tem -> vá para missão
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/mission-selection-screen');
          });
        } else {
          setState(() => _canEnter = true);
        }
      } else {
        // para casos futuros
        setState(() => _canEnter = true);
      }
    } catch (_) {
      // falhou em obter perfil -> força login
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canEnter) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.child;
  }
}
