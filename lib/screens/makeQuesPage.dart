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
      appBar: AppBar(
        title: const Text('Question'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [BorderTextField(tc: tc), const QuesTypeWidget()],
        ),
      ),
    );
  }
}

class QuesTypeWidget extends StatefulWidget {
  const QuesTypeWidget({Key? key}) : super(key: key);

  @override
  State<QuesTypeWidget> createState() => _QuesTypeWidgetState();
}

class _QuesTypeWidgetState extends State<QuesTypeWidget> {

  static final types = ['single choice','multi choice', 'free text'];
  var value = types[0];
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      dropdownColor: Theme.of(context).primaryColor,
      value: value,
      items:  [
        for (var i in types) DropdownMenuItem<String>(value: i,child: Text(i),),
      ],
      onChanged: (_) => setState(() => value = _!),
    );
  }
}
