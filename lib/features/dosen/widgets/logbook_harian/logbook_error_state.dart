import 'package:flutter/material.dart';

class LogbookErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const LogbookErrorState({
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
