import 'package:flutter/material.dart';
import '../screens/subscription/subscription_screen.dart';

class AppRoutes {
  static const String subscription = '/subscription';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      subscription: (context) => SubscriptionScreen(),
    };
  }
}
