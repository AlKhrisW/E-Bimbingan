// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';

// import 'package:ebimbingan/data/models/user_model.dart';
// import 'package:ebimbingan/features/auth/viewmodels/auth_viewmodel.dart';

// import '../../../mocks.mocks.dart';

// final tEmail = 'admin@project.com';
// final tPassword = 'password';
// final tUserUid = 'user_test_uid';

// // error message dari auth service yang akan di-catch
// final tAuthErrorMsg = 'email atau password salah.';

// // error message dari firestore service
// final tFirestoreErrorMsg = 'Data pengguna tidak ditemukan';

// // mock user firebase yang berhasil login
// final tMockUser = MockUser();

// // mock user model yang diambil dari firestore
// final tAdminModel = UserModel(
//   uid: tUserUid,
//   name: 'admin test',
//   email: tEmail,
//   role: 'admin',
// );

// void main() {
//   late MockFirebaseAuthService mockAuthService;
//   late MockFirestoreService mockFirestoreService;
//   late AuthViewModel viewModel;

//   // setup: dijalankan sebelum setiap tes
//   setUp(() {
//     mockAuthService = MockFirebaseAuthService();
//     mockFirestoreService = MockFirestoreService();

//     when(tMockUser.uid).thenReturn(tUserUid);

//     viewModel = AuthViewModel.internal(
//       authService: mockAuthService,
//       firestoreService: mockFirestoreService,
//     );
//   });

//   group('login logic', () {
//     test(
//       'login harus sukses dan mengembalikan user model jika kedua service sukses',
//       () async {
//         when(
//           mockAuthService.signInUser(email: tEmail, password: tPassword),
//         ).thenAnswer((_) async => tMockUser);

//         when(
//           mockFirestoreService.getUserData(tUserUid),
//         ).thenAnswer((_) async => tAdminModel);

//         final result = await viewModel.login(
//           email: tEmail,
//           password: tPassword,
//         );

//         expect(viewModel.isLoading, false);
//         expect(viewModel.errorMessage, null);
//         expect(result, isA<UserModel>());

//         verify(
//           mockAuthService.signInUser(email: tEmail, password: tPassword),
//         ).called(1);
//         verify(mockFirestoreService.getUserData(tUserUid)).called(1);
//       },
//     );

//     test('harus gagal dan menampilkan error auth jika signin gagal', () async {
//       when(
//         mockAuthService.signInUser(email: tEmail, password: tPassword),
//       ).thenThrow(tAuthErrorMsg);

//       final result = await viewModel.login(email: tEmail, password: tPassword);

//       expect(viewModel.isLoading, false);
//       expect(result, null);
//       expect(viewModel.errorMessage, tAuthErrorMsg);

//       verifyNever(mockFirestoreService.getUserData(any));
//     });

//     test(
//       'harus gagal dan menampilkan error firestore jika signin sukses tapi getuserdata gagal',
//       () async {
//         when(
//           mockAuthService.signInUser(email: tEmail, password: tPassword),
//         ).thenAnswer((_) async => tMockUser);

//         when(
//           mockFirestoreService.getUserData(tUserUid),
//         ).thenThrow(tFirestoreErrorMsg);

//         final result = await viewModel.login(
//           email: tEmail,
//           password: tPassword,
//         );

//         expect(viewModel.isLoading, false);
//         expect(result, null);
//         expect(
//           viewModel.errorMessage,
//           'Akun tidak terdaftar di database. Silakan hubungi Admin.',
//         );

//         verify(
//           mockAuthService.signInUser(email: tEmail, password: tPassword),
//         ).called(1);
//         verify(mockFirestoreService.getUserData(tUserUid)).called(1);
//       },
//     );
//   });

//   // ========================================================
//   // 🔥 TEST TAMBAHAN (TIDAK MENGHAPUS TEST SEBELUMNYA)
//   // ========================================================

//   test('email tidak boleh kosong', () async {
//     final result = await viewModel.login(email: '', password: tPassword);

//     expect(viewModel.errorMessage, 'Email tidak boleh kosong');
//     expect(result, null);
//     verifyNever(
//       mockAuthService.signInUser(
//         email: anyNamed("email"),
//         password: anyNamed("password"),
//       ),
//     );
//   });

//   test('password tidak boleh kosong', () async {
//     final result = await viewModel.login(email: tEmail, password: '');

//     expect(viewModel.errorMessage, 'Password tidak boleh kosong');
//     expect(result, null);
//     verifyNever(
//       mockAuthService.signInUser(
//         email: anyNamed("email"),
//         password: anyNamed("password"),
//       ),
//     );
//   });

//   test(
//     'login harus set isLoading menjadi true ketika proses dimulai',
//     () async {
//       when(
//         mockAuthService.signInUser(email: tEmail, password: tPassword),
//       ).thenAnswer(
//         (_) async =>
//             Future.delayed(Duration(milliseconds: 50), () => tMockUser),
//       );
//       when(
//         mockFirestoreService.getUserData(tUserUid),
//       ).thenAnswer((_) async => tAdminModel);

//       final futureLogin = viewModel.login(email: tEmail, password: tPassword);

//       // langsung cek — belum selesai
//       expect(viewModel.isLoading, true);

//       await futureLogin;
//       expect(viewModel.isLoading, false);
//     },
//   );

//   test(
//     'errorMessage harus kembali null setelah login sukses berikutnya',
//     () async {
//       // login gagal dulu
//       when(
//         mockAuthService.signInUser(email: tEmail, password: tPassword),
//       ).thenThrow(tAuthErrorMsg);

//       await viewModel.login(email: tEmail, password: tPassword);
//       expect(viewModel.errorMessage, tAuthErrorMsg);

//       // lalu login sukses
//       when(
//         mockAuthService.signInUser(email: tEmail, password: tPassword),
//       ).thenAnswer((_) async => tMockUser);
//       when(
//         mockFirestoreService.getUserData(tUserUid),
//       ).thenAnswer((_) async => tAdminModel);

//       final result = await viewModel.login(email: tEmail, password: tPassword);

//       expect(result, isNotNull);
//       expect(viewModel.errorMessage, null);
//     },
//   );

//   test(
//     'jika kedua service sukses, user model yang dikembalikan harus sesuai data firestore',
//     () async {
//       when(
//         mockAuthService.signInUser(email: tEmail, password: tPassword),
//       ).thenAnswer((_) async => tMockUser);

//       when(
//         mockFirestoreService.getUserData(tUserUid),
//       ).thenAnswer((_) async => tAdminModel);

//       final result = await viewModel.login(email: tEmail, password: tPassword);

//       expect(result, isA<UserModel>());
//       expect(result!.uid, tAdminModel.uid);
//       expect(result.name, tAdminModel.name);
//       expect(result.email, tAdminModel.email);
//       expect(result.role, tAdminModel.role);
//     },
//   );

//   test('password harus minimal 6 karakter', () async {
//     final result = await viewModel.login(email: tEmail, password: '12345');

//     expect(viewModel.errorMessage, 'Password minimal 6 karakter');
//     expect(result, null);
//     verifyNever(mockAuthService.signInUser(email: anyNamed("email"), password: anyNamed("password")));
//   });
// }
