import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Informe o e-mail';
    final re = RegExp(r'^\S+@\S+\.\S+$');
    if (!re.hasMatch(s)) return 'E-mail inválido';
    return null;
  }

  String? _validatePass(String? v) {
    if ((v ?? '').isEmpty) return 'Informe a senha';
    if ((v ?? '').length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final res = await _auth.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      final user = res['user'] as Map?;
      final nickname = (user?['nickname'] ?? '').toString();

      if (!mounted) return;
      if (nickname.isEmpty) {
        Navigator.pushReplacementNamed(context, AppRoutes.nicknameSetup);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.missionSelection);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha no login: $e'),
          backgroundColor: AppTheme.errorDark,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goRegister() {
    Navigator.pushReplacementNamed(context, AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Entrar',
          style: TextStyle(
            color: AppTheme.textHighEmphasis,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(Icons.explore, size: 16.w, color: AppTheme.primaryDark),
                    SizedBox(height: 3.h),

                    TextFormField(
                      controller: _emailCtrl,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      onFieldSubmitted: (_) => _passFocus.requestFocus(),
                      style: TextStyle(color: AppTheme.onPrimaryDark),
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: TextStyle(color: AppTheme.textMediumEmphasis),
                        prefixIcon: Icon(Icons.email, color: AppTheme.textMediumEmphasis),
                        filled: true,
                        fillColor: AppTheme.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.dividerDark),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryDark),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    TextFormField(
                      controller: _passCtrl,
                      focusNode: _passFocus,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      validator: _validatePass,
                      onFieldSubmitted: (_) => _submit(),
                      style: TextStyle(color: AppTheme.onPrimaryDark),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: TextStyle(color: AppTheme.textMediumEmphasis),
                        prefixIcon: Icon(Icons.lock, color: AppTheme.textMediumEmphasis),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                            color: AppTheme.textMediumEmphasis,
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.dividerDark),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryDark),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          foregroundColor: AppTheme.onPrimaryDark,
                          padding: EdgeInsets.symmetric(vertical: 1.8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                    SizedBox(height: 1.5.h),

                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.dividerDark)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Text('ou', style: TextStyle(color: AppTheme.textMediumEmphasis)),
                        ),
                        Expanded(child: Divider(color: AppTheme.dividerDark)),
                      ],
                    ),
                    SizedBox(height: 1.5.h),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _loading ? null : _goRegister,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textHighEmphasis,
                          padding: EdgeInsets.symmetric(vertical: 1.6.h),
                          side: BorderSide(color: AppTheme.dividerDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Criar uma conta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
