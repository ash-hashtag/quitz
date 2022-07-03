import 'package:flutter/material.dart';
import 'package:quitz/widgets/borderTextField.dart';

class MakeQuesPage extends StatefulWidget {
  static const route = '/makeques';
  const MakeQuesPage({Key? key}) : super(key: key);

  @override
  State<MakeQuesPage> createState() => _MakeQuesPageState();
}

class _MakeQuesPageState extends State<MakeQuesPage> {
  final tc = TextEditingController();
 
  @override
  void dispose() {
    tc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question')),
      body: Stack(
        children: [
          const Center(child: Text('data'),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children:  [
              BorderTextField(tc: tc),
            ]),
          ),
        ],
      ),
    );
  }
}
