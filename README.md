# E-Bimbingan - Aplikasi Mobile Bimbingan Magang Mahasiswa

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-green)](https://www.android.com)

## 📋 Deskripsi Aplikasi

**E-Bimbingan** adalah aplikasi mobile berbasis Flutter yang dirancang untuk mengelola seluruh proses bimbingan magang mahasiswa secara digital, real-time, dan terstruktur. Aplikasi ini menggantikan proses manual seperti pencatatan log book di kertas, konfirmasi jadwal melalui chat pribadi, serta bimbingan yang tidak terdokumentasi dengan baik.

### Latar Belakang

Permasalahan yang sering terjadi dalam sistem bimbingan magang konvensional:
- **Tidak Ada Bukti Bimbingan yang Valid**: Diskusi melalui WhatsApp sering hilang atau tertumpuk dengan obrolan lain
- **Sulitnya Pemantauan**: Program studi sulit memantau progres bimbingan mahasiswa secara real-time
- **Potensi Kehilangan Data**: Buku logbook fisik rentan hilang atau rusak
- **Proses Validasi yang Lambat**: Pemberian ACC kegiatan sering tertunda karena menunggu pertemuan tatap muka

### Tujuan Pengembangan

- Meningkatkan efisiensi proses bimbingan magang mahasiswa
- Menciptakan dokumentasi aktivitas magang (log harian dan log bimbingan) secara digital dan terorganisir
- Mempermudah mahasiswa dalam mengisi logbook, melakukan bimbingan, dan memantau progres
- Mengurangi kesalahan dan ketidakteraturan dalam pencatatan data bimbingan
- Memudahkan dosen dalam melakukan monitoring dan verifikasi aktivitas bimbingan mahasiswa
- Mempercepat proses administrasi magang dengan mengurangi kegiatan manual

### Fungsi Utama Aplikasi

1. **Pencatatan Digital**: Mahasiswa mengisi kegiatan harian dan mingguan langsung di aplikasi
2. **Rekam Jejak Bimbingan**: Semua revisi dan masukan dosen tercatat di sistem sebagai bukti valid
3. **Validasi Online**: Dosen dapat menyetujui logbook mahasiswa secara langsung tanpa perlu bertemu fisik
4. **Monitoring Real-time**: Pihak kampus dapat melihat progres mahasiswa secara transparan
5. **Notifikasi Otomatis**: Sistem memberikan pengingat dan notifikasi terkait status bimbingan

---

## 🛠️ Teknologi yang Digunakan

### Framework & Bahasa Pemrograman
- **Flutter** (Dart) - Framework pengembangan aplikasi mobile cross-platform
- **Dart** - Bahasa pemrograman untuk Flutter

### Backend & Database
- **Firebase Authentication** - Autentikasi pengguna dan manajemen akun (login multi-role)
- **Firebase Firestore** - Database NoSQL real-time untuk menyimpan data pengguna, logbook, dan bimbingan
- **Firebase Cloud Storage** - Penyimpanan file pendukung (dokumen, lampiran logbook)
- **Firebase Cloud Messaging (FCM)** - Notifikasi push real-time

### Arsitektur Aplikasi
- **MVVM (Model-View-ViewModel)** - Arsitektur untuk pemisahan logika bisnis dan tampilan UI
- **Provider/State Management** - Pengelolaan state aplikasi

### Tools Pengembangan
- **Visual Studio Code / Android Studio** - IDE pengembangan
- **Git & GitHub** - Version control system
- **Figma** - Desain UI/UX

### Platform
- **Android Only** (Android 10 ke atas)
- Aplikasi saat ini hanya tersedia untuk platform Android

---

## 📁 Struktur Folder Proyek

```
lib/
├── core/                          # Core utilities dan konstanta
│   ├── constants/                 # Konstanta aplikasi (warna, ukuran, dll)
│   ├── themes/                    # Tema dan styling global
│   ├── utils/                     # Utility functions
│   │   └── navigation/            # Helper navigasi
│   └── widgets/                   # Reusable widgets
│       ├── accordion/
│       ├── appbar/
│       └── status_card/
│
├── data/                          # Layer data (Model & Services)
│   ├── models/                    # Data models (User, Ajuan, Logbook, dll)
│   │   └── wrapper/               # Model wrapper untuk data kompleks
│   └── services/                  # Services untuk Firebase (Auth, Firestore, Storage)
│
├── features/                      # Fitur aplikasi berdasarkan role
│   ├── admin/                     # Modul Admin
│   │   ├── navigation/
│   │   ├── viewmodels/            # Business logic (Dashboard, Mapping)
│   │   ├── views/                 # UI screens
│   │   └── widgets/               # Komponen UI khusus admin
│   │
│   ├── auth/                      # Modul Autentikasi
│   │   ├── viewmodels/
│   │   ├── views/
│   │   └── widgets/
│   │
│   ├── dosen/                     # Modul Dosen Pembimbing
│   │   ├── navigation/
│   │   ├── viewmodels/
│   │   ├── views/
│   │   │   ├── ajuan/             # Validasi ajuan bimbingan
│   │   │   ├── dashboard/
│   │   │   ├── log_bimbingan/     # Validasi log bimbingan
│   │   │   ├── log_harian/        # Monitoring log harian
│   │   │   └── profile/
│   │   └── widgets/
│   │
│   ├── mahasiswa/                 # Modul Mahasiswa
│   │   ├── navigation/
│   │   ├── viewmodels/
│   │   ├── views/
│   │   │   ├── ajuanBimbingan/
│   │   │   ├── dashboard/
│   │   │   ├── logHarian/
│   │   │   ├── logMingguan/
│   │   │   └── profil/
│   │   └── widgets/
│   │
│   └── notifikasi/                # Modul Notifikasi
│       ├── viewmodels/
│       ├── views/
│       └── widgets/
│
└── routes/                        # Routing dan navigasi aplikasi
```

### Penjelasan Arsitektur MVVM

**E-Bimbingan** menggunakan arsitektur **MVVM (Model-View-ViewModel)** untuk memisahkan logika bisnis dari tampilan UI:

- **Model** (`data/models/`): Representasi data aplikasi (User, Ajuan, Logbook)
- **View** (`features/*/views/`): Tampilan UI yang berinteraksi dengan pengguna
- **ViewModel** (`features/*/viewmodels/`): Logic bisnis dan state management yang menghubungkan Model dan View
- **Services** (`data/services/`): Layer komunikasi dengan Firebase (Auth, Firestore, Storage)

---

## ⚙️ Persyaratan Sistem

### Untuk Developer (Pengembangan Aplikasi)

**Development Environment:**
- **Flutter SDK**: versi 3.0.0 atau lebih baru
- **Dart SDK**: versi 2.17.0 atau lebih baru
- **Android Studio** / **VS Code** dengan plugin Flutter
- **Git** untuk version control
- **Akun Firebase** (untuk konfigurasi backend)

**Build & Deployment:**
- **Android SDK**: API Level 29 (Android 10) atau lebih tinggi
- **Java JDK**: versi 11 atau lebih baru

### Untuk End-User (Pengguna Aplikasi)

**Persyaratan Perangkat Android:**
- **OS Android**: Android 10 (API 29) atau lebih tinggi
- **RAM**: Minimal 2GB (disarankan 4GB untuk performa optimal)
- **Storage**: Minimal 100MB ruang kosong untuk instalasi aplikasi
- **Koneksi Internet**: Diperlukan untuk sinkronisasi data real-time dengan Firebase
- **Izin Aplikasi**: 
  - Akses Internet
  - Akses Storage (untuk upload lampiran)
  - Notifikasi (untuk menerima pemberitahuan)

---

## 🚀 Instalasi untuk Developer

### 1. Clone Repository

```bash
git clone https://github.com/AlKhrisW/E-Bimbingan.git
cd E-Bimbingan
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Konfigurasi Firebase

#### a. Setup Firebase Project
1. Buat project baru di [Firebase Console](https://console.firebase.google.com/)
2. Aktifkan **Firebase Authentication** (Email/Password)
3. Buat **Firestore Database** (mode production atau test)
4. Aktifkan **Firebase Cloud Messaging**

#### b. Download Konfigurasi File
- **Android**: Download `google-services.json` dan letakkan di `android/app/`

#### c. Konfigurasi Firebase di Flutter
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Konfigurasi Firebase untuk aplikasi
flutterfire configure
```

### 4. Setup Firestore Security Rules

Upload security rules berikut ke Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - role-based access
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Ajuan Bimbingan - mahasiswa & dosen
    match /ajuanBimbingan/{ajuanId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.mahasiswaUid == request.auth.uid;
      allow update: if request.auth != null;
    }
    
    // Logbook - mahasiswa & dosen
    match /logbook/{logId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Build APK

```bash
# Build APK Release
flutter build apk --release

# Hasil build ada di: build/app/outputs/flutter-apk/app-release.apk
```

### 6. Testing (Opsional)

```bash
# Unit Test
flutter test

# Integration Test (E2E) - untuk Windows
flutter test integration_test -d windows
```

---

## 📲 Instalasi untuk End-User (Pengguna Aplikasi)

Aplikasi E-Bimbingan saat ini tersedia dalam format **APK** yang dapat diunduh dan diinstal secara manual di perangkat Android.

### Langkah-Langkah Instalasi

#### 1. Download File APK

**Download aplikasi dari Google Drive:**
- Link Download: [https://drive.google.com/drive/u/0/mobile/folders/1LQ7RpLsoowABtOHR8_8xAcVreSotNxrl?usp=drive_link](https://drive.google.com/drive/u/0/mobile/folders/1LQ7RpLsoowABtOHR8_8xAcVreSotNxrl?usp=drive_link)
- File yang diunduh: `app-release.apk` atau `e-bimbingan.apk`

#### 2. Aktifkan Instalasi dari Sumber Tidak Dikenal

Sebelum menginstal APK, pastikan perangkat Android Anda mengizinkan instalasi dari sumber tidak dikenal:

**Untuk Android 10 ke atas:**
1. Buka **Settings** (Pengaturan)
2. Pilih **Security** atau **Biometric and security**
3. Aktifkan opsi **Install unknown apps** atau **Install from unknown sources**
4. Pilih browser atau file manager yang digunakan untuk download
5. Izinkan instalasi dari aplikasi tersebut

**Alternatif (saat instalasi):**
- Ketika Anda membuka file APK, sistem akan meminta izin untuk menginstal
- Tap **Settings** pada notifikasi yang muncul
- Aktifkan toggle **Allow from this source**

#### 3. Install Aplikasi

1. Buka **File Manager** atau folder **Downloads** di perangkat Android
2. Temukan file `app-release.apk` atau `e-bimbingan.apk`
3. Tap file APK tersebut
4. Tap tombol **Install**
5. Tunggu hingga proses instalasi selesai (biasanya 10-30 detik)
6. Tap **Open** untuk langsung membuka aplikasi, atau **Done** untuk selesai

#### 4. Berikan Izin Aplikasi

Saat pertama kali membuka aplikasi, sistem akan meminta beberapa izin:
- **Akses Internet**: Diperlukan untuk sinkronisasi data dengan server
- **Akses Storage**: Diperlukan untuk upload lampiran logbook
- **Notifikasi**: Diperlukan untuk menerima pemberitahuan bimbingan

**Tap "Allow" atau "Izinkan"** untuk semua izin yang diminta agar aplikasi berfungsi optimal.

#### 5. Login Aplikasi

Setelah instalasi selesai:
1. Buka aplikasi **E-Bimbingan**
2. Pada halaman onboarding, tap **SKIP** atau geser ke halaman terakhir
3. Masukkan **Email** dan **Password** yang telah diberikan oleh Admin
4. Tap tombol **Masuk**
5. Anda akan diarahkan ke Dashboard sesuai role (Admin/Dosen/Mahasiswa)

### Troubleshooting Instalasi

**Masalah: Aplikasi tidak bisa diinstal**
- ✅ Pastikan ruang penyimpanan mencukupi (minimal 100MB)
- ✅ Pastikan opsi "Install unknown apps" sudah diaktifkan
- ✅ Hapus versi aplikasi lama jika ada, lalu install ulang

**Masalah: Aplikasi crash saat dibuka**
- ✅ Pastikan Android versi 10 atau lebih tinggi
- ✅ Restart perangkat dan coba buka lagi
- ✅ Pastikan koneksi internet aktif

**Masalah: Tidak bisa login**
- ✅ Pastikan koneksi internet stabil
- ✅ Periksa kembali email dan password
- ✅ Hubungi Admin untuk reset password jika lupa

### Catatan Penting

⚠️ **Keamanan Instalasi:**
- File APK hanya diunduh dari link resmi yang disediakan tim pengembang
- Jangan download APK dari sumber tidak resmi untuk menghindari malware
- Setelah instalasi, Anda dapat menonaktifkan kembali opsi "Install unknown apps" untuk keamanan

📱 **Update Aplikasi:**
- Jika ada versi baru, uninstall aplikasi lama terlebih dahulu
- Download APK versi terbaru dari link Google Drive
- Install ulang mengikuti langkah-langkah di atas
- Data Anda akan tetap aman karena tersimpan di cloud (Firebase)

---

## 📱 Cara Penggunaan Aplikasi

### Login Pertama Kali

1. **Admin** membuat akun pengguna melalui fitur **Kelola User**
2. **Mahasiswa** dan **Dosen** login menggunakan email dan password default: `password`
3. Pengguna disarankan mengubah password setelah login pertama kali di menu **Profil**

### Alur Penggunaan untuk Mahasiswa

1. **Login** dengan akun yang telah dibuat admin
2. **Dashboard**: Lihat ringkasan progres bimbingan dan status terkini
3. **Ajukan Bimbingan**: 
   - Buat pengajuan bimbingan baru dengan mengisi topik dan metode (online/offline)
   - Tunggu persetujuan dari dosen pembimbing
4. **Isi Logbook Harian**: 
   - Catat aktivitas magang setiap hari secara rutin
   - Isi tanggal, topik kegiatan, dan deskripsi aktivitas
5. **Isi Log Bimbingan Mingguan**: 
   - Lengkapi log setelah sesi bimbingan dengan dosen disetujui
   - Upload bukti kehadiran (foto) jika diperlukan
6. **Monitoring**: 
   - Pantau status pengajuan (Menunggu/Disetujui/Ditolak)
   - Lihat riwayat bimbingan dan feedback dari dosen

### Alur Penggunaan untuk Dosen Pembimbing

1. **Login** dengan akun dosen
2. **Dashboard**: 
   - Lihat daftar mahasiswa bimbingan
   - Lihat jadwal bimbingan aktif
3. **Validasi Ajuan**: 
   - Buka menu **Ajuan**
   - Setujui atau tolak pengajuan bimbingan mahasiswa
   - Berikan keterangan jika menolak
4. **Validasi Log Bimbingan**: 
   - Buka menu **Log Bimbingan**
   - Verifikasi log bimbingan mingguan yang diajukan mahasiswa
   - Berikan catatan atau feedback
5. **Monitor Logbook Harian**: 
   - Buka menu **Log Harian**
   - Pantau aktivitas harian mahasiswa (opsional)
6. **Berikan Evaluasi**: 
   - Tambahkan catatan pada setiap sesi bimbingan
   - Beri arahan untuk perbaikan jika diperlukan

### Alur Penggunaan untuk Admin

1. **Login** dengan akun admin
2. **Dashboard**: 
   - Lihat statistik jumlah user, mahasiswa, dosen
   - Lihat ringkasan aktivitas sistem
3. **Kelola User**: 
   - Tambah akun baru (Admin/Dosen/Mahasiswa)
   - Edit data pengguna
   - Hapus akun yang tidak aktif
4. **Mapping Bimbingan**: 
   - Tetapkan relasi mahasiswa dengan dosen pembimbing
   - Tambah atau hapus relasi bimbingan
5. **Monitoring**: 
   - Pantau aktivitas bimbingan secara keseluruhan
   - Lihat riwayat bimbingan semua mahasiswa

---

## 👥 Kontributor / Tim Pengembang

| Nama | NIM | Role | Kontribusi Utama |
|------|-----|------|------------------|
| **Aldo Khrisna Wijaya** | 2341760091 | Project Manager & Developer | Koordinasi tim, sistem notifikasi, modul dosen, penyusunan laporan |
| **Afgan Galih Fauz A.A.** | 2341760004 | Developer, Tester, Firebase Architect | Struktur database, modul admin, unit testing, E2E testing, penyusunan laporan |
| **Aqila Nur Azza** | 2341760022 | Developer & UI/UX Designer | Desain UI/UX, modul mahasiswa, pembuatan poster, penyusunan laporan |
| **Dipa Praja Pramono** | 2341760143 | Technical Writer & UI/UX Designer | Desain UI/UX login & dosen, manual book, poster, penyusunan laporan |
| **Karina Ika Indasa** | 2341760042 | System Analyst & UI/UX Designer | Desain UI/UX dosen, analisis kebutuhan sistem, PPT, manual book, penyusunan laporan |

**Program Studi**: D4 Sistem Informasi Bisnis  
**Jurusan**: Teknologi Informasi  
**Institusi**: Politeknik Negeri Malang  
**Tahun**: 2025

### Dosen Pembimbing

- **Pemrograman Mobile**: Ade Ismail, S.Kom., M.TI.
- **Manajemen Proyek**: Renaldi Primaswara Prasetyo, S.ST., Kom., Dr.

---

## 📝 Catatan Tambahan

### Batasan Sistem (Out of Scope)

Aplikasi ini **tidak mencakup**:
- Pelaksanaan teknis magang di lapangan
- Fitur penilaian akhir magang secara otomatis
- Integrasi dengan sistem akademik (SIAM/SIAKAD)
- Upload dokumen laporan magang versi final
- Fitur komunikasi chat real-time antar pengguna
- **Platform iOS** (hanya tersedia untuk Android)
- **Versi Web** (hanya aplikasi mobile Android)

### Success Criteria

Keberhasilan aplikasi diukur berdasarkan:
- ✅ Semua fitur inti berfungsi sesuai kebutuhan dan telah diuji
- ✅ Kemudahan akses bagi mahasiswa dan dosen tanpa hambatan teknis
- ✅ Efisiensi proses bimbingan dan pengurangan dokumentasi manual
- ✅ Keamanan data terjamin dengan Firebase Authentication & Firestore Security Rules
- ✅ Feedback positif dari pengguna terkait usability (Skor SUS: **78.98** - kategori **"Good"**)

### Hasil Pengujian

Aplikasi telah melalui pengujian komprehensif:

**1. Unit Testing**
- ✅ 19 test cases (100% passed)
- ✅ Coverage: AuthViewModel, FirestoreService, DosenAjuanViewModel, MahasiswaAjuanViewModel, AdminUserManagementViewModel
- ✅ Durasi eksekusi: < 1 detik

**2. End-to-End (E2E) Testing**
- ✅ Login & Logout (Admin, Mahasiswa, Dosen)
- ✅ Pengajuan Bimbingan Mahasiswa (positive & negative cases)
- ✅ Validasi & Verifikasi Dosen
- ✅ Navigasi antar halaman
- ✅ Total: 8 skenario test (100% passed)

**3. Usability Testing (SUS)**
- ✅ Responden: 54 mahasiswa (setelah cleaning data)
- ✅ Skor rata-rata: **78.98/100**
- ✅ Kategori: **"Good"** mendekati **"Excellent"**
- ✅ Grade: **B (Above Average)**
- ✅ Acceptability: **"Acceptable"** - dapat diterima dengan baik oleh pengguna

### Keamanan Aplikasi

**Fitur Keamanan:**
- ✅ **Firebase Authentication**: Login aman dengan enkripsi
- ✅ **Firestore Security Rules**: Pembatasan akses data berbasis role
- ✅ **Role-Based Access Control**: Admin, Dosen, Mahasiswa memiliki hak akses berbeda
- ✅ **Data Encryption**: Data sensitif terenkripsi saat transit dan penyimpanan

**Catatan Keamanan untuk Developer:**

⚠️ **PENTING - Tidak Menggunakan Browser Storage**
- Aplikasi ini **TIDAK menggunakan** `localStorage` atau `sessionStorage`
- Semua data state dikelola menggunakan **Provider/State Management** Flutter
- Data persisten disimpan di **Firebase Firestore**

### Identitas Aplikasi

**Logo E-Bimbingan** terdiri dari tiga bentuk panah biru yang melambangkan:
- **Progres berkelanjutan**: Proses bimbingan yang bergerak maju
- **Fleksibilitas**: Kemampuan sistem menyesuaikan kebutuhan mahasiswa dan dosen
- **Profesionalitas**: Warna biru menunjukkan kepercayaan, stabilitas, dan teknologi
- **Kesederhanaan**: Tipografi sederhana untuk kemudahan penggunaan

### Rekomendasi Pengembangan Lanjutan

Untuk pengembangan masa depan, disarankan untuk menambahkan:
1. **Fitur Notifikasi Push** yang lebih canggih dengan Firebase Cloud Messaging
2. **Integrasi Kalender** untuk penjadwalan bimbingan otomatis
3. **Dashboard Analitik** untuk monitoring progres mahasiswa secara menyeluruh
4. **Export Laporan** dalam format PDF atau Excel
5. **Fitur Chat In-App** untuk komunikasi langsung antara mahasiswa dan dosen
6. **Versi iOS** untuk menjangkau pengguna iPhone
7. **Versi Web** untuk akses melalui browser desktop

---

## 🔗 Link Penting

| Resource | Link |
|----------|------|
| **Source Code (GitHub)** | [https://github.com/AlKhrisW/E-Bimbingan.git](https://github.com/AlKhrisW/E-Bimbingan.git) |
| **Download APK (Google Drive)** | [Download APK](https://drive.google.com/drive/folders/1LQ7RpLsoowABtOHR8_8xAcVreSotNxrl?usp=sharing) |
| **Desain UI/UX (Figma)** | [View Design](https://www.figma.com/design/DmlRioDrd4gJ8y3jxtKrbb/e-bimbingan?node-id=0-1&p=f&t=cUQwKACP5GUqSIBZ-0) |
| **Diagram System** | [View Diagram](https://drive.google.com/file/d/1HueEFeIqQG-q2TEk_pdDzDAFAa80CQub/view) |
| **Manual Book (Canva)** | [View Manual Book](https://www.canva.com/design/DAG6avGCCpo/W-jqfs-88ns5LNosIIqEbg/edit) |
| **Laporan Akhir PBL** | *(Tersedia dalam repository)* |
| **Dokumentasi Pengujian** | *(Tersedia dalam repository)* |

---

## 📄 Lisensi

Proyek ini dikembangkan sebagai **Project Based Learning (PBL)** untuk keperluan akademik di **Politeknik Negeri Malang**.

© 2025 Kelompok 3 - Ebimbingan

---

## 📞 Kontak & Dukungan

Jika membutuhkan bantuan atau memiliki pertanyaan terkait aplikasi:

- **WhatsApp Support**: 087725050445
- **Email**: *(hubungi melalui GitHub Issues)*
- **GitHub Issues**: [Create Issue](https://github.com/AlKhrisW/E-Bimbingan/issues)

**Untuk End-User:**
- Jika mengalami kendala saat instalasi atau penggunaan aplikasi, silakan hubungi Admin atau tim IT support institusi Anda

---

## 🙏 Ucapan Terima Kasih

Terima kasih kepada:
- **Dosen Pembimbing** yang telah membimbing pengembangan proyek ini
- **Politeknik Negeri Malang** atas fasilitas dan dukungan
- **Firebase** dan **Flutter Community** atas tools dan dokumentasi yang luar biasa
- Semua **mahasiswa responden** yang telah berpartisipasi dalam pengujian usability
- Semua **pihak yang telah berkontribusi** dalam pengembangan aplikasi E-Bimbingan

---

**Versi Dokumen**: 1.0  
**Terakhir Diperbarui**: Desember 2025  

**Catatan**: README ini disusun berdasarkan dokumentasi laporan akhir PBL dan dokumen pengujian aplikasi E-Bimbingan. Untuk informasi teknis lebih detail, silakan merujuk pada dokumentasi lengkap yang tersedia di repository atau hubungi tim pengembang.