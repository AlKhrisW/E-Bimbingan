// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pastikan Anda menggunakan options: DefaultFirebaseOptions.currentPlatform jika diperlukan
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  
  runApp(const App());
}