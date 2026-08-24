import 'dart:math';
import 'package:flutter/material.dart';

class GravityTiltCard extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle; // maximum tilt angle in degrees
  final double glowIntensity;
  final Color glowColor;
  final VoidCallback? onTap;

  const GravityTiltCard({
    super.key,
    required this.child,
    this.maxTiltAngle = 12.0,
    this.glowIntensity = 15.0,
    this.glowColor = const Color(0xFF4CAF50),
    this.onTap,
  });

  @override
  State<GravityTiltCard> createState() => _GravityTiltCardState();
}

class _GravityTiltCardState extends State<GravityTiltCard> with SingleTickerProviderStateMixin {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isHovered = false;
  
  // Hover position to shift shadow/glow direction
  double _shadowOffsetX = 0.0;
  double _shadowOffsetY = 0.0;

  void _onHover(PointerEvent event) {
    final size = context.size;
    if (size == null) return;

    // Calculate relative coordinates from center (-0.5 to 0.5)
    final localPos = event.localPosition;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final relX = (localPos.dx - centerX) / centerX; // horizontal relative pos
    final relY = (localPos.dy - centerY) / centerY; // vertical relative pos

    // Translate to tilt angles (rad)
    final maxRad = widget.maxTiltAngle * pi / 180;
    
    setState(() {
      _tiltX = -relY * maxRad; // tilting around X axis based on Y movement
      _tiltY = relX * maxRad;  // tilting around Y axis based on X movement
      _shadowOffsetX = -relX * widget.glowIntensity;
      _shadowOffsetY = -relY * widget.glowIntensity;
    });
  }

  void _onHoverEnter(PointerEvent event) {
    setState(() {
      _isHovered = true;
    });
  }

  void _onHoverExit(PointerEvent event) {
    setState(() {
      _isHovered = false;
      _tiltX = 0.0;
      _tiltY = 0.0;
      _shadowOffsetX = 0.0;
      _shadowOffsetY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0015) // perspective distortion
      ..rotateX(_tiltX)
      ..rotateY(_tiltY)
      ..scaleByDouble(_isHovered ? 1.04 : 1.0, _isHovered ? 1.04 : 1.0, 1.0, 1.0);

    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      onHover: _onHover,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: TweenAnimationBuilder<Matrix4>(
          duration: Duration(milliseconds: _isHovered ? 50 : 250),
          curve: Curves.easeOutCubic,
          tween: Matrix4Tween(begin: Matrix4.identity(), end: matrix),
          builder: (context, currentMatrix, childWidget) {
            return Transform(
              transform: currentMatrix,
              alignment: FractionalOffset.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered 
                          ? widget.glowColor.withValues(alpha: 0.4) 
                          : Colors.black.withValues(alpha: 0.3),
                      blurRadius: _isHovered ? 25.0 : 12.0,
                      spreadRadius: _isHovered ? 2.0 : -2.0,
                      offset: Offset(_shadowOffsetX, _shadowOffsetY),
                    ),
                  ],
                ),
                child: childWidget,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
