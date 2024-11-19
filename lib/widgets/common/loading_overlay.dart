import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? barrierColor;
  final Widget? loadingWidget;
  final bool dismissible;
  final double opacity;
  final Duration animationDuration;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.barrierColor,
    this.loadingWidget,
    this.dismissible = false,
    this.opacity = 0.5,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AnimatedOpacity(
            opacity: isLoading ? 1.0 : 0.0,
            duration: animationDuration,
            child: Stack(
              children: [
                // Barrier
                ModalBarrier(
                  color: (barrierColor ?? Colors.black).withOpacity(opacity),
                  dismissible: dismissible,
                ),
                // Loading indicator
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: loadingWidget ??
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                            if (loadingText != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                loadingText!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Variant: Custom Loading Overlay
class CustomLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Widget loadingWidget;
  final Color barrierColor;
  final bool dismissible;
  final VoidCallback? onDismiss;

  const CustomLoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    required this.loadingWidget,
    this.barrierColor = Colors.black54,
    this.dismissible = false,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          GestureDetector(
            onTap: dismissible ? onDismiss ?? () {} : null,
            child: Container(
              color: barrierColor,
              child: Center(
                child: loadingWidget,
              ),
            ),
          ),
      ],
    );
  }
}

// Helper class to manage loading overlay state
class LoadingOverlayController extends ChangeNotifier {
  bool _isLoading = false;
  String? _loadingText;

  bool get isLoading => _isLoading;
  String? get loadingText => _loadingText;

  void show({String? text}) {
    _isLoading = true;
    _loadingText = text;
    notifyListeners();
  }

  void hide() {
    _isLoading = false;
    _loadingText = null;
    notifyListeners();
  }

  void updateText(String text) {
    _loadingText = text;
    notifyListeners();
  }
}

// Widget that uses LoadingOverlayController
class ControlledLoadingOverlay extends StatelessWidget {
  final Widget child;
  final LoadingOverlayController controller;
  final Widget? loadingWidget;
  final Color? barrierColor;
  final bool dismissible;
  final double opacity;

  const ControlledLoadingOverlay({
    Key? key,
    required this.child,
    required this.controller,
    this.loadingWidget,
    this.barrierColor,
    this.dismissible = false,
    this.opacity = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return LoadingOverlay(
          isLoading: controller.isLoading,
          loadingText: controller.loadingText,
          loadingWidget: loadingWidget,
          barrierColor: barrierColor,
          dismissible: dismissible,
          opacity: opacity,
          child: child!,
        );
      },
      child: child,
    );
  }
}