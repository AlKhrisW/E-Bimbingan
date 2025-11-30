import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/custom_universal_back_appBar.dart';
import '../../../data/models/logbook_harian_model.dart';
import 'success_screen.dart';

class TambahLogbookHarianScreen extends StatefulWidget {
  final UserModel user;

  const TambahLogbookHarianScreen({super.key, required this.user});

  @override
  State<TambahLogbookHarianScreen> createState() => _TambahLogbookHarianScreenState();
}

class _TambahLogbookHarianScreenState extends State<TambahLogbookHarianScreen> {
  final TextEditingController mahasiswaController = TextEditingController();
  final TextEditingController dosenController = TextEditingController();
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  bool _isLoading = false;
  String? judulError;
  String? deskripsiError;
  String? tanggalError;

  DateTime pickedTanggal = DateTime.now();

  @override
  void initState() {
    super.initState();
    mahasiswaController.text = widget.user.name ?? "";
    _loadDosenName();

    tanggalController.text =
        "${pickedTanggal.day.toString().padLeft(2, '0')}-${pickedTanggal.month.toString().padLeft(2, '0')}-${pickedTanggal.year}";
  }

  @override
  void dispose() {
    mahasiswaController.dispose();
    dosenController.dispose();
    judulController.dispose();
    deskripsiController.dispose();
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

      final doc =
          await FirebaseFirestore.instance.collection("users").doc(dosenUid).get();

      if (!doc.exists) {
        dosenController.text = "Dosen tidak ditemukan";
        return;
      }

      final data = doc.data()!;
      final dosenName = data['name'] ?? data['full_name'] ?? "Nama dosen tidak tersedia";

      dosenController.text = dosenName;
    } catch (e) {
      print("Error load dosen: $e");
      dosenController.text = "Gagal memuat nama dosen";
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickedTanggal,
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
      if (judulController.text.isEmpty) {
        judulError = "Judul topik harus diisi";
        isValid = false;
      } else {
        judulError = null;
      }

      if (deskripsiController.text.isEmpty) {
        deskripsiError = "Deskripsi harus diisi";
        isValid = false;
      } else {
        deskripsiError = null;
      }

      if (tanggalController.text.isEmpty) {
        tanggalError = "Tanggal harus diisi";
        isValid = false;
      } else {
        tanggalError = null;
      }
    });

    return isValid;
  }

  Future<void> _submitLogbook() async {
    if (!_validateForm()) return;

    if (widget.user.dosenUid == null || widget.user.dosenUid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mahasiswa belum punya dosen pembimbing!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final logbook = LogbookHarianModel(
        logbookHarianUid: "",
        mahasiswaUid: widget.user.uid ?? "",
        dosenUid: widget.user.dosenUid ?? "",
        judulTopik: judulController.text,
        tanggal: pickedTanggal,
        deskripsi: deskripsiController.text,
        status: LogbookStatus.draft,
      );

      final docRef = await FirebaseFirestore.instance
          .collection("logbook_harian")
          .add(logbook.toMap());

      await docRef.update({"logbookHarianUid": docRef.id});

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SuccessScreen(
            message: "Logbook Harian Berhasil Disimpan",
          ),
        ),
      );
    } catch (e) {
      print("Gagal submit logbook: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim logbook: $e")),
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomUniversalAppbar(judul: "Tambah Logbook Harian"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Mahasiswa"),
            _readonlyField(controller: mahasiswaController),

            _label("Dosen Pembimbing"),
            _readonlyField(controller: dosenController),

            _label("Judul Topik"),
            _inputField(
              controller: judulController,
              hint: "Contoh: Revisi Bab 2",
              errorText: judulError,
              onChanged: (value) {
                if (value.isNotEmpty && judulError != null) setState(() => judulError = null);
              },
            ),

            _label("Deskripsi Kegiatan"),
            _inputField(
              controller: deskripsiController,
              hint: "Contoh: Mengerjakan bab 2 metode penelitian",
              errorText: deskripsiError,
              onChanged: (value) {
                if (value.isNotEmpty && deskripsiError != null) setState(() => deskripsiError = null);
              },
              maxLines: 5,
            ),

            _label("Tanggal"),
            TextField(
              controller: tanggalController,
              readOnly: true,
              onTap: _pickDate,
              decoration: _decoration().copyWith(
                hintText: "Klik untuk memilih tanggal",
                errorText: tanggalError,
                errorBorder: tanggalError != null
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitLogbook,
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _readonlyField({required TextEditingController controller}) => TextField(
        controller: controller,
        readOnly: true,
        decoration: _decoration(),
      );

  Widget _inputField({
    required TextEditingController controller,
    String? hint,
    String? errorText,
    Function(String)? onChanged,
    int maxLines = 1,
  }) =>
      TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: _decoration().copyWith(hintText: hint, errorText: errorText),
      );

  InputDecoration _decoration() => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Colors.grey),
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
