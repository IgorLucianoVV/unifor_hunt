import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ConfettiAnimationWidget extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onAnimationComplete;

  const ConfettiAnimationWidget({
    super.key,
    required this.isActive,
    this.onAnimationComplete,
  });

  @override
  State<ConfettiAnimationWidget> createState() =>
      _ConfettiAnimationWidgetState();
}

class _ConfettiAnimationWidgetState extends State<ConfettiAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final List<ConfettiParticle> _particles = [];
  final int _particleCount = 50;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _initializeParticles();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles.clear();

    for (int i = 0; i < _particleCount; i++) {
      _particles.add(ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1,
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY: random.nextDouble() * 2 + 1,
        color: _getRandomColor(random),
        size: random.nextDouble() * 8 + 4,
        rotation: random.nextDouble() * 2 * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.2,
      ));
    }
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      AppTheme.lightTheme.primaryColor,
      AppTheme.lightTheme.colorScheme.secondary,
      AppTheme.secondaryVariantLight,
      AppTheme.accentGlow,
      Colors.pink,
      Colors.orange,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void didUpdateWidget(ConfettiAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initializeParticles();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _animation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
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
      final currentX =
          particle.x * size.width + particle.velocityX * progress * 100;
      final currentY = particle.y * size.height +
          particle.velocityY * progress * size.height;
      final currentRotation =
          particle.rotation + particle.rotationSpeed * progress * 10;

      if (currentY > size.height + 20) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress * 0.3)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(particle.size * 0.2)),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
