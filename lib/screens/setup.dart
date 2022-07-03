import 'package:flutter/material.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: RichText(
        text: const TextSpan(children: [
          TextSpan(text: 'Welcome to\n'),
          TextSpan(text: 'Quitz')
        ]),
      )),
    );
  }
}

class UsernameCheck extends StatefulWidget {
  const UsernameCheck({Key? key}) : super(key: key);

  @override
  State<UsernameCheck> createState() => _UsernameCheckState();
}

class _UsernameCheckState extends State<UsernameCheck> {
  final tc = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(),
      ),
      child: TextField(controller: tc),
    );
  }
}
