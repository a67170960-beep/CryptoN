import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 18,
    this.blur = 16,
    this.opacity = 0.11,
    this.padding,
    this.margin,
    this.borderColor,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding ?? const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: gradient ??
                    LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(opacity + 0.03),
                        Colors.white.withOpacity(opacity * 0.45),
                      ],
                    ),
                border: Border.all(
                  color: borderColor ?? Colors.white.withOpacity(0.11),
                  width: 0.7,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: 12,
      opacity: 0.1,
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Icon(icon, color: color ?? const Color(0xFF7EB8D4), size: size),
    );
  }
}
