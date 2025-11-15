// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Asumsi Anda sudah mengimpor FirebaseOptions yang benar
import 'firebase_options.dart'; 
import 'app.dart'; // Import class App yang baru

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pastikan Anda menggunakan options: DefaultFirebaseOptions.currentPlatform jika diperlukan
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  
  // Ganti runApp(const MyApp()) dengan runApp(const App())
  runApp(const App());
}