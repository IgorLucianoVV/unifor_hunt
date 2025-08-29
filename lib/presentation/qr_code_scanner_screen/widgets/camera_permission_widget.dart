import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraPermissionWidget extends StatelessWidget {
  final VoidCallback onRequestPermission;
  final VoidCallback onGoBack;

  const CameraPermissionWidget({
    super.key,
    required this.onRequestPermission,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundDark,
            AppTheme.surfaceDark,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            children: [
              // Header with back button
              Row(
                children: [
                  GestureDetector(
                    onTap: onGoBack,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.textMediumEmphasis
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.textHighEmphasis,
                        size: 6.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Permissão da Câmera',
                    style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textHighEmphasis,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Permission illustration
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryDark.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'camera_alt',
                          color: AppTheme.primaryDark,
                          size: 12.w,
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      'Acesso à Câmera Necessário',
                      style:
                          AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textHighEmphasis,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 2.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Para escanear códigos QR e continuar sua caça ao tesouro, precisamos acessar sua câmera.',
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textMediumEmphasis,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Permission benefits
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryDark.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildPermissionBenefit(
                            icon: 'qr_code_scanner',
                            title: 'Escaneamento Rápido',
                            description: 'Escaneie códigos QR instantaneamente',
                          ),
                          SizedBox(height: 2.h),
                          _buildPermissionBenefit(
                            icon: 'security',
                            title: 'Seguro e Privado',
                            description: 'Suas imagens não são armazenadas',
                          ),
                          SizedBox(height: 2.h),
                          _buildPermissionBenefit(
                            icon: 'offline_bolt',
                            title: 'Funciona Offline',
                            description: 'Escaneamento sem internet',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRequestPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDark,
                        foregroundColor: AppTheme.onPrimaryDark,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'camera_alt',
                            color: AppTheme.onPrimaryDark,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Permitir Acesso à Câmera',
                            style: AppTheme.darkTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.onPrimaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onGoBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textMediumEmphasis,
                        side: BorderSide(
                          color: AppTheme.textMediumEmphasis
                              .withValues(alpha: 0.3),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Voltar',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textMediumEmphasis,
                        ),
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
  }

  Widget _buildPermissionBenefit({
    required String icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.primaryDark,
            size: 5.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textHighEmphasis,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
