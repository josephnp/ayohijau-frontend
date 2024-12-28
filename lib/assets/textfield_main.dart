import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldMain extends StatelessWidget {
  const TextFieldMain({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.email,
    this.password,
    this.number,
    this.address,
    this.last,
    required this.valid,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool? email;
  final bool? password;
  final bool? number;
  final bool? address;
  final bool? last;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
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
          obscureText: password == true ? true : false,
          keyboardType: password == true
            ? TextInputType.visiblePassword
            : email == true
              ? TextInputType.emailAddress
              : number == true
                ? TextInputType.number
                : address == true
                  ? TextInputType.streetAddress
                  : TextInputType.text,
          inputFormatters: number == true ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly] : null,
          textInputAction: last == true ? TextInputAction.done : TextInputAction.next,
        ),
      ],
    );
  }
}