import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:ebimbingan/data/services/user_service.dart';
import 'package:ebimbingan/data/services/firestore_service.dart';
import 'package:ebimbingan/data/services/firebase_auth_service.dart';
import 'package:ebimbingan/data/services/notification_service.dart';
import 'package:ebimbingan/data/services/ajuan_bimbingan_service.dart';
import 'package:ebimbingan/core/utils/auth_utils.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';

@GenerateMocks([
  // Services
  UserService,
  FirestoreService,
  FirebaseAuthService,
  NotificationService,
  AjuanBimbinganService,
  LogBimbinganService,
  AuthUtils,

  // Firebase Auth
  FirebaseAuth,
  UserCredential,
  User,

  // Firebase Firestore 
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  Query,

  // Optional
  ChangeNotifier,
])
void main() {}