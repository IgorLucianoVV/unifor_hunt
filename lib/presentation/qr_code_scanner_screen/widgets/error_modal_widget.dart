import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ErrorModalWidget extends StatefulWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onClose;
  final String? qrCodeValue;

  const ErrorModalWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onClose,
    this.qrCodeValue,
  });

  @override
  State<ErrorModalWidget> createState() => _ErrorModalWidgetState();
}

class _ErrorModalWidgetState extends State<ErrorModalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    // Trigger haptic feedback and shake animation
    HapticFeedback.vibrate();
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.dialogDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.errorDark.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.errorDark.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error icon with glow effect
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppTheme.errorDark.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.errorDark.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.errorDark.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'error_outline',
                        color: AppTheme.errorDark,
                        size: 10.w,
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Error title
                  Text(
                    'QR Code Inválido',
                    style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textHighEmphasis,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 2.h),

                  // Error message
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.errorDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.errorDark.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      widget.errorMessage,
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMediumEmphasis,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Show QR code value if available
                  if (widget.qrCodeValue != null) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.textMediumEmphasis
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Código escaneado:',
                            style: AppTheme.darkTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.textMediumEmphasis,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            widget.qrCodeValue!,
                            style: AppTheme.dataStyle(
                              fontSize: 12.sp,
                              color: AppTheme.textHighEmphasis,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 4.h),

                  // Help tips
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryDark.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'lightbulb_outline',
                              color: AppTheme.primaryDark,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Dicas para escanear:',
                              style: AppTheme.darkTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        _buildTip('Certifique-se de que há luz suficiente'),
                        _buildTip('Mantenha o QR code dentro da moldura'),
                        _buildTip('Verifique se o código não está danificado'),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onClose,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textMediumEmphasis,
                            side: BorderSide(
                              color: AppTheme.textMediumEmphasis
                                  .withValues(alpha: 0.3),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Fechar',
                            style: AppTheme.darkTheme.textTheme.titleSmall
                                ?.copyWith(
                              color: AppTheme.textMediumEmphasis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: widget.onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryDark,
                            foregroundColor: AppTheme.onPrimaryDark,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'refresh',
                                color: AppTheme.onPrimaryDark,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Tentar Novamente',
                                style: AppTheme.darkTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  color: AppTheme.onPrimaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            width: 1.w,
            height: 1.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              tip,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMediumEmphasis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
