import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  static Color colorFor(String status) {
    switch (status) {
      case 'Under Review':
        return const Color(0xFFB4532A);
      case 'In Progress':
        return const Color(0xFF1F63A8);
      case 'Resolved':
        return const Color(0xFF2E7D4F);
      default:
        return const Color(0xFF9A6A00); // Submitted
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
    );
  }
}