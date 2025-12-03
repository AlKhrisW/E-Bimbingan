import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ebimbingan/features/admin/viewmodels/mapping/detail_mapping_vm.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import '../../../mocks.mocks.dart';

void main() {
  late MockUserService mockUserService;
  late DetailMappingViewModel viewModel;

  // // Dummy data
  // final dummyDosen = UserModel(
  //   uid: 'uid-dosen-1',
  //   name: 'Dosen Test',
  //   email: 'dosen@test.com',
  //   role: 'dosen',
  //   phoneNumber: '08129876543',
  //   nip: '123456',
  //   jabatan: 'Lektor',
  // );

  final dummyMahasiswa1 = UserModel(
    uid: 'uid-mhs-1',
    name: 'Mahasiswa 1',
    email: 'mhs1@test.com',
    role: 'mahasiswa',
    phoneNumber: '08121234567',
    nim: '111111',
    programStudi: 'Teknik Informatika',
    placement: 'PT. ABC',
    startDate: DateTime(2025, 1, 1),
    dosenUid: 'uid-dosen-1',
  );

  final dummyMahasiswa2 = UserModel(
    uid: 'uid-mhs-2',
    name: 'Mahasiswa 2',
    email: 'mhs2@test.com',
    role: 'mahasiswa',
    phoneNumber: '08121234568',
    nim: '222222',
    programStudi: 'Teknik Informatika',
    placement: 'PT. XYZ',
    startDate: DateTime(2025, 1, 1),
    dosenUid: 'uid-dosen-1',
  );

  final dummyMahasiswaUnassigned = UserModel(
    uid: 'uid-mhs-unassigned',
    name: 'Mahasiswa Unassigned',
    email: 'mhs.unassigned@test.com',
    role: 'mahasiswa',
    phoneNumber: '08121234569',
    nim: '333333',
    programStudi: 'Teknik Informatika',
    placement: 'PT. DEF',
    startDate: DateTime(2025, 1, 1),
    dosenUid: null, // belum ter-mapping
  );

  setUp(() {
    mockUserService = MockUserService();
    viewModel = DetailMappingViewModel(
      userService: mockUserService, // ✅ Inject mock service
    );
  });

  group('LOAD MAPPED MAHASISWA', () {
    test('loadMappedMahasiswa berhasil', () async {
      when(mockUserService.fetchMahasiswaByDosenUid('uid-dosen-1'))
          .thenAnswer((_) async => [dummyMahasiswa1, dummyMahasiswa2]);

      await viewModel.loadMappedMahasiswa('uid-dosen-1');

      expect(viewModel.isLoading, false);
      expect(viewModel.mappedMahasiswa.length, 2);
      expect(viewModel.mappedMahasiswa.first.uid, 'uid-mhs-1');
      expect(viewModel.mappedMahasiswa.last.uid, 'uid-mhs-2');
      expect(viewModel.errorMessage, null);
    });

    test('loadMappedMahasiswa gagal', () async {
      when(mockUserService.fetchMahasiswaByDosenUid('uid-dosen-1'))
          .thenThrow(Exception('Network Error'));

      await viewModel.loadMappedMahasiswa('uid-dosen-1');

      expect(viewModel.isLoading, false);
      expect(viewModel.mappedMahasiswa, isEmpty);
      expect(viewModel.errorMessage, contains('Gagal memuat mahasiswa bimbingan'));
    });

    test('loadMappedMahasiswa dengan list kosong', () async {
      when(mockUserService.fetchMahasiswaByDosenUid('uid-dosen-1'))
          .thenAnswer((_) async => []);

      await viewModel.loadMappedMahasiswa('uid-dosen-1');

      expect(viewModel.isLoading, false);
      expect(viewModel.mappedMahasiswa, isEmpty);
      expect(viewModel.errorMessage, null);
    });
  });

  group('LOAD UNASSIGNED MAHASISWA', () {
    test('loadUnassignedMahasiswa berhasil', () async {
      when(mockUserService.fetchMahasiswaUnassigned())
          .thenAnswer((_) async => [dummyMahasiswaUnassigned]);

      await viewModel.loadUnassignedMahasiswa();

      expect(viewModel.unassignedMahasiswa.length, 1);
      expect(viewModel.unassignedMahasiswa.first.dosenUid, null);
      expect(viewModel.unassignedMahasiswa.first.uid, 'uid-mhs-unassigned');
      expect(viewModel.errorMessage, null);
    });

    test('loadUnassignedMahasiswa gagal', () async {
      when(mockUserService.fetchMahasiswaUnassigned())
          .thenThrow(Exception('Firestore Error'));

      await viewModel.loadUnassignedMahasiswa();

      expect(viewModel.unassignedMahasiswa, isEmpty);
      expect(viewModel.errorMessage,
          contains('Gagal memuat daftar mahasiswa yang belum ter-mapping'));
    });

    test('loadUnassignedMahasiswa dengan list kosong', () async {
      when(mockUserService.fetchMahasiswaUnassigned())
          .thenAnswer((_) async => []);

      await viewModel.loadUnassignedMahasiswa();

      expect(viewModel.unassignedMahasiswa, isEmpty);
      expect(viewModel.errorMessage, null);
    });
  });

  group('REMOVE MAPPING', () {
    setUp(() {
      // Set initial mapped mahasiswa
      viewModel.mappedMahasiswa = [dummyMahasiswa1, dummyMahasiswa2];
    });

    test('removeMapping berhasil', () async {
      when(mockUserService.updateUserMetadataPartial(
        'uid-mhs-1',
        {'dosen_uid': null},
      )).thenAnswer((_) async {});

      final result = await viewModel.removeMapping('uid-mhs-1', 'uid-dosen-1');

      expect(result, true);
      expect(viewModel.mappedMahasiswa.length, 1);
      expect(viewModel.mappedMahasiswa.first.uid, 'uid-mhs-2');
      expect(viewModel.successMessage, contains('berhasil dihapus'));
      expect(viewModel.errorMessage, null);
      expect(viewModel.isLoading, false);
    });

    test('removeMapping gagal', () async {
      when(mockUserService.updateUserMetadataPartial(
        'uid-mhs-1',
        {'dosen_uid': null},
      )).thenThrow(Exception('Update Failed'));

      final result = await viewModel.removeMapping('uid-mhs-1', 'uid-dosen-1');

      expect(result, false);
      expect(viewModel.mappedMahasiswa.length, 2); // tidak berubah
      expect(viewModel.errorMessage, contains('Gagal menghapus relasi'));
      expect(viewModel.successMessage, null);
      expect(viewModel.isLoading, false);
    });

    test('removeMapping mahasiswa yang tidak ada dalam list', () async {
      when(mockUserService.updateUserMetadataPartial(
        'uid-mhs-99',
        {'dosen_uid': null},
      )).thenAnswer((_) async {});

      final result = await viewModel.removeMapping('uid-mhs-99', 'uid-dosen-1');

      expect(result, true);
      expect(viewModel.mappedMahasiswa.length, 2); // tetap 2
      expect(viewModel.successMessage, contains('berhasil dihapus'));
    });
  });

  group('ADD MAPPING', () {
    test('addMapping berhasil untuk 1 mahasiswa', () async {
      final mahasiswaUids = ['uid-mhs-unassigned'];

      when(mockUserService.batchUpdateDosenRelasi(
        mahasiswaUids: mahasiswaUids,
        newDosenUid: 'uid-dosen-1',
      )).thenAnswer((_) async {});

      when(mockUserService.fetchMahasiswaByDosenUid('uid-dosen-1'))
          .thenAnswer((_) async => [dummyMahasiswa1, dummyMahasiswaUnassigned]);

      final result = await viewModel.addMapping(mahasiswaUids, 'uid-dosen-1');

      expect(result, true);
      expect(viewModel.mappedMahasiswa.length, 2);
      expect(viewModel.successMessage, contains('1 mahasiswa berhasil ditambahkan'));
      expect(viewModel.errorMessage, null);
      expect(viewModel.isLoading, false);
    });

    test('addMapping berhasil untuk multiple mahasiswa', () async {
      final mahasiswaUids = ['uid-mhs-3', 'uid-mhs-4', 'uid-mhs-5'];

      final newMahasiswa3 = UserModel(
        uid: 'uid-mhs-3',
        name: 'Mahasiswa 3',
        email: 'mhs3@test.com',
        role: 'mahasiswa',
        phoneNumber: '08121234570',
        nim: '444444',
        programStudi: 'Teknik Informatika',
        dosenUid: 'uid-dosen-1',
      );

      final newMahasiswa4 = UserModel(
        uid: 'uid-mhs-4',
        name: 'Mahasiswa 4',
        email: 'mhs4@test.com',
        role: 'mahasiswa',
        phoneNumber: '08121234571',
        nim: '555555',
        programStudi: 'Teknik Informatika',
        dosenUid: 'uid-dosen-1',
      );

      final newMahasiswa5 = UserModel(
        uid: 'uid-mhs-5',
        name: 'Mahasiswa 5',
        email: 'mhs5@test.com',
        role: 'mahasiswa',
        phoneNumber: '08121234572',
        nim: '666666',
        programStudi: 'Teknik Informatika',
        dosenUid: 'uid-dosen-1',
      );

      when(mockUserService.batchUpdateDosenRelasi(
        mahasiswaUids: mahasiswaUids,
        newDosenUid: 'uid-dosen-1',
      )).thenAnswer((_) async {});

      when(mockUserService.fetchMahasiswaByDosenUid('uid-dosen-1'))
          .thenAnswer((_) async => [
                dummyMahasiswa1,
                dummyMahasiswa2,
                newMahasiswa3,
                newMahasiswa4,
                newMahasiswa5,
              ]);

      final result = await viewModel.addMapping(mahasiswaUids, 'uid-dosen-1');

      expect(result, true);
      expect(viewModel.mappedMahasiswa.length, 5);
      expect(viewModel.successMessage, contains('3 mahasiswa berhasil ditambahkan'));
      expect(viewModel.errorMessage, null);
      expect(viewModel.isLoading, false);
    });

    test('addMapping gagal', () async {
      final mahasiswaUids = ['uid-mhs-unassigned'];

      when(mockUserService.batchUpdateDosenRelasi(
        mahasiswaUids: mahasiswaUids,
        newDosenUid: 'uid-dosen-1',
      )).thenThrow(Exception('Batch Update Failed'));

      final result = await viewModel.addMapping(mahasiswaUids, 'uid-dosen-1');

      expect(result, false);
      expect(viewModel.errorMessage, contains('Gagal menambahkan relasi mapping'));
      expect(viewModel.successMessage, null);
      expect(viewModel.isLoading, false);
    });

    test('addMapping dengan list kosong', () async {
      final mahasiswaUids = <String>[];

      when(mockUserService.batchUpdateDosenRelasi(
        mahasiswaUids: mahasiswaUids,
        newDosenUid: 'uid-dosen-1',
      )).thenAnswer((_) async {});

      when(mockUserService.fetchMahasiswaByDosenUid('uid-dosen-1'))
          .thenAnswer((_) async => [dummyMahasiswa1]);

      final result = await viewModel.addMapping(mahasiswaUids, 'uid-dosen-1');

      expect(result, true);
      expect(viewModel.successMessage, contains('0 mahasiswa berhasil ditambahkan'));
    });
  });

  group('RESET MESSAGES', () {
    test('resetMessages menghapus error dan success message', () {
      // Manually set messages (in real scenario, they're set by methods)
      viewModel.loadMappedMahasiswa('invalid-uid');

      viewModel.resetMessages();

      expect(viewModel.errorMessage, null);
      expect(viewModel.successMessage, null);
    });
  });

  group('STATE MANAGEMENT', () {
    test('state awal viewmodel benar', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.successMessage, null);
      expect(viewModel.mappedMahasiswa, isEmpty);
      expect(viewModel.unassignedMahasiswa, isEmpty);
    });

    test('messages di-reset sebelum operasi baru', () async {
      // Set messages dari operasi sebelumnya
      when(mockUserService.fetchMahasiswaByDosenUid('uid-dosen-1'))
          .thenThrow(Exception('First Error'));

      await viewModel.loadMappedMahasiswa('uid-dosen-1');
      expect(viewModel.errorMessage, isNotNull);

      // Operasi baru harus reset messages
      when(mockUserService.fetchMahasiswaByDosenUid('uid-dosen-1'))
          .thenAnswer((_) async => [dummyMahasiswa1]);

      await viewModel.loadMappedMahasiswa('uid-dosen-1');
      expect(viewModel.errorMessage, null);
      expect(viewModel.successMessage, null);
    });
  });
}