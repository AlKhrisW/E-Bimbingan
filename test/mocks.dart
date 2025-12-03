  import 'package:mockito/annotations.dart';
  import 'package:firebase_auth/firebase_auth.dart';

  // --- SERVICE LAYER PROYEK ANDA ---
  import 'package:ebimbingan/data/services/user_service.dart'; 
  import 'package:ebimbingan/data/services/firestore_service.dart'; 
  import 'package:ebimbingan/data/services/firebase_auth_service.dart'; 

  // --- DEFINISI CLASS YANG AKAN DI-MOCK ---
  @GenerateMocks([
    // Services
    UserService, 
    FirestoreService, 
    FirebaseAuthService, 
    
    // Firebase Classes (harus di-mock)
    FirebaseAuth,     
    UserCredential,   
    User,             
  ]) 
  void main() {}
