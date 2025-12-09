import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart'; 
import 'app.dart';
import 'package:ebimbingan/data/services/notification_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  // 1. Set Background Handler (Sebelum runApp)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 2. Inisialisasi Notification Service
  await NotificationService().initialize();

  await initializeDateFormatting('id', null);
  
  runApp(const App());
}