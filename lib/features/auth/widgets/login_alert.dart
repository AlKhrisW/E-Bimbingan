import 'package:flutter/material.dart';


class LoginAlert extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback? onDismissed; // callback ketika alert hilang

  const LoginAlert({
    super.key,
    required this.message,
    this.isError = true,
    this.onDismissed,
  });

  @override
  State<LoginAlert> createState() => _LoginAlertState();
}

class _LoginAlertState extends State<LoginAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Timer untuk otomatis hilang
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (widget.onDismissed != null) {
            widget.onDismissed!();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: widget.isError ? Colors.red.shade600 : Colors.green.shade600,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(
              widget.isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
