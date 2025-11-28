# 📘 Sistem Logbook Harian & Log Bimbingan Mingguan

## 1. Overview

Sistem ini dirancang untuk melakukan pemantauan kegiatan mahasiswa secara harian (Logbook Harian) dan pembimbingan mingguan (Log Bimbingan Mingguan), serta memastikan kepatuhan mahasiswa terhadap jumlah sesi bimbingan minimal 4x per bulan.

Sistem terdiri dari tiga model utama:

1. **AjuanBimbinganModel** – Perencanaan jadwal bimbingan
2. **LogbookHarianModel** – Catatan aktivitas harian
3. **LogBimbinganModel** – Dokumentasi hasil sesi bimbingan mingguan serta pemicu verifikasi Log Harian

---

## 2. Peran & Fungsi Setiap Model

### 📌 AjuanBimbinganModel (Perencanaan & Komunikasi Awal)

Digunakan oleh mahasiswa untuk mengajukan jadwal bimbingan pada minggu tersebut.

**Fungsi Utama:**
- Menentukan rencana jadwal sesi bimbingan
- Mengaktifkan sistem reminder H-1 kepada mahasiswa dan dosen
- Mencatat reschedule (jika ada perubahan jadwal)
- Dokumentasi perencanaan dan administrasi awal

**❗ Catatan:**  
Ajuan bukan pemicu verifikasi Log Harian.

---

### 📌 LogbookHarianModel (Aktivitas Kerja Mahasiswa)

Mahasiswa mengisi Log Harian setiap hari kerja Senin–Jumat.

**Status default:** `draft`  
**Tujuan:** dokumentasi aktivitas harian sebagai bukti proses kerja dan progres mingguan.

---

### 📌 LogBimbinganModel (Verifikasi & Validasi Mingguan)

Setelah sesi bimbingan berlangsung, mahasiswa mengisi Log Bimbingan Mingguan.

Ketika Dosen melakukan **approve** pada Log Bimbingan Mingguan, sistem secara otomatis memverifikasi semua Log Harian pada minggu tersebut.

**Inilah pemicu utama verifikasi kualitas.**

---

## 3. Alur Sistem Global (End-to-End)

### Tahap 1 — Perencanaan
- Mahasiswa membuat Ajuan Bimbingan
- Dosen dapat menerima/tolak/reschedule
- Reminder H-1 dikirim otomatis

### Tahap 2 — Pelaksanaan Mingguan
- Mahasiswa mengisi Log Harian (Senin–Jumat)
- Status: `draft`

### Tahap 3 — Sesi Bimbingan
Dilakukan sesuai jadwal yang disepakati pada Ajuan.

### Tahap 4 — Pengisian Log Bimbingan Mingguan
- Mahasiswa mengisi ringkasan hasil pembimbingan
- Status: `pending`

### Tahap 5 — Persetujuan Dosen (Approval)
- Dosen membaca Log Mingguan
- Klik **Approve**
- Sistem menghitung jatah Log Harian untuk minggu tersebut: Senin s.d Jumat pada minggu di mana sesi berlangsung
- Sistem otomatis mengubah Status Log Harian menjadi: `verified`

---

## 4. Rentang Verifikasi Log Harian (Aturan Resmi)

### ✔ Aturan Final Sistem:

Setiap kali dosen menyetujui (approve) Log Bimbingan:
- Sistem mengambil `tanggalSesi` pada LogBimbingan tersebut
- Sistem menghitung rentang minggu: **Senin s.d Jumat pada minggu itu**
- Semua Log Harian dalam range tersebut → otomatis diverifikasi

### 📍 Catatan penting:

Tanggal sesi pada LogBimbingan **harus hari kerja** yaitu: **Senin – Jumat**

Jika bimbingan terjadi Sabtu atau Minggu, maka mahasiswa harus tetap mencatat tanggal sesi di LogBimbingan sebagai hari kerja terakhir minggu itu (biasanya Jumat).

---

## 5. Studi Kasus 

### 🧩 Studi Kasus 1: Rencana dibuat Minggu lalu

- Ajuan dibuat 1 Desember (minggu sebelumnya)
- Rencana bimbingan: Selasa 3 Desember
- Sistem tidak melarang
- Reminder tetap berfungsi
- Ajuan tidak mempengaruhi verifikasi Log Harian

👆 Ini legal dan realistis.

---

### 🧩 Studi Kasus 2: Bimbingan Hari Kamis

- `tanggalSesi` = Kamis, 5 Desember
- Sistem menghitung rentang: **Senin 2 Des — Jumat 6 Des**
- Log Harian Senin–Jumat → `verified`

Meskipun pada waktu approve Kamis, aktivitas Jumat sedang belum terjadi, tetapi sudah dianggap sebagai bagian dari rencana minggu itu.

---

### 🧩 Studi Kasus 3: Bimbingan Sabtu (di luar jam kerja)

Yang benar adalah:
- Ajuan boleh menyebut hari Sabtu (opsional)
- Namun Log Bimbingan Mingguan **HARUS** mencatat tanggal sesi sebagai: **Jumat terakhir minggu itu (hari kerja)**, yaitu dengan cara mahasiswa mengisi log bimbingan di hari jumat

---

## 6. Ringkasan Aturan Kunci

| Komponen | Fungsi | Pemicu Verifikasi |
|----------|--------|-------------------|
| **Ajuan Bimbingan** | Perencanaan & reminder | ❌ Tidak |
| **Log Harian** | Dokumentasi aktivitas harian | ❌ Tidak (status: draft) |
| **Log Bimbingan** | Dokumentasi hasil sesi | ✅ Ya (saat di-approve) |

**Mekanisme Verifikasi:**
```
Approve Log Bimbingan (tanggalSesi)
    ↓
Hitung rentang: Senin–Jumat minggu tersebut
    ↓
Update semua Log Harian dalam rentang → status: verified
```

---

## 7. Kepatuhan Minimal

Mahasiswa wajib melakukan **minimal 4 sesi bimbingan per bulan**.

Setiap sesi yang di-approve akan:
- Memverifikasi 5 hari Log Harian (Senin–Jumat)
- Menghitung sebagai 1 sesi dari 4 sesi wajib bulanan

---

## 8. FAQ

**Q: Apakah Ajuan Bimbingan wajib dibuat sebelum Log Harian?**  
A: Tidak wajib. Ajuan adalah perencanaan administratif dan tidak mempengaruhi verifikasi Log Harian.

**Q: Bagaimana jika bimbingan dilakukan di hari Sabtu?**  
A: Mahasiswa harus mencatat tanggal sesi sebagai Jumat terakhir minggu tersebut di Log Bimbingan.

**Q: Apakah Log Harian bisa diverifikasi tanpa Log Bimbingan?**  
A: Tidak. Hanya approval Log Bimbingan yang memicu verifikasi otomatis Log Harian.

**Q: Berapa lama status `draft` Log Harian berlaku?**  
A: Sampai Log Bimbingan minggu tersebut di-approve oleh dosen.

---

