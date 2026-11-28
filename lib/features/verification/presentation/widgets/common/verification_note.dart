import 'package:flutter/material.dart';

/// Tinted note with a leading icon, e.g. "Advanced plan active".
class VerificationNote extends StatelessWidget {
  const VerificationNote({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
