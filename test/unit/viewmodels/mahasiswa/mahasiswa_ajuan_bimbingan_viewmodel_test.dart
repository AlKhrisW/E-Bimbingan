import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
import 'package:intl/intl.dart';

// Utils
// import 'package:ebimbingan/core/utils/auth_utils.dart'; // Import AuthUtils yang sudah diubah
// Models
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';
import 'package:ebimbingan/data/models/wrapper/mahasiswa_helper_ajuan.dart';
// ViewModels
import 'package:ebimbingan/features/mahasiswa/viewmodels/ajuan_bimbingan_viewmodel.dart';

// Mocks
import '../../../mocks.mocks.dart';
// Asumsi: MockServices, MockAuthUtils, dll., ada di file mocks.mocks.dart

// ====================================================================
// TEST DATA
// ====================================================================

final tMahasiswaUid = 'mhs_uid_123';
final tDosenUid = 'dosen_uid_456';
final tErrorMessage = 'Gagal mengambil data.';
final tAjuanId1 = 'ajuan_id_1';
final tAjuanId2 = 'ajuan_id_2';
final tNewAjuanId = 'new_ajuan_id_generated';

// Fungsi mock yang akan diinjeksikan untuk membuat ID (mengatasi error Firestore di test)
String mockIdGenerator() => tNewAjuanId;

final tMahasiswaModel = UserModel(
  uid: tMahasiswaUid,
  name: 'Mahasiswa Test',
  email: 'mhs@test.com',
  role: 'mahasiswa',
  dosenUid: tDosenUid, // Sudah punya dosen
);

final tMahasiswaNoDosenModel = UserModel(
  uid: tMahasiswaUid,
  name: 'Mahasiswa No Dosen',
  email: 'mhs_nodosen@test.com',
  role: 'mahasiswa',
  dosenUid: null, // Belum punya dosen
);

final tDosenModel = UserModel(
  uid: tDosenUid,
  name: 'Dosen Pembimbing Test',
  email: 'dosen@test.com',
  role: 'dosen',
);

final tAjuan1 = AjuanBimbinganModel(
  ajuanUid: tAjuanId1,
  mahasiswaUid: tMahasiswaUid,
  dosenUid: tDosenUid,
  judulTopik: 'Topik 1',
  metodeBimbingan: 'Online',
  waktuBimbingan: '10:00',
  tanggalBimbingan: DateTime(2025, 12, 10),
  status: AjuanStatus.proses,
  waktuDiajukan: DateTime(2025, 12, 9, 10, 0, 0),
);

final tAjuan2 = AjuanBimbinganModel(
  ajuanUid: tAjuanId2,
  mahasiswaUid: tMahasiswaUid,
  dosenUid: tDosenUid,
  judulTopik: 'Topik 2',
  metodeBimbingan: 'Offline',
  waktuBimbingan: '14:00',
  tanggalBimbingan: DateTime(2025, 12, 11),
  status: AjuanStatus.disetujui,
  waktuDiajukan: DateTime(2025, 12, 9, 15, 0, 0),
);

final tAjuanHelper1 = MahasiswaAjuanHelper(ajuan: tAjuan1, dosen: tDosenModel);
final tAjuanHelper2 = MahasiswaAjuanHelper(ajuan: tAjuan2, dosen: tDosenModel);

// ====================================================================
// SETUP DAN GRUP TEST
// ====================================================================

// @GenerateMocks([AuthUtils]) harus ada di file mocks anda!
void main() {
  late MahasiswaAjuanBimbinganViewModel viewModel;
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

    // Setup AuthUtils default (berhasil)
    when(mockAuthUtils.currentUid).thenReturn(tMahasiswaUid);

    // 🔥 Panggil constructor internal dengan SEMUA dependencies
    viewModel = MahasiswaAjuanBimbinganViewModel.internal(
      ajuanService: mockAjuanService,
      notifService: mockNotifService,
      userService: mockUserService,
      logService: mockLogService,
      authUtils: mockAuthUtils,
      idGenerator: mockIdGenerator, // Inject ID generator
    );
  });

  // ====================================================================
  // TEST: getDosenNameForCurrentUser()
  // ====================================================================

  group('getDosenNameForCurrentUser', () {
    test('harus mengembalikan nama dosen jika ada', () async {
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid),
      ).thenAnswer((_) async => tMahasiswaModel);
      when(
        mockUserService.fetchUserByUid(tDosenUid),
      ).thenAnswer((_) async => tDosenModel);

      final result = await viewModel.getDosenNameForCurrentUser();

      expect(result, tDosenModel.name);
      verify(mockUserService.fetchUserByUid(tMahasiswaUid)).called(1);
      verify(mockUserService.fetchUserByUid(tDosenUid)).called(1);
    });

    test('harus mengembalikan "Sesi berakhir" jika currentUid null', () async {
      when(mockAuthUtils.currentUid).thenReturn(null);

      final result = await viewModel.getDosenNameForCurrentUser();

      expect(result, "Sesi berakhir");
      verifyNever(mockUserService.fetchUserByUid(any));
    });

    test(
      'harus mengembalikan "Belum memiliki Dosen Pembimbing" jika dosenUid null',
      () async {
        when(
          mockUserService.fetchUserByUid(tMahasiswaUid),
        ).thenAnswer((_) async => tMahasiswaNoDosenModel);

        final result = await viewModel.getDosenNameForCurrentUser();

        expect(result, "Belum memiliki Dosen Pembimbing");
        verify(mockUserService.fetchUserByUid(tMahasiswaUid)).called(1);
        verifyNever(mockUserService.fetchUserByUid(tDosenUid));
      },
    );

    test(
      'harus mengembalikan "Gagal memuat info dosen" jika terjadi error',
      () async {
        when(
          mockUserService.fetchUserByUid(tMahasiswaUid),
        ).thenThrow(Exception('DB Error'));

        final result = await viewModel.getDosenNameForCurrentUser();

        expect(result, "Gagal memuat info dosen");
      },
    );
  });

  // ====================================================================
  // TEST: loadAjuanData()
  // ====================================================================

  group('loadAjuanData', () {
    void setupSuccessfulLoad() {
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid),
      ).thenAnswer((_) async => tMahasiswaModel);
      when(
        mockAjuanService.getAjuanByMahasiswaUid(tMahasiswaUid, tDosenUid),
      ).thenAnswer((_) async => [tAjuan1, tAjuan2]);
      when(
        mockUserService.fetchUserByUid(tDosenUid),
      ).thenAnswer((_) async => tDosenModel);
    }

    test(
      'harus memuat data ajuan, menyatukan, dan mengurutkan berdasarkan waktuDiajukan (terbaru di atas)',
      () async {
        setupSuccessfulLoad();

        await viewModel.loadAjuanData();

        // Cek state
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        expect(viewModel.filteredAjuans.length, 2);

        // Cek urutan (tAjuan2 lebih baru dari tAjuan1)
        expect(viewModel.filteredAjuans[0].ajuan.ajuanUid, tAjuanId2);
        expect(viewModel.filteredAjuans[1].ajuan.ajuanUid, tAjuanId1);

        verify(
          mockAjuanService.getAjuanByMahasiswaUid(tMahasiswaUid, tDosenUid),
        ).called(1);
        verify(mockUserService.fetchUserByUid(tDosenUid)).called(1);
      },
    );

    test('harus mengosongkan list jika tidak ada ajuan ditemukan', () async {
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid),
      ).thenAnswer((_) async => tMahasiswaModel);
      when(
        mockAjuanService.getAjuanByMahasiswaUid(tMahasiswaUid, tDosenUid),
      ).thenAnswer((_) async => []);

      await viewModel.loadAjuanData();

      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.filteredAjuans, isEmpty);
      verify(
        mockAjuanService.getAjuanByMahasiswaUid(tMahasiswaUid, tDosenUid),
      ).called(1);
      verifyNever(mockUserService.fetchUserByUid(tDosenUid));
    });

    test('harus set errorMessage jika currentUid null', () async {
      when(mockAuthUtils.currentUid).thenReturn(null);

      await viewModel.loadAjuanData();

      expect(viewModel.isLoading, false);
      expect(
        viewModel.errorMessage,
        "Sesi anda telah berakhir. Silakan login kembali.",
      );
      verifyNever(mockUserService.fetchUserByUid(any));
    });

    test(
      'harus set errorMessage jika terjadi exception saat fetch data',
      () async {
        when(
          mockUserService.fetchUserByUid(tMahasiswaUid),
        ).thenAnswer((_) async => tMahasiswaModel);
        when(
          mockAjuanService.getAjuanByMahasiswaUid(tMahasiswaUid, tDosenUid),
        ).thenThrow(Exception(tErrorMessage));

        await viewModel.loadAjuanData();

        expect(viewModel.isLoading, false);
        expect(viewModel.filteredAjuans, isEmpty);
        expect(viewModel.errorMessage, contains("Gagal memuat riwayat ajuan"));
        verify(
          mockAjuanService.getAjuanByMahasiswaUid(tMahasiswaUid, tDosenUid),
        ).called(1);
      },
    );
  });

  // ====================================================================
  // TEST: submitAjuan()
  // ====================================================================

  group('submitAjuan', () {
    final tJudul = 'Judul Topik Baru';
    final tMetode = 'Zoom';
    final tWaktu = '13:00';
    final tTanggal = DateTime(2025, 12, 12);
    final tDateStr = DateFormat('dd MMM').format(tTanggal);

    void setupSuccessfulSubmit() {
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid),
      ).thenAnswer((_) async => tMahasiswaModel);
      // Mock save Ajuan agar berhasil
      when(mockAjuanService.saveAjuan(any)).thenAnswer((_) async => {});
      // Mock loadData agar tidak error setelah submit (untuk reload data)
      when(
        mockAjuanService.getAjuanByMahasiswaUid(tMahasiswaUid, tDosenUid),
      ).thenAnswer((_) async => [tAjuan1, tAjuan2]);
      when(
        mockUserService.fetchUserByUid(tDosenUid),
      ).thenAnswer((_) async => tDosenModel);
    }

    test(
      'harus berhasil submit, memanggil service, mengirim notif, dan reload data',
      () async {
        setupSuccessfulSubmit();

        final result = await viewModel.submitAjuan(
          judulTopik: tJudul,
          metodeBimbingan: tMetode,
          waktuBimbingan: tWaktu,
          tanggalBimbingan: tTanggal,
        );

        // Cek hasil (Seharusnya TRUE sekarang)
        expect(result, true);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);

        // Verifikasi saveAjuan (menggunakan ID yang di-mock)
        verify(
          mockAjuanService.saveAjuan(
            argThat(
              isA<AjuanBimbinganModel>()
                  .having((a) => a.judulTopik, 'judulTopik', tJudul)
                  .having((a) => a.dosenUid, 'dosenUid', tDosenUid)
                  .having(
                    (a) => a.ajuanUid,
                    'ajuanUid',
                    tNewAjuanId,
                  ), // ID dari mock
            ),
          ),
        ).called(1);

        // Verifikasi Notifikasi (menggunakan ID yang di-mock)
        verify(
          mockNotifService.sendNotification(
            recipientUid: tDosenUid,
            title: "Ajuan Bimbingan Baru",
            body:
                "${tMahasiswaModel.name} mengajukan bimbingan untuk tanggal $tDateStr.",
            type: "ajuan_masuk",
            relatedId: tNewAjuanId, // ID dari mock
          ),
        ).called(1);

        // Verifikasi Reload Data
        verify(
          mockAjuanService.getAjuanByMahasiswaUid(tMahasiswaUid, tDosenUid),
        ).called(1);
      },
    );

    test('harus gagal submit jika currentUid null', () async {
      when(mockAuthUtils.currentUid).thenReturn(null);

      final result = await viewModel.submitAjuan(
        judulTopik: tJudul,
        metodeBimbingan: tMetode,
        waktuBimbingan: tWaktu,
        tanggalBimbingan: tTanggal,
      );

      expect(result, false);
      expect(viewModel.generalError, contains('Sesi berakhir'));

      verifyNever(mockUserService.fetchUserByUid(any));
    });

    test(
      'harus gagal submit jika mahasiswa belum punya dosen pembimbing',
      () async {
        when(
          mockUserService.fetchUserByUid(tMahasiswaUid),
        ).thenAnswer((_) async => tMahasiswaNoDosenModel);

        final result = await viewModel.submitAjuan(
          judulTopik: tJudul,
          metodeBimbingan: tMetode,
          waktuBimbingan: tWaktu,
          tanggalBimbingan: tTanggal,
        );

        expect(result, false);
        expect(
          viewModel
              .generalError, 
          contains("Anda belum memiliki Dosen Pembimbing."),
        );
        verifyNever(mockAjuanService.saveAjuan(any));
      },
    );

    test('harus gagal submit jika saveAjuan gagal (Exception)', () async {
      // Setup untuk skenario ini
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid),
      ).thenAnswer((_) async => tMahasiswaModel);
      // 🔥 Mock saveAjuan untuk melempar error
      when(mockAjuanService.saveAjuan(any)).thenThrow(Exception(tErrorMessage));

      final result = await viewModel.submitAjuan(
        judulTopik: tJudul,
        metodeBimbingan: tMetode,
        waktuBimbingan: tWaktu,
        tanggalBimbingan: tTanggal,
      );

      expect(result, false);
      expect(viewModel.errorMessage, contains("Gagal mengirim ajuan"));

      // Verifikasi bahwa saveAjuan DIPANGGIL sekali
      verify(mockAjuanService.saveAjuan(any)).called(1);
      // Verifikasi notif TIDAK PERNAH dikirim
      verifyNever(
        mockNotifService.sendNotification(
          recipientUid: anyNamed('recipientUid'),
          title: anyNamed('title'),
          body: anyNamed('body'),
          type: anyNamed('type'),
          relatedId: anyNamed('relatedId'),
        ),
      );
    });
  });

  // ====================================================================
  // TEST: getAjuanDetail()
  // ====================================================================

  group('getAjuanDetail', () {
    test(
      'harus mengembalikan MahasiswaAjuanHelper jika data ditemukan',
      () async {
        when(
          mockAjuanService.getAjuanByUid(tAjuanId1),
        ).thenAnswer((_) async => tAjuan1);
        when(
          mockUserService.fetchUserByUid(tDosenUid),
        ).thenAnswer((_) async => tDosenModel);

        final result = await viewModel.getAjuanDetail(tAjuanId1);

        expect(result, isNotNull);
        expect(result!.ajuan.ajuanUid, tAjuanId1);
        expect(result.dosen.uid, tDosenUid);
        verify(mockAjuanService.getAjuanByUid(tAjuanId1)).called(1);
        verify(mockUserService.fetchUserByUid(tDosenUid)).called(1);
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

  // ====================================================================
  // TEST: setFilter() dan filteredAjuans
  // ====================================================================

  group('Filtering and State Management', () {
    setUp(() async {
      // Setup data awal (diperlukan load data agar _allAjuans terisi)
      when(
        mockUserService.fetchUserByUid(tMahasiswaUid),
      ).thenAnswer((_) async => tMahasiswaModel);
      when(
        mockAjuanService.getAjuanByMahasiswaUid(tMahasiswaUid, tDosenUid),
      ).thenAnswer((_) async => [tAjuan1, tAjuan2]);
      when(
        mockUserService.fetchUserByUid(tDosenUid),
      ).thenAnswer((_) async => tDosenModel);

      await viewModel.loadAjuanData(); // Isi _allAjuans
    });

    test(
      'filteredAjuans harus mengembalikan semua ajuan jika activeFilter null',
      () async {
        viewModel.setFilter(null);

        expect(viewModel.activeFilter, null);
        expect(viewModel.filteredAjuans.length, 2);
      },
    );

    test('filteredAjuans harus memfilter hanya status.proses', () async {
      viewModel.setFilter(AjuanStatus.proses); // tAjuan1

      expect(viewModel.activeFilter, AjuanStatus.proses);
      expect(viewModel.filteredAjuans.length, 1);
      expect(viewModel.filteredAjuans[0].ajuan.status, AjuanStatus.proses);
      expect(viewModel.filteredAjuans[0].ajuan.ajuanUid, tAjuanId1);
    });

    test('filteredAjuans harus memfilter hanya status.disetujui', () async {
      viewModel.setFilter(
        AjuanStatus.disetujui,
      ); // tAjuan2 (Asumsi AjuanStatus.disetujui adalah enum yang benar)

      expect(viewModel.activeFilter, AjuanStatus.disetujui);
      expect(viewModel.filteredAjuans.length, 1);
      expect(viewModel.filteredAjuans[0].ajuan.status, AjuanStatus.disetujui);
      expect(viewModel.filteredAjuans[0].ajuan.ajuanUid, tAjuanId2);
    });

    test('clearData harus me-reset semua state', () {
      // Setup state non-default
      viewModel.setFilter(AjuanStatus.proses);
      // Data sudah dimuat di setUp async
      // viewModel.isLoading = true; // Tidak perlu karena clearData akan mereset

      viewModel.clearData();

      expect(viewModel.activeFilter, null);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.filteredAjuans, isEmpty);
    });
  });
}
