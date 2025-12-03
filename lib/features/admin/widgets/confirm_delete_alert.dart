// import 'package:flutter/material.dart';
// import '../../../core/themes/app_theme.dart';

// typedef OnDeleteConfirmed = Future<bool> Function();

// class ConfirmDeleteAlert extends StatelessWidget {
//   final String itemName;
//   final OnDeleteConfirmed onConfirmed;

//   const ConfirmDeleteAlert({
//     super.key,
//     required this.itemName,
//     required this.onConfirmed,
//   });

//   void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red.shade600 : AppTheme.primaryColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   Future<void> _showDialog(BuildContext context) async {
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: Colors.white,
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 340), // batas lebar maksimal
//           padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Icon kecil dengan background lingkaran tipis
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.errorColor.withOpacity(0.12),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.delete_rounded,
//                   color: AppTheme.errorColor,
//                   size: 32,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Judul
//               Text(
//                 'Hapus $itemName?',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),

//               // Deskripsi
//               Text(
//                 'Item ini akan dihapus permanen.',
//                 style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),

//               // Tombol horizontal (Batal kiri - Hapus kanan)
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.of(ctx).pop(false),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: AppTheme.errorColor,
//                         side: BorderSide(color: AppTheme.errorColor, width: 1.5),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.of(ctx).pop(true),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppTheme.errorColor,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         elevation: 0,
//                       ),
//                       child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     if (confirm == true) {
//       try {
//         final success = await onConfirmed();
//         _showSnackbar(
//           context,
//           success ? 'Berhasil dihapus!' : 'Gagal menghapus item.',
//           isError: !success,
//         );
//       } catch (e) {
//         _showSnackbar(context, 'Error: ${e.toString()}', isError: true);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.delete, color: AppTheme.errorColor),
//       tooltip: 'Hapus',
//       onPressed: () => _showDialog(context),
//     );
//   }
// }