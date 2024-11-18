#!/bin/bash

# Find all Dart files
find lib -name "*.dart" -type f | while read file; do
  # Comment out Firebase imports
  sed -i '' 's/^import.*firebase.*$/\/\/ &/' "$file"
  
  # Comment out Firebase.initializeApp
  sed -i '' 's/^.*Firebase.initializeApp.*$/\/\/ &/' "$file"
  
  # Comment out FirebaseAuth
  sed -i '' 's/^.*FirebaseAuth.*$/\/\/ &/' "$file"
  
  # Comment out FirebaseFirestore
  sed -i '' 's/^.*FirebaseFirestore.*$/\/\/ &/' "$file"
  
  # Comment out FirebaseStorage
  sed -i '' 's/^.*FirebaseStorage.*$/\/\/ &/' "$file"
done

# Update main.dart specifically
cat > lib/main.dart << 'MAIN'
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golden Years Pet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Temporary Home'),
        ),
      ),
    );
  }
}
MAIN
