import 'package:flutter/material.dart';

/// One colored line of the end-of-turn summary: an icon and its text.
class SummaryLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const SummaryLine(this.icon, this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color))),
      ]),
    );
  }
}
