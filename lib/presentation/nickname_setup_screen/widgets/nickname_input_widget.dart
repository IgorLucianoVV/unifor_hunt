import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class NicknameInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool isValid;
  final String? errorMessage;

  const NicknameInputWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.isValid,
    this.errorMessage,
  });

  @override
  State<NicknameInputWidget> createState() => _NicknameInputWidgetState();
}

class _NicknameInputWidgetState extends State<NicknameInputWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _startGlowAnimation() {
    _glowController.repeat(reverse: true);
  }

  void _stopGlowAnimation() {
    _glowController.stop();
    _glowController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: _isFocused
                    ? [
                        AppTheme.glowEffect(
                          color: widget.isValid
                              ? AppTheme.darkTheme.colorScheme.primary
                              : AppTheme.darkTheme.colorScheme.error,
                          blurRadius: 10.0 * _glowAnimation.value,
                          spreadRadius: 1.0,
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                onTap: () {
                  setState(() => _isFocused = true);
                  _startGlowAnimation();
                },
                onFieldSubmitted: (_) {
                  setState(() => _isFocused = false);
                  _stopGlowAnimation();
                },
                onTapOutside: (_) {
                  setState(() => _isFocused = false);
                  _stopGlowAnimation();
                  FocusScope.of(context).unfocus();
                },
                maxLength: 20,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Digite seu nome de caçador',
                  hintStyle: AppTheme.darkTheme.inputDecorationTheme.hintStyle
                      ?.copyWith(
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: AppTheme.darkTheme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: AppTheme.darkTheme.colorScheme.outline,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: AppTheme.darkTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: widget.isValid
                          ? AppTheme.darkTheme.colorScheme.primary
                          : AppTheme.darkTheme.colorScheme.error,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: AppTheme.darkTheme.colorScheme.error,
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: AppTheme.darkTheme.colorScheme.error,
                      width: 2.0,
                    ),
                  ),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 1.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.errorMessage ?? _getValidationMessage(),
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: widget.isValid
                      ? AppTheme.darkTheme.colorScheme.secondary
                      : AppTheme.darkTheme.colorScheme.error,
                  fontSize: 12.sp,
                ),
              ),
              Text(
                '${widget.controller.text.length}/20',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasis,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getValidationMessage() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      return 'Escolha um nome único para sua aventura';
    } else if (text.length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    } else if (widget.isValid) {
      return 'Nome disponível! ✓';
    }
    return 'Nome deve conter apenas letras e números';
  }
}
