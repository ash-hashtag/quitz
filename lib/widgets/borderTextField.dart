import 'package:flutter/material.dart';

class BorderTextField extends StatelessWidget {
  final TextEditingController tc;
  const BorderTextField({Key? key, required this.tc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      controller: tc,
    );
  }
}
