import 'package:flutter/material.dart';
import '../screens/payment_screen.dart';
import '../screens/home_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/auth/auth_screen.dart';
// Import other screens as needed

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
        
      case '/payment':
        return MaterialPageRoute(
          builder: (_) => const PaymentScreen(),
          settings: settings,
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case '/auth':
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(),
          settings: settings,
        );

      // Add other routes as needed

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
