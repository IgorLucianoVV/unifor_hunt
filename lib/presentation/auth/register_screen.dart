import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _nickCtrl.dispose();
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

  String? _validateConfirm(String? v) {
    if ((v ?? '').isEmpty) return 'Confirme a senha';
    if (v != _passCtrl.text) return 'As senhas não conferem';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final res = await _auth.register(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        nickname: _nickCtrl.text.trim().isEmpty ? null : _nickCtrl.text.trim(),
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
          content: Text('Falha no cadastro: $e'),
          backgroundColor: AppTheme.errorDark,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
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
          'Criar conta',
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
                    Icon(Icons.person_add, size: 16.w, color: AppTheme.primaryDark),
                    SizedBox(height: 3.h),

                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      style: TextStyle(color: AppTheme.onPrimaryDark),
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: TextStyle(color: AppTheme.textMediumEmphasis),
                        prefixIcon: Icon(Icons.email, color: AppTheme.textMediumEmphasis),
                        filled: true,
                        fillColor: AppTheme.cardDark,
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
                    ),
                    SizedBox(height: 2.h),

                    TextFormField(
                      controller: _nickCtrl,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: AppTheme.onPrimaryDark),
                      decoration: InputDecoration(
                        labelText: 'Nickname (opcional)',
                        labelStyle: TextStyle(color: AppTheme.textMediumEmphasis),
                        prefixIcon: Icon(Icons.badge, color: AppTheme.textMediumEmphasis),
                        filled: true,
                        fillColor: AppTheme.cardDark,
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
                    ),
                    SizedBox(height: 2.h),

                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure1,
                      textInputAction: TextInputAction.next,
                      validator: _validatePass,
                      style: TextStyle(color: AppTheme.onPrimaryDark),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: TextStyle(color: AppTheme.textMediumEmphasis),
                        prefixIcon: Icon(Icons.lock, color: AppTheme.textMediumEmphasis),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure1 = !_obscure1),
                          icon: Icon(
                            _obscure1 ? Icons.visibility : Icons.visibility_off,
                            color: AppTheme.textMediumEmphasis,
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.cardDark,
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
                    ),
                    SizedBox(height: 2.h),

                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscure2,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirm,
                      onFieldSubmitted: (_) => _submit(),
                      style: TextStyle(color: AppTheme.onPrimaryDark),
                      decoration: InputDecoration(
                        labelText: 'Confirmar senha',
                        labelStyle: TextStyle(color: AppTheme.textMediumEmphasis),
                        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textMediumEmphasis),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure2 = !_obscure2),
                          icon: Icon(
                            _obscure2 ? Icons.visibility : Icons.visibility_off,
                            color: AppTheme.textMediumEmphasis,
                          ),
                        ),
                        filled: true,
                        fillColor: AppTheme.cardDark,
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
                            : const Text('Criar conta'),
                      ),
                    ),
                    SizedBox(height: 1.5.h),

                    TextButton(
                      onPressed: _loading ? null : _goLogin,
                      child: const Text('Já tenho conta – Entrar'),
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
