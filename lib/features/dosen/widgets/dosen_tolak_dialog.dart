import 'package:flutter/material.dart';

class TolakAjuanDialog extends StatelessWidget {
  final Function(String alasan) onConfirm;

  TolakAjuanDialog({
    super.key,
    required this.onConfirm,
  });

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      title: const Text(
        "Menolak Ajuan",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Masukkan alasan penolakan ajuan bimbingan ini.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // ===== INPUT ALASAN =====
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Alasan penolakan",
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),

              // ===== NORMAL =====
              enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),

              // ===== SAAT FOCUS =====
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),

              // ===== SAAT ERROR (OPSIONAL) =====
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),

              // ===== SAAT DISABLE =====
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ===== TOMBOL MODEL LOGOUT =====
          Row(
            children: [
              // ===== BUTTON BATAL =====
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      side: BorderSide.none,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ===== BUTTON TOLAK =====
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                    ),
                    onPressed: () {
                      final alasan = controller.text.trim();
                      Navigator.pop(context);
                      onConfirm(alasan);
                    },
                    child: const Text(
                      "Konfirmasi",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}