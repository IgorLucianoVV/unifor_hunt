import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ConfettiAnimationWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onAnimationComplete;

  const ConfettiAnimationWidget({
    super.key,
    required this.isVisible,
    this.onAnimationComplete,
  });

  @override
  State<ConfettiAnimationWidget> createState() =>
      _ConfettiAnimationWidgetState();
}

class _ConfettiAnimationWidgetState extends State<ConfettiAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _generateParticles();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ConfettiAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward(from: 0.0);
    }
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(
        x: _random.nextDouble() * 100.w,
        y: -10.h,
        color: _getRandomColor(),
        size: _random.nextDouble() * 3 + 2,
        velocityX: (_random.nextDouble() - 0.5) * 4,
        velocityY: _random.nextDouble() * 3 + 2,
        rotation: _random.nextDouble() * 2 * math.pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
      ));
    }
  }

  Color _getRandomColor() {
    final colors = [
      AppTheme.darkTheme.colorScheme.primary,
      AppTheme.darkTheme.colorScheme.secondary,
      AppTheme.darkTheme.colorScheme.tertiary,
      AppTheme.darkTheme.colorScheme.primaryContainer,
      AppTheme.darkTheme.colorScheme.secondaryContainer,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(
                particles: _particles,
                progress: _animation.value,
              ),
              size: Size(100.w, 100.h),
            );
          },
        ),
      ),
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double velocityX;
  final double velocityY;
  double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;

      final currentX =
          particle.x + particle.velocityX * progress * size.width * 0.01;
      final currentY =
          particle.y + particle.velocityY * progress * size.height * 0.01;
      final currentRotation =
          particle.rotation + particle.rotationSpeed * progress * 10;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size,
      );

      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
