import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/ajuan_bimbingan_model.dart';
import '../../../core/widgets/custom_universal_back_appbar.dart';

import 'success_screen.dart';

class MahasiswaAjuanScreen extends StatefulWidget {
  final UserModel user;

  const MahasiswaAjuanScreen({
    super.key,
    required this.user,
  });

  @override
  State<MahasiswaAjuanScreen> createState() => _MahasiswaAjuanScreenState();
}

class _MahasiswaAjuanScreenState extends State<MahasiswaAjuanScreen> {
  final TextEditingController mahasiswaController = TextEditingController();
  final TextEditingController dosenController = TextEditingController();
  final TextEditingController topikController = TextEditingController();
  final TextEditingController metodeController = TextEditingController();
  final TextEditingController waktuController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  bool _isLoading = false;

  String? topikError;
  String? metodeError;
  String? waktuError;
  String? tanggalError;

  DateTime? pickedTanggal;

  @override
  void initState() {
    super.initState();
    mahasiswaController.text = widget.user.name ?? "";
    _loadDosenName();
  }

  @override
  void dispose() {
    mahasiswaController.dispose();
    dosenController.dispose();
    topikController.dispose();
    metodeController.dispose();
    waktuController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> _loadDosenName() async {
    try {
      final dosenUid = widget.user.dosenUid;

      if (dosenUid == null || dosenUid.isEmpty) {
        dosenController.text = "Tidak ada dosen pembimbing";
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(dosenUid)
          .get();

      if (!doc.exists) {
        dosenController.text = "Dosen tidak ditemukan";
        return;
      }

      final data = doc.data()!;
      final dosenName = data['name'] ??
          data['nama'] ??
          data['full_name'] ??
          data['namalengkap'] ??
          "Nama dosen tidak tersedia";

      dosenController.text = dosenName;
    } catch (e) {
      dosenController.text = "Gagal memuat nama dosen";
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      setState(() {
        waktuController.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        waktuError = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickedTanggal ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        pickedTanggal = picked;
        tanggalController.text =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        tanggalError = null;
      });
    }
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      if (topikController.text.isEmpty) {
        topikError = "Topik bimbingan harus diisi";
        isValid = false;
      } else {
        topikError = null;
      }

      if (metodeController.text.isEmpty) {
        metodeError = "Metode bimbingan harus diisi";
        isValid = false;
      } else {
        metodeError = null;
      }

      if (waktuController.text.isEmpty) {
        waktuError = "Waktu harus diisi";
        isValid = false;
      } else {
        waktuError = null;
      }

      if (tanggalController.text.isEmpty || pickedTanggal == null) {
        tanggalError = "Tanggal harus diisi";
        isValid = false;
      } else {
        tanggalError = null;
      }
    });

    return isValid;
  }

  Future<void> _submitAjuan() async {
    if (!_validateForm()) return;

    if (widget.user.dosenUid == null || widget.user.dosenUid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mahasiswa belum punya dosen pembimbing!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ajuan = AjuanBimbinganModel(
        ajuanUid: "",
        mahasiswaUid: widget.user.uid ?? "",
        dosenUid: widget.user.dosenUid ?? "",
        judulTopik: topikController.text,
        metodeBimbingan: metodeController.text,
        waktuBimbingan: waktuController.text,
        tanggalBimbingan: pickedTanggal!,
        status: AjuanStatus.proses,
        waktuDiajukan: DateTime.now(),
        keterangan: null,
      );

      final docRef = await FirebaseFirestore.instance
          .collection("ajuan_bimbingan")
          .add(ajuan.toMap());

      await docRef.update({"ajuanUid": docRef.id});

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SuccessScreen(
            message: "Ajuan Bimbingan Berhasil Diajukan",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim ajuan: $e")),
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomUniversalAppbar(judul: "Ajuan Bimbingan"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Mahasiswa"),
            _readonlyField(controller: mahasiswaController),

            _label("Dosen Pembimbing"),
            _readonlyField(controller: dosenController),

            _label("Topik Bimbingan"),
            _inputField(
              controller: topikController,
              hint: "Contoh: Revisi Bab 2",
              errorText: topikError,
              onChanged: (_) {
                if (topikError != null) setState(() => topikError = null);
              },
            ),

            _label("Metode Bimbingan"),
            _inputField(
              controller: metodeController,
              hint: "Contoh: Tatap muka / Zoom / Online",
              errorText: metodeError,
              onChanged: (_) {
                if (metodeError != null) setState(() => metodeError = null);
              },
            ),

            _label("Waktu Bimbingan"),
            TextField(
              controller: waktuController,
              readOnly: true,
              onTap: _pickTime,
              decoration: _decoration().copyWith(
                hintText: "Klik untuk memilih waktu",
                errorText: waktuError,
              ),
            ),

            _label("Tanggal Bimbingan"),
            TextField(
              controller: tanggalController,
              readOnly: true,
              onTap: _pickDate,
              decoration: _decoration().copyWith(
                hintText: "Klik untuk memilih tanggal",
                errorText: tanggalError,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitAjuan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _readonlyField({required TextEditingController controller}) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: _decoration(),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    String? hint,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration:
          _decoration().copyWith(hintText: hint, errorText: errorText),
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
}
