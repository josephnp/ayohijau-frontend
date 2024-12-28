import 'package:flutter/material.dart';

class ButtonAdmin extends StatelessWidget {
  const ButtonAdmin({
    super.key,
    required this.onPressed,
    required this.child
  });

  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[400],
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        minimumSize: const Size(100, 50),
        textStyle: const TextStyle(
          fontSize: 16
        )
      ),
      onPressed: onPressed,
      child: child
    );
  }
}