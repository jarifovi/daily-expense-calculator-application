// ---------------------------------------------------------
// Copyright (c) 2026 jarifovi. All rights reserved.
// Author: jarifovi (https://github.com/jarifovi)
// Project: Daily Expense Calculator (3D Gravity Edition)
// ---------------------------------------------------------

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  double _shadowOffsetX = 0.0;
  double _shadowOffsetY = 0.0;
  double _hoverProgress = 0.0;
  
  double _targetTiltX = 0.0;
  double _targetTiltY = 0.0;
  double _targetShadowOffsetX = 0.0;
  double _targetShadowOffsetY = 0.0;
  bool _isHovered = false;

  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    // Damped interpolation factor (smoothness filter)
    const double lerpFactor = 0.12;
    
    setState(() {
      _tiltX += (_targetTiltX - _tiltX) * lerpFactor;
      _tiltY += (_targetTiltY - _tiltY) * lerpFactor;
      _shadowOffsetX += (_targetShadowOffsetX - _shadowOffsetX) * lerpFactor;
      _shadowOffsetY += (_targetShadowOffsetY - _shadowOffsetY) * lerpFactor;
      
      final double targetProgress = _isHovered ? 1.0 : 0.0;
      _hoverProgress += (targetProgress - _hoverProgress) * lerpFactor;
    });

    // Stop the ticker when animation rests to save CPU/GPU cycles
    if (!_isHovered && 
        _tiltX.abs() < 0.0001 && 
        _tiltY.abs() < 0.0001 && 
        _hoverProgress < 0.0001) {
      _ticker.stop();
      setState(() {
        _tiltX = 0.0;
        _tiltY = 0.0;
        _shadowOffsetX = 0.0;
        _shadowOffsetY = 0.0;
        _hoverProgress = 0.0;
      });
    }
  }

  void _onHover(PointerEvent event) {
    final size = context.size;
    if (size == null) return;

    final localPos = event.localPosition;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final relX = (localPos.dx - centerX) / centerX;
    final relY = (localPos.dy - centerY) / centerY;

    final maxRad = widget.maxTiltAngle * pi / 180;
    
    _targetTiltX = -relY * maxRad;
    _targetTiltY = relX * maxRad;
    _targetShadowOffsetX = -relX * widget.glowIntensity;
    _targetShadowOffsetY = -relY * widget.glowIntensity;

    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _onHoverEnter(PointerEvent event) {
    _isHovered = true;
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _onHoverExit(PointerEvent event) {
    _isHovered = false;
    _targetTiltX = 0.0;
    _targetTiltY = 0.0;
    _targetShadowOffsetX = 0.0;
    _targetShadowOffsetY = 0.0;
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double currentScale = 1.0 + (0.03 * _hoverProgress);
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective distortion
      ..rotateX(_tiltX)
      ..rotateY(_tiltY)
      ..scaleByDouble(currentScale, currentScale, 1.0, 1.0);

    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      onHover: _onHover,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Transform(
          transform: matrix,
          alignment: FractionalOffset.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(
                    Colors.black.withValues(alpha: 0.3),
                    widget.glowColor.withValues(alpha: 0.35),
                    _hoverProgress,
                  )!,
                  blurRadius: 12.0 + (13.0 * _hoverProgress),
                  spreadRadius: -2.0 + (4.0 * _hoverProgress),
                  offset: Offset(_shadowOffsetX, _shadowOffsetY),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
