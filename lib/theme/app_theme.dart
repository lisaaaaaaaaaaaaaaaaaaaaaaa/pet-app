import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Scheme
  static const Color primaryColor = Color(0xFF93B7BE);    // Soft blue-gray
  static const Color secondaryColor = Color(0xFF8C9A9E);  // Medium gray
  static const Color tertiaryColor = Color(0xFF747578);   // Dark gray
  
  // Background Pattern Colors
  static const Color bubbleColor1 = Color(0x1593B7BE);    // 15% opacity
  static const Color bubbleColor2 = Color(0x108C9A9E);    // 10% opacity
  static const Color pawPrintColor = Color(0x08747578);   // 8% opacity

  // Additional Colors
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF2C3E50);
  static const Color textSecondaryColor = Color(0xFF6C757D);
  static const Color textTertiaryColor = Color(0xFF95A5A6);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onBackground: textPrimaryColor,
        onSurface: textPrimaryColor,
        onError: Colors.white,
      ),

      // Typography
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(color: textPrimaryColor),
        displayMedium: const TextStyle(color: textPrimaryColor),
        displaySmall: const TextStyle(color: textPrimaryColor),
        headlineMedium: const TextStyle(color: textPrimaryColor),
        headlineSmall: const TextStyle(color: textPrimaryColor),
        titleLarge: const TextStyle(color: textPrimaryColor),
        titleMedium: const TextStyle(color: textSecondaryColor),
        titleSmall: const TextStyle(color: textSecondaryColor),
        bodyLarge: const TextStyle(color: textPrimaryColor),
        bodyMedium: const TextStyle(color: textSecondaryColor),
        bodySmall: const TextStyle(color: textTertiaryColor),
      ),

      // Component Themes
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Additional Customizations
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimaryColor),
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Background Decorations
class BackgroundDecorations extends StatelessWidget {
  final Widget child;

  const BackgroundDecorations({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background patterns
        Positioned.fill(
          child: CustomPaint(
            painter: BackgroundPainter(),
          ),
        ),
        // Main content
        child,
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw bubbles
    _drawBubbles(canvas, size);
    // Draw paw prints
    _drawPawPrints(canvas, size);
  }

  void _drawBubbles(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppTheme.bubbleColor1
      ..style = PaintingStyle.fill;
    
    final paint2 = Paint()
      ..color = AppTheme.bubbleColor2
      ..style = PaintingStyle.fill;

    // Draw various sized bubbles
    final random = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 15; i++) {
      final x = (random + i * 567) % size.width;
      final y = (random + i * 789) % size.height;
      final radius = 20.0 + (random + i * 123) % 40;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        i % 2 == 0 ? paint1 : paint2,
      );
    }
  }

  void _drawPawPrints(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.pawPrintColor
      ..style = PaintingStyle.fill;

    // Draw paw prints at various positions
    final random = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < 10; i++) {
      final x = (random + i * 456) % size.width;
      final y = (random + i * 678) % size.height;
      _drawPawPrint(canvas, Offset(x, y), paint);
    }
  }

  void _drawPawPrint(Canvas canvas, Offset center, Paint paint) {
    // Main pad
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: 30,
        height: 35,
      ),
      paint,
    );

    // Toe pads
    final toeOffsets = [
      Offset(center.dx - 15, center.dy - 20),
      Offset(center.dx + 15, center.dy - 20),
      Offset(center.dx - 20, center.dy - 10),
      Offset(center.dx + 20, center.dy - 10),
    ];

    for (var offset in toeOffsets) {
      canvas.drawCircle(offset, 8, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
