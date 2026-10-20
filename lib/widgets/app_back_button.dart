import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Kembali',
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),
      iconSize: 24,
      icon: const Icon(
        Icons.arrow_back,
        size: 24,
        color: Color(0xFFFAAE36),
      ),
    );
  }
}
