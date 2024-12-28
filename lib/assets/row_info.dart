import 'package:flutter/material.dart';

class RowInfo extends StatelessWidget {
  const RowInfo({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10,),
          SizedBox(
            width: 120,
            child: Text(text),
          )
        ],
      )
    );
  }
}