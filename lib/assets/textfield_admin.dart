import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldAdmin extends StatelessWidget {
  const TextFieldAdmin({
    super.key,
    required this.controller,
    required this.label,
    this.number,
    this.desc,
    this.last,
    required this.valid,
  });

  final TextEditingController controller;
  final String label;
  final bool? number;
  final bool? desc;
  final bool? last;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(
              color: valid ? Colors.black : Colors.red
            )
          )
        ),
        keyboardType: number == true ? TextInputType.number : TextInputType.text,
        inputFormatters: number == true ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly] : null,
        textInputAction: last == true ? TextInputAction.done : TextInputAction.next,
        maxLines: desc == true ? 2 : 1,
      ),
    );
  }
}