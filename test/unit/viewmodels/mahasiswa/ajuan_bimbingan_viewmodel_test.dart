// File: test/unit/viewmodels/mahasiswa/ajuan_bimbingan_viewmodel_test.dart

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import Mocks dan kelas-kelas Anda
import '../../../mocks.mocks.dart';
import 'package:ebimbingan/features/mahasiswa/viewmodels/ajuan_bimbingan_viewmodel.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:ebimbingan/data/models/ajuan_bimbingan_model.dart';

// =========================================================
// SETUP INJEKSI MOCK FIRESTORE (CLASS OVERRIDE)
// =========================================================
// Class ini harus mereplikasi bagaimana Anda meng-override getter firestoreInstance di ViewModel
class TestableAjuanBimbinganViewModel extends AjuanBimbinganViewModel {
  final FirebaseFirestore firestore;

  TestableAjuanBimbinganViewModel({required this.firestore});

  // Pastikan nama getter ini SAMA PERSIS dengan yang ada di ViewModel
  @override
  FirebaseFirestore get firestoreInstance => firestore;
}

// =========================================================
// DATA UJI
// =========================================================
final tMahasiswa = UserModel(
  uid: 'mhs_001',
  name: 'Budi Santoso',
  email: 'budi.s@email.com',
  role: 'mahasiswa',
  dosenUid: 'dsn_005',
);
final tMahasiswaNoDosen = UserModel(
  uid: 'mhs_002',
  name: 'Ani Dewi',
  email: 'ani.d@email.com',
  role: 'mahasiswa',
  dosenUid: null,
);
final tAjuanDataInput = {
  'judulTopik': 'Diskusi Bab 2',
  'metode': 'Online (Zoom)',
  'waktu': '14:00',
  'tanggal': DateTime(2026, 1, 10),
};
const tDosenName = 'Dr. Ir. Suryadi, M.Kom.';
final tAjuanMapBase = AjuanBimbinganModel(
  ajuanUid: 'ajuan999',
  mahasiswaUid: tMahasiswa.uid,
  dosenUid: tMahasiswa.dosenUid!,
  judulTopik: 'Test Topik',
  metodeBimbingan: 'Test Metode',
  waktuBimbingan: '11:00',
  tanggalBimbingan: DateTime(2026, 1, 1),
  status: AjuanStatus.proses,
  waktuDiajukan: DateTime.now(),
).toMap();

void main() {
  // Mock Objects
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockAjuanCollectionRef;
  late MockDocumentReference<Map<String, dynamic>> mockAjuanDocRef;
  late MockCollectionReference<Map<String, dynamic>> mockUserCollectionRef;

  // Mocks yang berbeda untuk DocumentSnapshot dan QueryDocumentSnapshot
  late MockDocumentSnapshot<Map<String, dynamic>> mockSingleDocSnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>>
  mockQueryDoc1; // ✅ Perbaikan A
  late MockQueryDocumentSnapshot<Map<String, dynamic>>
  mockQueryDoc2; // ✅ Perbaikan A

  late TestableAjuanBimbinganViewModel viewModel;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAjuanCollectionRef = MockCollectionReference();
    mockAjuanDocRef = MockDocumentReference();
    mockUserCollectionRef = MockCollectionReference();
    mockSingleDocSnapshot = MockDocumentSnapshot();
    mockQueryDoc1 = MockQueryDocumentSnapshot(); // ✅ Perbaikan A
    mockQueryDoc2 = MockQueryDocumentSnapshot(); // ✅ Perbaikan A

    // Setup umum
    when(mockFirestore.collection('ajuan_bimbingan')).thenReturn(
      mockAjuanCollectionRef as CollectionReference<Map<String, dynamic>>,
    );
    when(mockFirestore.collection('users')).thenReturn(
      mockUserCollectionRef as CollectionReference<Map<String, dynamic>>,
    );

    // Inisialisasi ViewModel dengan mock instance
    viewModel = TestableAjuanBimbinganViewModel(firestore: mockFirestore);
  });

  // ----------------------------------------------------
  // GROUP: SUBMIT AJUAN BIMBINGAN
  // ----------------------------------------------------
  group('submitAjuan', () {
    test(
      'POSITIF: Harus sukses dan mengembalikan null, serta memanggil add dan update Firestore',
      () async {
        // Setup mock untuk skenario sukses
        when(
          mockAjuanCollectionRef.add(any),
        ).thenAnswer((_) async => mockAjuanDocRef);
        when(mockAjuanDocRef.id).thenReturn('ajuan999');
        when(mockAjuanDocRef.update(any)).thenAnswer((_) async => null);

        // Panggil fungsi
        final future = viewModel.submitAjuan(
          user: tMahasiswa,
          judulTopik: tAjuanDataInput['judulTopik'] as String,
          metode: tAjuanDataInput['metode'] as String,
          waktu: tAjuanDataInput['waktu'] as String,
          tanggal: tAjuanDataInput['tanggal'] as DateTime,
        );

        // Verifikasi State Loading Awal (sebelum await)
        // ✅ Perbaikan: Menguji isLoading segera.
        expect(viewModel.isLoading, true);

        final result = await future;

        // Verifikasi Hasil dan State Akhir
        expect(result, null);
        expect(viewModel.isLoading, false);

        // Verifikasi Interaksi Firestore
        verify(mockAjuanCollectionRef.add(any)).called(1);
        verify(mockAjuanDocRef.update({'ajuanUid': 'ajuan999'})).called(1);
      },
    );

    test(
      'NEGATIF: Harus gagal dan mengembalikan pesan error jika mahasiswa belum punya dosen pembimbing',
      () async {
        // ... (tes ini tidak berinteraksi dengan firestore, jadi harusnya aman)
        final result = await viewModel.submitAjuan(
          user: tMahasiswaNoDosen,
          judulTopik: tAjuanDataInput['judulTopik'] as String,
          metode: tAjuanDataInput['metode'] as String,
          waktu: tAjuanDataInput['waktu'] as String,
          tanggal: tAjuanDataInput['tanggal'] as DateTime,
        );
        expect(result, 'Mahasiswa belum memiliki dosen pembimbing.');
        expect(viewModel.isLoading, false);
        verifyNever(mockAjuanCollectionRef.add(any));
      },
    );

    test(
      'NEGATIF: Harus gagal dan mengembalikan pesan error jika terjadi exception saat menyimpan data',
      () async {
        when(mockAjuanCollectionRef.add(any)).thenThrow(
          FirebaseException(
            plugin: 'firestore',
            code: 'permission-denied',
            message: 'Denied',
          ),
        );

        final result = await viewModel.submitAjuan(
          user: tMahasiswa,
          judulTopik: tAjuanDataInput['judulTopik'] as String,
          metode: tAjuanDataInput['metode'] as String,
          waktu: tAjuanDataInput['waktu'] as String,
          tanggal: tAjuanDataInput['tanggal'] as DateTime,
        );

        expect(result, startsWith('Gagal mengirim ajuan:'));
        expect(viewModel.isLoading, false);
      },
    );
  });

  // ----------------------------------------------------
  // GROUP: LOAD NAMA DOSEN
  // ----------------------------------------------------
  group('loadDosenName', () {
    const tDosenUid = 'dsn_005';

    setUp(() {
      when(
        mockUserCollectionRef.doc(tDosenUid),
      ).thenReturn(mockAjuanDocRef as DocumentReference<Map<String, dynamic>>);
    });

    test(
      'POSITIF: Harus sukses mengembalikan nama dosen dari field "name"',
      () async {
        // ✅ Perbaikan B: Setup doc.data() agar tidak null dan mengembalikan data
        when(
          mockAjuanDocRef.get(),
        ).thenAnswer((_) async => mockSingleDocSnapshot);
        when(mockSingleDocSnapshot.exists).thenReturn(true);
        when(
          mockSingleDocSnapshot.data(),
        ).thenReturn({'name': tDosenName}); // Data non-null

        final result = await viewModel.loadDosenName(tDosenUid);

        expect(result, tDosenName);
        verify(mockUserCollectionRef.doc(tDosenUid)).called(1);
      },
    );

    test(
      'NEGATIF: Harus mengembalikan "Dosen tidak ditemukan" jika snapshot.exists == false',
      () async {
        // ✅ Perbaikan B: Setup doc.data() agar mengembalikan data kosong saat exists=false
        when(
          mockAjuanDocRef.get(),
        ).thenAnswer((_) async => mockSingleDocSnapshot);
        when(mockSingleDocSnapshot.exists).thenReturn(false);
        // Penting: doc.data() harus mengembalikan null jika exists=false
        when(mockSingleDocSnapshot.data()).thenReturn(null);

        final result = await viewModel.loadDosenName(tDosenUid);

        expect(result, 'Dosen tidak ditemukan');
      },
    );

    test(
      'NEGATIF: Harus mengembalikan "Tidak ada dosen pembimbing" jika dosenUid kosong',
      () async {
        final result = await viewModel.loadDosenName('');
        expect(result, 'Tidak ada dosen pembimbing');
        verifyNever(mockUserCollectionRef.doc(any));
      },
    );
  });

  // ----------------------------------------------------
  // GROUP: GET RIWAYAT (STREAM)
  // ----------------------------------------------------
  group('getRiwayat', () {
    late MockQuery<Map<String, dynamic>> mockQuery;
    late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;

    setUp(() {
      mockQuery = MockQuery();
      mockQuerySnapshot = MockQuerySnapshot();

      // Mock setup: collection().where() -> mockQuery
      when(
        mockAjuanCollectionRef.where('mahasiswaUid', isEqualTo: tMahasiswa.uid),
      ).thenReturn(mockQuery as Query<Map<String, dynamic>>);

      // Mock setup: snapshots() -> mockStreamController
      final controller =
          StreamController<QuerySnapshot<Map<String, dynamic>>>();
      when(mockQuery.snapshots()).thenAnswer((_) => controller.stream);

      // Data Ajuan (ajuan2 memiliki tanggal terbaru)
      when(mockQueryDoc1.data()).thenReturn({
        ...tAjuanMapBase,
        'tanggalBimbingan': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      when(mockQueryDoc2.data()).thenReturn({
        ...tAjuanMapBase,
        'tanggalBimbingan': Timestamp.fromDate(DateTime(2026, 1, 15)),
      });
      when(mockQueryDoc1.id).thenReturn('ajuan1');
      when(mockQueryDoc2.id).thenReturn('ajuan2');

      // Memberikan data ke mock QuerySnapshot, menggunakan mock QueryDocumentSnapshot
      when(mockQuerySnapshot.docs).thenReturn(
        [mockQueryDoc1, mockQueryDoc2]
            as List<QueryDocumentSnapshot<Map<String, dynamic>>>,
      ); // ✅ Perbaikan C

      // Mengirim data ke stream
      controller.add(mockQuerySnapshot as QuerySnapshot<Map<String, dynamic>>);
      controller.close();
    });

    test(
      'POSITIF: Harus mengembalikan stream list ajuan yang terurut berdasarkan tanggal (terbaru di depan)',
      () async {
        final stream = viewModel.getRiwayat(tMahasiswa.uid!);

        await expectLater(
          stream,
          emits((list) {
            expect(list, isA<List<AjuanBimbinganModel>>());
            expect(list.length, 2);

            final AjuanBimbinganModel first = list[0];
            expect(first.tanggalBimbingan!.day, 15);

            return true;
          }),
        );
      },
    );

    test(
      'NEGATIF: Harus mengembalikan list kosong jika tidak ada data ajuan',
      () async {
        // Setup ulang untuk skenario kosong
        final controller =
            StreamController<QuerySnapshot<Map<String, dynamic>>>();
        when(mockQuery.snapshots()).thenAnswer((_) => controller.stream);
        when(mockQuerySnapshot.docs).thenReturn([]);
        controller.add(
          mockQuerySnapshot as QuerySnapshot<Map<String, dynamic>>,
        );
        controller.close();

        final stream = viewModel.getRiwayat(tMahasiswa.uid!);

        await expectLater(
          stream,
          emits((list) {
            expect(list, isEmpty);
            return true;
          }),
        );
      },
    );
  });
}
