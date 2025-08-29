import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProtectedRoute extends StatefulWidget {
  final Widget child;
  const ProtectedRoute({super.key, required this.child});

  @override
  State<ProtectedRoute> createState() => _ProtectedRouteState();
}

class _ProtectedRouteState extends State<ProtectedRoute> {
  final _auth = AuthService();
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final token = await _auth.getToken();
    if (!mounted) return;
    if (token == null) {
      // sem token -> login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      });
    } else {
      setState(() => _allowed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_allowed) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.child;
  }
}
