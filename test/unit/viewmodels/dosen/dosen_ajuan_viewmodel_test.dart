import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/intl.dart';

// Import Models dan Enums
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/log_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/dosen_helper_ajuan.dart';

// ViewModels
import 'package:ebimbingan/features/dosen/viewmodels/ajuan_viewmodel.dart';

// Mocks
import '../../../mocks.mocks.dart';

// ====================================================================
// TEST DATA
// ====================================================================

final tDosenUid = 'dosen_uid_456';
final tMahasiswaUid1 = 'mhs_uid_1';
final tMahasiswaUid2 = 'mhs_uid_2';
final tAjuanId1 = 'ajuan_id_1';
final tAjuanId2 = 'ajuan_id_2';
final tNewLogId = 'log_id_generated';
final tErrorMessage = 'Gagal memproses data.';
final tKeteranganTolak = 'Jadwal bimbingan tidak tersedia.';

String mockLogIdGenerator() => tNewLogId;

final tDosenModel = UserModel(
  uid: tDosenUid,
  name: 'Dosen Pembimbing Test',
  email: 'dosen@test.com',
  role: 'dosen',
);

final tMahasiswaModel1 = UserModel(
  uid: tMahasiswaUid1,
  name: 'Mahasiswa Satu',
  email: 'mhs1@test.com',
  role: 'mahasiswa',
  dosenUid: tDosenUid,
  placement: 'Kantor Pusat',
);

final tMahasiswaModel2 = UserModel(
  uid: tMahasiswaUid2,
  name: 'Mahasiswa Dua',
  email: 'mhs2@test.com',
  role: 'mahasiswa',
  dosenUid: tDosenUid,
  placement: 'Kantor Cabang',
);

final tAjuan1_Proses = AjuanBimbinganModel(
  ajuanUid: tAjuanId1,
  mahasiswaUid: tMahasiswaUid1,
  dosenUid: tDosenUid,
  judulTopik: 'Topik 1 (Lama)',
  metodeBimbingan: 'Online',
  waktuBimbingan: '10:00',
  tanggalBimbingan: DateTime(2026, 1, 10),
  status: AjuanStatus.proses,
  waktuDiajukan: DateTime(2025, 12, 9, 10, 0, 0), // Lebih Lama
);

final tAjuan2_Proses = AjuanBimbinganModel(
  ajuanUid: tAjuanId2,
  mahasiswaUid: tMahasiswaUid2,
  dosenUid: tDosenUid,
  judulTopik: 'Topik 2 (Baru)',
  metodeBimbingan: 'Offline',
  waktuBimbingan: '14:00',
  tanggalBimbingan: DateTime(2026, 1, 11),
  status: AjuanStatus.proses,
  waktuDiajukan: DateTime(2025, 12, 9, 15, 0, 0), // Lebih Baru
);

// ====================================================================
// SETUP DAN GRUP TEST
// ====================================================================

void main() {
  late DosenAjuanViewModel viewModel;
  late MockAjuanBimbinganService mockAjuanService;
  late MockUserService mockUserService;
  late MockNotificationService mockNotifService;
  late MockAuthUtils mockAuthUtils;
  late MockLogBimbinganService mockLogService;

  setUp(() {
    mockAjuanService = MockAjuanBimbinganService();
    mockUserService = MockUserService();
    mockNotifService = MockNotificationService();
    mockAuthUtils = MockAuthUtils();
    mockLogService = MockLogBimbinganService();

    // 1. Setup AuthUtils default (berhasil)
    when(mockAuthUtils.currentUid).thenReturn(tDosenUid);

    // 2. Inisialisasi ViewModel dengan mocks
    viewModel = DosenAjuanViewModel.internal(
      ajuanService: mockAjuanService,
      logService: mockLogService,
      userService: mockUserService,
      notifService: mockNotifService,
      authUtils: mockAuthUtils,
      logIdGenerator: mockLogIdGenerator,
    );

    // 3. Mock default untuk service yang dipanggil saat setujui/tolak
    when(
      mockAjuanService.updateAjuanStatus(
        ajuanUid: anyNamed('ajuanUid'),
        status: anyNamed('status'),
        keterangan: anyNamed('keterangan'),
      ),
    ).thenAnswer((_) async => {});

    when(mockLogService.saveLogBimbingan(any)).thenAnswer((_) async => {});

    // Mocking semua named argument agar tidak error Bad State pada verify
    when(
      mockNotifService.sendNotification(
        recipientUid: anyNamed('recipientUid'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        type: anyNamed('type'),
        relatedId: anyNamed('relatedId'),
      ),
    ).thenAnswer((_) async => {});
  });

  // ====================================================================
  // TEST: _loadAjuanProses() - Dipanggil oleh refresh/list
  // ====================================================================

  group('loadAjuanProses', () {
    void setupSuccessfulLoad() {
      // 1. Ajuan Service mengembalikan 2 ajuan proses
      when(
        mockAjuanService.getAjuanByDosenUid(tDosenUid),
      ).thenAnswer((_) async => [tAjuan1_Proses, tAjuan2_Proses]);

      // 2. User Service mengembalikan detail Mahasiswa secara paralel
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid1),
      ).thenAnswer((_) async => tMahasiswaModel1);
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid2),
      ).thenAnswer((_) async => tMahasiswaModel2);
    }

    test(
      'harus memuat, menyatukan, dan mengurutkan ajuan (terbaru di atas)',
      () async {
        setupSuccessfulLoad();

        await viewModel.refresh(); // Panggil _loadAjuanProses()

        expect(viewModel.isLoading, false);
        expect(viewModel.error, null);
        expect(viewModel.daftarAjuan.length, 2);

        // Cek urutan (tAjuan2_Proses lebih baru dari tAjuan1_Proses)
        expect(viewModel.daftarAjuan[0].ajuan.ajuanUid, tAjuanId2);
        expect(viewModel.daftarAjuan[0].mahasiswa.name, tMahasiswaModel2.name);

        verify(mockAjuanService.getAjuanByDosenUid(tDosenUid)).called(1);
      },
    );

    test('harus set error jika currentUid null', () async {
      when(mockAuthUtils.currentUid).thenReturn(null);

      await viewModel.refresh();

      expect(viewModel.isLoading, false);
      expect(viewModel.error, "User belum login");
      expect(viewModel.daftarAjuan, isEmpty);
      verifyNever(mockAjuanService.getAjuanByDosenUid(any));
    });

    test('harus set error jika terjadi exception saat fetch data', () async {
      when(
        mockAjuanService.getAjuanByDosenUid(tDosenUid),
      ).thenThrow(Exception(tErrorMessage));

      await viewModel.refresh();

      expect(viewModel.isLoading, false);
      expect(viewModel.error, contains("Gagal memproses daftar ajuan"));
      expect(viewModel.daftarAjuan, isEmpty);
      verify(mockAjuanService.getAjuanByDosenUid(tDosenUid)).called(1);
    });
  });

  // ====================================================================
  // TEST: setujui()
  // ====================================================================

  group('setujui', () {
    final tSetujuiDate = tAjuan1_Proses.tanggalBimbingan;
    final tSetujuiDateStr = DateFormat('dd MMM').format(tSetujuiDate);

    // Setup: Buat ajuan tersedia di list sebelum test 'setujui' dipanggil
    setUp(() async {
      when(
        mockAjuanService.getAjuanByDosenUid(tDosenUid),
      ).thenAnswer((_) async => [tAjuan1_Proses]);
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid1),
      ).thenAnswer((_) async => tMahasiswaModel1);
      await viewModel.refresh(); // Isi list daftarAjuan
    });

    test(
      'harus mengubah status ajuan, membuat log bimbingan, dan mengirim notif',
      () async {
        // Mock data reload setelah setujui agar list kosong
        when(
          mockAjuanService.getAjuanByDosenUid(tDosenUid),
        ).thenAnswer((_) async => []);

        await viewModel.setujui(tAjuanId1);

        // 1. Verifikasi Status Ajuan diupdate
        verify(
          mockAjuanService.updateAjuanStatus(
            ajuanUid: tAjuanId1,
            status: AjuanStatus.disetujui,
            keterangan: null,
          ),
        ).called(1);

        // 2. Verifikasi Log Bimbingan dibuat
        verify(
          mockLogService.saveLogBimbingan(
            argThat(
              isA<LogBimbinganModel>()
                  .having((l) => l.ajuanUid, 'ajuanUid', tAjuanId1)
                  .having(
                    (l) => l.logBimbinganUid,
                    'logBimbinganUid',
                    tNewLogId,
                  ),
            ),
          ),
        ).called(1);

        // 3. Verifikasi Notifikasi dikirim (PERBAIKAN Mockito)
        verify(
          mockNotifService.sendNotification(
            recipientUid: tMahasiswaUid1,
            title: "Ajuan Bimbingan Disetujui",
            body: argThat(
              contains(tSetujuiDateStr),
              named: 'body',
            ), // ✅ Perbaikan
            type: "ajuan_status",
            relatedId: tAjuanId1,
          ),
        ).called(1);

        // 4. Verifikasi Reload
        verify(mockAjuanService.getAjuanByDosenUid(tDosenUid)).called(2);
      },
    );

    test(
      'harus gagal dan melempar exception jika update status gagal',
      () async {
        when(
          mockAjuanService.updateAjuanStatus(
            ajuanUid: tAjuanId1,
            status: AjuanStatus.disetujui,
          ),
        ).thenThrow(Exception('DB Ajuan Gagal'));

        // ✅ Perbaikan: Menghilangkan async/await pada expect(Future, throwsA)
        expect(viewModel.setujui(tAjuanId1), throwsA(isA<Exception>()));

        // Verifikasi error state di set
        await viewModel.setujui(tAjuanId1).catchError((_) {});
        expect(viewModel.error, contains('DB Ajuan Gagal'));

        // Verifikasi Mockito
        verifyNever(mockLogService.saveLogBimbingan(any));
      },
    );
  });

  // ====================================================================
  // TEST: tolak()
  // ====================================================================

  group('tolak', () {
    // Setup: Buat ajuan tersedia di list sebelum test 'tolak' dipanggil
    setUp(() async {
      when(
        mockAjuanService.getAjuanByDosenUid(tDosenUid),
      ).thenAnswer((_) async => [tAjuan1_Proses]);
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid1),
      ).thenAnswer((_) async => tMahasiswaModel1);
      await viewModel.refresh(); // Isi list daftarAjuan
    });

    test(
      'harus mengubah status ajuan menjadi ditolak dan mengirim notif',
      () async {
        // Mock data reload setelah tolak
        when(
          mockAjuanService.getAjuanByDosenUid(tDosenUid),
        ).thenAnswer((_) async => []);

        await viewModel.tolak(tAjuanId1, tKeteranganTolak);

        // 1. Verifikasi Status Ajuan diupdate
        verify(
          mockAjuanService.updateAjuanStatus(
            ajuanUid: tAjuanId1,
            status: AjuanStatus.ditolak,
            keterangan: tKeteranganTolak,
          ),
        ).called(1);

        // 2. Verifikasi Log Bimbingan TIDAK pernah dibuat
        verifyNever(mockLogService.saveLogBimbingan(any));

        // 3. Verifikasi Notifikasi dikirim (PERBAIKAN Mockito)
        verify(
          mockNotifService.sendNotification(
            recipientUid: tMahasiswaUid1,
            title: "Ajuan Bimbingan Ditolak",
            body: argThat(
              contains(tKeteranganTolak),
              named: 'body',
            ), // ✅ Perbaikan
            type: "ajuan_status",
            relatedId: tAjuanId1,
          ),
        ).called(1);

        // 4. Verifikasi Reload
        verify(mockAjuanService.getAjuanByDosenUid(tDosenUid)).called(2);
      },
    );

    test('harus gagal jika keterangan kosong', () async {
      // Clear data untuk reset error state
      viewModel.clearData();
      await viewModel.tolak(tAjuanId1, ' ');

      expect(viewModel.error, 'Keterangan penolakan wajib diisi');
      verifyNever(
        mockAjuanService.updateAjuanStatus(
          ajuanUid: anyNamed('ajuanUid'),
          status: anyNamed('status'),
          keterangan: anyNamed('keterangan'),
        ),
      );
    });

    test(
      'harus gagal dan melempar exception jika update status gagal',
      () async {
        when(
          mockAjuanService.updateAjuanStatus(
            ajuanUid: tAjuanId1,
            status: AjuanStatus.ditolak,
            keterangan: tKeteranganTolak,
          ),
        ).thenThrow(Exception('DB Ajuan Gagal'));

        // ✅ Perbaikan: Menghilangkan async/await pada expect(Future, throwsA)
        expect(
          viewModel.tolak(tAjuanId1, tKeteranganTolak),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  // ====================================================================
  // TEST: getAjuanDetail()
  // ====================================================================

  group('getAjuanDetail', () {
    test(
      'harus mengembalikan AjuanWithMahasiswa jika data ditemukan',
      () async {
        // Mock Ajuan Service
        when(
          mockAjuanService.getAjuanByUid(tAjuanId1),
        ).thenAnswer((_) async => tAjuan1_Proses);
        // Mock User Service
        when(
          mockUserService.fetchUserByUid(tMahasiswaUid1),
        ).thenAnswer((_) async => tMahasiswaModel1);

        final result = await viewModel.getAjuanDetail(tAjuanId1);

        expect(result, isNotNull);
        expect(result!.ajuan.ajuanUid, tAjuanId1);
        expect(result.mahasiswa.uid, tMahasiswaUid1);
        verify(mockAjuanService.getAjuanByUid(tAjuanId1)).called(1);
        verify(mockUserService.fetchUserByUid(tMahasiswaUid1)).called(1);
      },
    );

    test('harus mengembalikan null jika ajuan tidak ditemukan', () async {
      when(
        mockAjuanService.getAjuanByUid(tAjuanId1),
      ).thenAnswer((_) async => null);

      final result = await viewModel.getAjuanDetail(tAjuanId1);

      expect(result, null);
      verify(mockAjuanService.getAjuanByUid(tAjuanId1)).called(1);
      verifyNever(mockUserService.fetchUserByUid(any));
    });

    test('harus mengembalikan null jika terjadi error', () async {
      when(
        mockAjuanService.getAjuanByUid(tAjuanId1),
      ).thenThrow(Exception('Error Fetch'));

      final result = await viewModel.getAjuanDetail(tAjuanId1);

      expect(result, null);
    });
  });
}
