import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

typedef OnDeleteConfirmed = Future<bool> Function();

class ConfirmDeleteDialog extends StatelessWidget {
  final String itemName;
  final String? customMessage;
  final OnDeleteConfirmed onConfirmed;

  const ConfirmDeleteDialog({
    super.key,
    required this.itemName,
    this.customMessage,
    required this.onConfirmed,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String itemName,
    String? customMessage,
    required OnDeleteConfirmed onConfirmed,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDeleteDialog(
        itemName: itemName,
        customMessage: customMessage,
        onConfirmed: onConfirmed,
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_rounded, color: AppTheme.errorColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Hapus $itemName?',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              customMessage ?? 'Item ini akan dihapus permanen dan tidak dapat dikembalikan.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, true);
                      try {
                        final success = await onConfirmed();
                        _showSnackbar(
                          context,
                          success ? 'Berhasil dihapus!' : 'Gagal menghapus.',
                          isError: !success,
                        );
                      } catch (e) {
                        _showSnackbar(context, 'Terjadi kesalahan', isError: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}