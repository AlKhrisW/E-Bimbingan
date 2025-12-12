import 'package:flutter_test/flutter_test.dart';
import 'package:ebimbingan/data/services/firestore_service.dart';
import 'package:ebimbingan/data/models/user_model.dart';
import 'package:mockito/mockito.dart';


import '../../mocks.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;

  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDoc;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDoc;

  late FirestoreService firestoreService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();

    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDoc = MockDocumentReference<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQueryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

    firestoreService = FirestoreService.withInstance(mockFirestore);
  });

  group("FirestoreService - getUserData", () {
    test("mengambil user ketika data ada", () async {
      when(mockFirestore.collection("users"))
          .thenReturn(mockCollection);

      when(mockCollection.doc("123"))
          .thenReturn(mockDoc);

      when(mockDoc.get())
          .thenAnswer((_) async => mockDocSnapshot);

      when(mockDocSnapshot.exists).thenReturn(true);

      when(mockDocSnapshot.data()).thenReturn({
        "uid": "123",
        "name": "Afgan",
        "email": "a@a.com",
        "role": "mahasiswa"
      });

      final user = await firestoreService.getUserData("123");

      expect(user.uid, "123");
      expect(user.name, "Afgan");
      expect(user.role, "mahasiswa");
    });

    test("throw error ketika user tidak ada", () async {
      when(mockFirestore.collection("users"))
          .thenReturn(mockCollection);

      when(mockCollection.doc("123"))
          .thenReturn(mockDoc);

      when(mockDoc.get())
          .thenAnswer((_) async => mockDocSnapshot);

      when(mockDocSnapshot.exists).thenReturn(false);

      expect(() => firestoreService.getUserData("123"),
          throwsA(isA<String>()));
    });
  });

  group("FirestoreService - saveUserMetadata", () {
    test("berhasil menyimpan metadata user", () async {
      final user = UserModel(
        uid: "x1",
        name: "Afgan",
        email: "a@a.com",
        role: "admin",
      );

      when(mockFirestore.collection("users"))
          .thenReturn(mockCollection);

      when(mockCollection.doc("x1"))
          .thenReturn(mockDoc);

      when(mockDoc.set(any))
          .thenAnswer((_) async => null);

      await firestoreService.saveUserMetadata(user);

      verify(mockDoc.set(user.toMap())).called(1);
    });
  });

  group("FirestoreService - fetchDosenList", () {
    test("mengambil list dosen", () async {
      when(mockFirestore.collection("users"))
          .thenReturn(mockCollection);

      when(mockCollection.where("role", isEqualTo: "dosen"))
          .thenReturn(mockQuery);

      when(mockQuery.get())
          .thenAnswer((_) async => mockQuerySnapshot);

      when(mockQuerySnapshot.docs)
          .thenReturn([mockQueryDoc]);

      when(mockQueryDoc.data()).thenReturn({
        "uid": "d1",
        "name": "Dosen A",
        "email": "d@a.com",
        "role": "dosen"
      });

      final users = await firestoreService.fetchDosenList();

      expect(users.first.role, "dosen");
      expect(users.first.name, "Dosen A");
    });
  });

  group("FirestoreService - fetchMahasiswaList", () {
    test("mengambil list mahasiswa", () async {
      when(mockFirestore.collection("users"))
          .thenReturn(mockCollection);

      when(mockCollection.where("role", isEqualTo: "mahasiswa"))
          .thenReturn(mockQuery);

      when(mockQuery.get())
          .thenAnswer((_) async => mockQuerySnapshot);

      when(mockQuerySnapshot.docs)
          .thenReturn([mockQueryDoc]);

      when(mockQueryDoc.data()).thenReturn({
        "uid": "m1",
        "name": "Mahasiswa A",
        "email": "m@a.com",
        "role": "mahasiswa"
      });

      final users = await firestoreService.fetchMahasiswaList();

      expect(users.first.role, "mahasiswa");
    });
  });

  group("FirestoreService - updateUserMetadata", () {
    test("update metadata berhasil", () async {
      final user = UserModel(
        uid: "u1",
        name: "Afgan",
        email: "a@a.com",
        role: "admin",
      );

      when(mockFirestore.collection("users"))
          .thenReturn(mockCollection);

      when(mockCollection.doc("u1"))
          .thenReturn(mockDoc);

      when(mockDoc.update(any))
          .thenAnswer((_) async => null);

      await firestoreService.updateUserMetadata(user);

      verify(mockDoc.update(user.toMap())).called(1);
    });
  });

  group("FirestoreService - deleteUserMetadata", () {
    test("delete user berhasil", () async {
      when(mockFirestore.collection("users"))
          .thenReturn(mockCollection);

      when(mockCollection.doc("x1"))
          .thenReturn(mockDoc);

      when(mockDoc.delete())
          .thenAnswer((_) async => null);

      await firestoreService.deleteUserMetadata("x1");

      verify(mockDoc.delete()).called(1);
    });
  });
}
