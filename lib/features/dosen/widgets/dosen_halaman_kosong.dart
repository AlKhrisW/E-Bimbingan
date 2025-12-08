import 'package:flutter/material.dart';

class DosenHalamanKosong extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  final double iconSize;

  const DosenHalamanKosong({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.iconSize = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16, 
                  color: Colors.grey, 
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ),
              if (subMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  subMessage!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}