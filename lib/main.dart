import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Correct import
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'services/auth_provider.dart';
import 'services/subscription_manager.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({
    Key? key,
    required this.prefs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionManager(prefs)),
      ],
      child: MaterialApp(
        title: 'Golden Years',
        theme: AppTheme.theme,
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
