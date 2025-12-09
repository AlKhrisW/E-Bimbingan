import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ebimbingan/core/themes/app_theme.dart';
import 'package:ebimbingan/data/services/log_bimbingan_service.dart';

class ImagePreviewWidget extends StatelessWidget {
  final String? base64Image;
  
  final LogBimbinganService _logService = LogBimbinganService();

  ImagePreviewWidget({
    super.key,
    required this.base64Image,
  });

  @override
  Widget build(BuildContext context) {
    if (base64Image == null || base64Image!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.image_not_supported_outlined, color: Colors.grey),
              SizedBox(height: 4),
              Text("Tidak ada bukti kehadiran", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final Uint8List? imageBytes = _logService.decodeBase64ToImage(base64Image);
    
    if (imageBytes == null) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () => _showFullImage(context, imageBytes),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(imageBytes, fit: BoxFit.cover),
              Container(
                color: Colors.black.withOpacity(0.1),
              ),
              const Center(
                child: Icon(Icons.zoom_in, color: Colors.white, size: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(imageBytes),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}