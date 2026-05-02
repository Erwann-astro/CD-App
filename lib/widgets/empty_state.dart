import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: color),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
