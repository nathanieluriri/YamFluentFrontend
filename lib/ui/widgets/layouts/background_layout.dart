import 'package:flutter/material.dart';
import 'dart:math' as math;

class AuthBackgroundLayout extends StatelessWidget {
  final Widget child;
  final double topOffset;
  final Color backgroundColor;
  final double ovalAngle;
  final Offset ovalPosition;
  final Size ovalSize;
  final double ovalOpacity;
  final double reverseOvalAngle;
  const AuthBackgroundLayout({
    super.key,
    required this.child,
    this.topOffset = 42,
    this.backgroundColor = const Color(0xFF001924),
    this.ovalAngle = -35, 
    this.reverseOvalAngle=35,
    this.ovalPosition = const Offset(244.5, 44.3),
    this.ovalSize = const Size(210, 130),
    this.ovalOpacity = 0.04,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    
    final rotation = ovalAngle * math.pi / 180;
    final rotation2 = reverseOvalAngle * math.pi / 180;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
            
            Positioned(
              top: ovalPosition.dy,
              left: ovalPosition.dx,
              child: _Oval(
                size: ovalSize,
                rotation: rotation2,
                opacity: ovalOpacity,
              ),
            ),

            Positioned(
              top: 30,
              left: 0,
              child: _Oval(
                size:  Size(screenWidth,99),
                rotation: 0,
                opacity: 0.05,
              ),
            ),

            
            Positioned(
              top: ovalPosition.dy,
              left: screenWidth - ovalPosition.dx - ovalSize.width,
              child: _Oval(
                size: ovalSize,
                rotation: rotation,
                opacity: ovalOpacity,
              ),
            ),

            
            Positioned.fill(
              top: topOffset,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: child,
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Oval extends StatelessWidget {
  final Size size;
  final double rotation;
  final double opacity;

  const _Oval({
    required this.size,
    required this.rotation,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(45),
        ),
      ),
    );
  }
}
