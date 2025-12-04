import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ebimbingan/features/admin/viewmodels/admin_user_management_viewmodel.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import '../../../mocks.mocks.dart';

void main() {
  late MockUserService mockUserService;
  late MockFirebaseAuthService mockAuthService;
  late AdminUserManagementViewModel viewModel;

  // contoh data user
  final dummyAdmin = UserModel(
    uid: 'uid-admin',
    name: 'Admin Test',
    email: 'admin@test.com',
    role: 'admin',
    phoneNumber: '08123456789',
  );

  final dummyDosen = UserModel(
    uid: 'uid-dosen',
    name: 'Dosen Test',
    email: 'dosen@test.com',
    role: 'dosen',
    phoneNumber: '08129876543',
    nip: '123456',
    jabatan: 'Lektor',
  );

  final dummyMahasiswa = UserModel(
    uid: 'uid-mhs',
    name: 'Mahasiswa Test',
    email: 'mhs@test.com',
    role: 'mahasiswa',
    phoneNumber: '08121234567',
    nim: '987654321',
    programStudi: 'Teknik Informatika',
    placement: 'PT. Contoh',
    startDate: DateTime(2025, 11, 25),
    dosenUid: 'uid-dosen',
  );

  setUp(() {
    mockUserService = MockUserService();
    mockAuthService = MockFirebaseAuthService();
    viewModel = AdminUserManagementViewModel(
      userService: mockUserService,
      authService: mockAuthService,
    );
  });

  group('LOAD USERS', () {
    test('loadAllUsers berhasil', () async {
      when(mockUserService.fetchAllUsers())
          .thenAnswer((_) async => [dummyAdmin, dummyDosen]);

      await viewModel.loadAllUsers();

      expect(viewModel.isLoading, false);
      expect(viewModel.users.length, 2);
      expect(viewModel.errorMessage, null);
    });

    test('loadAllUsers gagal', () async {
      when(mockUserService.fetchAllUsers())
          .thenThrow(Exception('Network Error'));

      await viewModel.loadAllUsers();

      expect(viewModel.isLoading, false);
      expect(viewModel.users, isEmpty);
      expect(viewModel.errorMessage, contains('Gagal memuat daftar pengguna'));
    });

    test('loadDosenList berhasil', () async {
      when(mockUserService.fetchDosenList())
          .thenAnswer((_) async => [dummyDosen]);

      await viewModel.loadDosenList();

      expect(viewModel.isLoading, false);
      expect(viewModel.users.length, 1);
      expect(viewModel.users.first.role, 'dosen');
    });
  });

group('REGISTER USER', () {
  test('registerUserUniversal berhasil', () async {
    // Buat UserModel yang akan dikembalikan oleh registerUser
    final registeredUser = UserModel(
      uid: 'new-uid',
      name: 'New User',
      email: 'newuser@test.com',
      role: 'mahasiswa',
      phoneNumber: '08121234567',
      nim: '12345',
      programStudi: 'TI',
      placement: 'PT. Contoh',
      startDate: DateTime.now(),
      dosenUid: 'uid-dosen',
    );

    when(mockAuthService.registerUser(
      email: anyNamed('email'),
      password: anyNamed('password'),
      name: anyNamed('name'),
      role: anyNamed('role'),
      phoneNumber: anyNamed('phoneNumber'),
      programStudi: anyNamed('programStudi'),
      nim: anyNamed('nim'),
      placement: anyNamed('placement'),
      startDate: anyNamed('startDate'),
      dosenUid: anyNamed('dosenUid'),
      nip: anyNamed('nip'),
      jabatan: anyNamed('jabatan'),
    )).thenAnswer((_) async => registeredUser); // ✅ Return UserModel

    when(mockUserService.fetchAllUsers())
        .thenAnswer((_) async => [dummyAdmin]);

    final result = await viewModel.registerUserUniversal(
      email: 'newuser@test.com',
      name: 'New User',
      role: 'mahasiswa',
      phoneNumber: '08121234567',
      programStudi: 'TI',
      nim: '12345',
      placement: 'PT. Contoh',
      startDate: DateTime.now(),
      dosenUid: 'uid-dosen',
    );

    expect(result, true);
    expect(viewModel.successMessage, contains('berhasil didaftarkan'));
    expect(viewModel.errorMessage, null);
    expect(viewModel.users, isNotEmpty);
  });

  test('registerUserUniversal gagal', () async {
    when(mockAuthService.registerUser(
      email: anyNamed('email'),
      password: anyNamed('password'),
      name: anyNamed('name'),
      role: anyNamed('role'),
      phoneNumber: anyNamed('phoneNumber'),
    )).thenThrow(Exception('Email sudah digunakan'));

    final result = await viewModel.registerUserUniversal(
      email: 'existing@test.com',
      name: 'Existing User',
      role: 'dosen',
      phoneNumber: '08123456789',
    );

    expect(result, false);
    expect(viewModel.errorMessage, contains('Email sudah digunakan'));
    expect(viewModel.successMessage, null);
  });
});

  group('UPDATE USER', () {
    setUp(() {
      // inject user awal
      viewModel.users = [dummyDosen];
    });

    test('updateUserUniversal berhasil', () async {
      when(mockUserService.updateUserMetadata(any))
          .thenAnswer((_) async {}); // ✅ Fixed: return void instead of null

      final result = await viewModel.updateUserUniversal(
        uid: dummyDosen.uid,
        email: 'updated@test.com',
        name: 'Dosen Updated',
        role: 'dosen',
        phoneNumber: '08120000000',
        nip: '654321',
        jabatan: 'Lektor Kepala',
      );

      expect(result, true);
      expect(viewModel.users.first.name, 'Dosen Updated');
      expect(viewModel.successMessage, contains('berhasil diperbarui'));
      expect(viewModel.errorMessage, null);
    });

    test('updateUserUniversal gagal', () async {
      when(mockUserService.updateUserMetadata(any))
          .thenThrow(Exception('Update error'));

      final result = await viewModel.updateUserUniversal(
        uid: dummyDosen.uid,
        email: 'fail@test.com',
        name: 'Fail Name',
        role: 'dosen',
        phoneNumber: '08120000000',
      );

      expect(result, false);
      expect(viewModel.errorMessage, contains('Gagal memperbarui data'));
    });
  });

  group('DELETE USER', () {
    setUp(() {
      viewModel.users = [dummyAdmin];
    });

    test('deleteUser berhasil', () async {
      when(mockAuthService.deleteUser(dummyAdmin.uid))
          .thenAnswer((_) async {}); // ✅ Fixed: return void instead of null

      final result = await viewModel.deleteUser(dummyAdmin.uid);

      expect(result, true);
      expect(viewModel.users, isEmpty);
      expect(viewModel.successMessage, contains('berhasil dihapus'));
    });

    test('deleteUser gagal', () async {
      when(mockAuthService.deleteUser(dummyAdmin.uid))
          .thenThrow(Exception('Delete error'));

      final result = await viewModel.deleteUser(dummyAdmin.uid);

      expect(result, false);
      expect(viewModel.errorMessage, contains('Gagal menghapus pengguna'));
      expect(viewModel.users.length, 1);
    });
  });
}