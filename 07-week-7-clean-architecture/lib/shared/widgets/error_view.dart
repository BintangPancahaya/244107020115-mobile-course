import 'package:flutter/material.dart';
import '../../core/failures.dart';

/// UI hanya menerima pesan: Failure -> message, selain itu pesan umum.
String messageOf(Object error) =>
    error is Failure ? error.message : 'Terjadi kesalahan tak terduga.';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
