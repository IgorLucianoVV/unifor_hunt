import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScannerOverlayWidget extends StatefulWidget {
  final bool isScanning;
  final VoidCallback? onTorchToggle;
  final bool isTorchOn;
  final String currentClue;

  const ScannerOverlayWidget({
    super.key,
    required this.isScanning,
    this.onTorchToggle,
    required this.isTorchOn,
    required this.currentClue,
  });

  @override
  State<ScannerOverlayWidget> createState() => _ScannerOverlayWidgetState();
}

class _ScannerOverlayWidgetState extends State<ScannerOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _cornerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _cornerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top overlay with clue information
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 2.h,
              left: 4.w,
              right: 4.w,
              bottom: 2.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.backgroundDark.withValues(alpha: 0.9),
                  AppTheme.backgroundDark.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escaneie o QR Code',
                  style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textHighEmphasis,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Dica atual:',
                  style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.textMediumEmphasis,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryDark.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.currentClue,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textHighEmphasis,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Center scanning frame
        Center(
          child: AnimatedBuilder(
            animation: _cornerAnimation,
            builder: (context, child) {
              return Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.isScanning
                        ? AppTheme.primaryDark.withValues(
                            alpha: 0.3 + (_cornerAnimation.value * 0.7))
                        : AppTheme.textMediumEmphasis.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Corner indicators
                    ...List.generate(4, (index) {
                      return Positioned(
                        top: index < 2 ? 0 : null,
                        bottom: index >= 2 ? 0 : null,
                        left: index % 2 == 0 ? 0 : null,
                        right: index % 2 == 1 ? 0 : null,
                        child: Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: widget.isScanning
                                ? AppTheme.primaryDark.withValues(
                                    alpha: 0.5 + (_cornerAnimation.value * 0.5))
                                : AppTheme.textMediumEmphasis,
                            borderRadius: BorderRadius.only(
                              topLeft: index == 0
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              topRight: index == 1
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomLeft: index == 2
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: index == 3
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                            ),
                          ),
                        ),
                      );
                    }),

                    // Center scanning indicator
                    if (widget.isScanning)
                      Center(
                        child: Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark.withValues(
                                alpha: 0.3 + (_cornerAnimation.value * 0.7)),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.primaryDark.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom overlay with controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 2.h,
              left: 4.w,
              right: 4.w,
              top: 2.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppTheme.backgroundDark.withValues(alpha: 0.9),
                  AppTheme.backgroundDark.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Torch toggle button
                GestureDetector(
                  onTap: widget.onTorchToggle,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: widget.isTorchOn
                          ? AppTheme.primaryDark.withValues(alpha: 0.2)
                          : AppTheme.surfaceDark.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isTorchOn
                            ? AppTheme.primaryDark
                            : AppTheme.textMediumEmphasis
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: widget.isTorchOn ? 'flash_on' : 'flash_off',
                          color: widget.isTorchOn
                              ? AppTheme.primaryDark
                              : AppTheme.textMediumEmphasis,
                          size: 6.w,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Flash',
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: widget.isTorchOn
                                ? AppTheme.primaryDark
                                : AppTheme.textMediumEmphasis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Manual input button
                GestureDetector(
                  onTap: () {
                    _showManualInputDialog(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            AppTheme.textMediumEmphasis.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'keyboard',
                          color: AppTheme.textMediumEmphasis,
                          size: 6.w,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Manual',
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
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

        // Scanning instruction text
        Positioned(
          bottom: 25.h,
          left: 4.w,
          right: 4.w,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryDark.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Posicione o QR code dentro da moldura',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textHighEmphasis,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showManualInputDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.dialogDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Entrada Manual',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textHighEmphasis,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Digite o código QR manualmente:',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasis,
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: controller,
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textHighEmphasis,
                ),
                decoration: InputDecoration(
                  hintText: 'Código QR',
                  hintStyle: AppTheme.darkTheme.inputDecorationTheme.hintStyle,
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textMediumEmphasis.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryDark,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.textMediumEmphasis,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  // Handle manual QR code input
                  _handleManualQRCode(controller.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: AppTheme.onPrimaryDark,
              ),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _handleManualQRCode(String qrCode) {
    // This would be handled by the parent widget
    // For now, just show a toast or callback
  }
}
