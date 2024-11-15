import 'package:flutter/material.dart';

class PageTransition extends PageRouteBuilder {
  final Widget page;
  final TransitionType type;
  final Curve curve;
  final Alignment alignment;
  final Duration duration;

  PageTransition({
    required this.page,
    this.type = TransitionType.fade,
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (type) {
              case TransitionType.fade:
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );

              case TransitionType.scale:
                return ScaleTransition(
                  alignment: alignment,
                  scale: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  ),
                  child: child,
                );

              case TransitionType.slideRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  ),
                  child: child,
                );

              case TransitionType.slideLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  ),
                  child: child,
                );

              case TransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  ),
                  child: child,
                );

              case TransitionType.slideDown:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  ),
                  child: child,
                );

              case TransitionType.rotate:
                return RotationTransition(
                  alignment: alignment,
                  turns: animation,
                  child: child,
                );

              case TransitionType.size:
                return Align(
                  alignment: alignment,
                  child: SizeTransition(
                    sizeFactor: animation,
                    child: child,
                  ),
                );

              case TransitionType.rightToLeftFaded:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );

              case TransitionType.leftToRightFaded:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );

              case TransitionType.scaleWithFade:
                return ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
            }
          },
        );
}

enum TransitionType {
  fade,
  scale,
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  rotate,
  size,
  rightToLeftFaded,
  leftToRightFaded,
  scaleWithFade,
}

// Extension for BuildContext to make navigation easier
extension NavigationExtension on BuildContext {
  Future<T?> pushTransition<T>(
    Widget page, {
    TransitionType type = TransitionType.fade,
    Curve curve = Curves.easeInOut,
    Alignment alignment = Alignment.center,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.push<T>(
      this,
      PageTransition(
        page: page,
        type: type,
        curve: curve,
        alignment: alignment,
        duration: duration,
      ),
    );
  }

  Future<T?> pushReplacementTransition<T>(
    Widget page, {
    TransitionType type = TransitionType.fade,
    Curve curve = Curves.easeInOut,
    Alignment alignment = Alignment.center,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.pushReplacement(
      this,
      PageTransition(
        page: page,
        type: type,
        curve: curve,
        alignment: alignment,
        duration: duration,
      ),
    );
  }
}