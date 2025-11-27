# Dokumentasi Model dan Service (E-Bimbingan)

Dokumen ini menjelaskan struktur data utama (Model) dan lapisan logika interaksi dengan Firebase Firestore (Service) untuk fitur Logbook dan Bimbingan pada aplikasi E-Bimbingan.

---

## 1. Lapisan Model (`lib/data/models/`)

Model-model ini berfungsi sebagai blueprint (cetak biru) data yang disimpan dan diambil dari Firestore, memastikan integritas dan konsistensi tipe data.

### Model

| File Model                 | Deskripsi                                                               | Peran Utama                 | Keterkaitan Kunci |
|---------------------------|-------------------------------------------------------------------------|-----------------------------|------------------|
| `user_model.dart`         | Data dasar pengguna (Admin, Dosen, Mahasiswa).                          | Admin/Dosen/Mahasiswa       | Relasi: Digunakan untuk lookup nama Dosen/Mahasiswa menggunakan UID |
| `ajuan_bimbingan_model.dart`  | Melacak pengajuan dan persetujuan jadwal bimbingan (misal Kamis 10:00). | Mahasiswa & Dosen           | Status: proses, disetujui, ditolak |
| `log_bimbingan_model.dart`    | Laporan mingguan yang diisi mahasiswa setelah sesi bimbingan selesai. | Mahasiswa & Dosen           | Persetujuan Dosen → trigger verifikasi otomatis Logbook Harian |
| `logbook_harian_model.dart`   | Entri aktivitas harian pada masa magang.                              | Mahasiswa & Dosen           | Status: draft, verified, rejected |

---

## 2. Lapisan Service (`lib/data/services/`)

Service Layer bertindak sebagai jembatan antara ViewModel dan Firebase Firestore. Layer ini menangani semua operasi jaringan (CRUD) dan logika batching untuk efisiensi.

### 🔧 Tabel Service

| File Service                   | Koleksi Firestore | Fungsi Utama | Kaitan Logika |
|------------------------------|------------------|--------------|--------------|
| `ajuan_bimbingan_service.dart`   | `ajuan_bimbingan` | CRUD & Get Ajuan by Dosen | Berinteraksi dengan model AjuanBimbinganModel |
| `log_bimbingan_service.dart`     | `log_bimbingan` | CRUD & getPendingLogsByDosenUid | ViewModel memicu Batch Update pada Logbook Harian saat approved |
| `logbook_harian_service.dart`    | `logbook_harian` | CRUD & getLogbooksInDateRange | Memakai batchUpdateStatus untuk update banyak dokumen sekaligus |

---

## 3. Diagram Alur Persetujuan Kritikal (Log Bimbingan → Logbook Harian)

### 🔄 Alur Persetujuan Otomatis (Batch Write Workflow)

1. Mahasiswa submit Log Bimbingan Mingguan → status: `pending`
2. Dosen menekan tombol **Approve**
3. ViewModel (Log Bimbingan) menjalankan:
   - `LogbookHarianService.getLogbooksInDateRange(tgl_mulai, tgl_akhir)`
   - Menghasilkan `List<String> logbookUids`
   - Memanggil:  
     `LogbookHarianService.batchUpdateStatus(logbookUids, LogbookStatus.verified)`
4. Firestore melakukan update status Logbook Harian secara atomik (all-or-none)
5. Status Log Bimbingan diperbarui menjadi `approved`
6. Sistem menghitung kepatuhan 4x/bulan berdasarkan log mingguan


---
### notes

jujur, ane masih bingung dengan alur mahasiswa/dosen maunya bagaimana secara detail. jadi beberapa logic yang dibuat di sini masih mengikuti deskripsi sistem yang ada di:

https://docs.google.com/document/d/1nfL_GVvtGPvWYNcK-OIcwB85X1EFW8Z7r1eq42cSm8w/edit

nanti bisa disesuaikan dengan proses yang ada, antum yang lebih paham.

