import 'package:flutter/material.dart';

class MahasiswaErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const MahasiswaErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }
}
