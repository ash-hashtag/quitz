import 'package:flutter/material.dart';
import 'package:quitz/bin/db.dart';
import 'package:quitz/models/cardletModel.dart';
import 'package:quitz/widgets/borderTextField.dart';

import '../bin/system.dart';

class MakeQuesPage extends StatefulWidget {
  static const route = '/makeques';
  const MakeQuesPage({Key? key}) : super(key: key);

  @override
  State<MakeQuesPage> createState() => _MakeQuesPageState();
}

class _MakeQuesPageState extends State<MakeQuesPage> {
  final tc = TextEditingController();

  final queskey = GlobalKey<_QuesTypeWidgetState>();

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
      floatingActionButton: FloatingActionButton(
        onPressed: askQuestion,
        child: const Text(
          'Ask',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            BorderTextField(tc: tc),
            QuesTypeWidget(
              key: queskey,
            )
          ],
        ),
      ),
    );
  }

  Future<void> askQuestion() async {
    if (queskey.currentState != null) {
      final quesState = queskey.currentState!;
      if (tc.text.isEmpty) {
        System.showSnackBar('Great Question', context);
        return;
      }
      if (quesState.value != QuesType.text) {
        if (quesState.choices.isEmpty) {
          System.showSnackBar('which choice they gonna pick?!', context);
          return;
        } else if (quesState.choices.length == 1) {
          System.showSnackBar(
              'I know the answer "${quesState.choices.first}"', context);
          return;
        }
      }
      try {
        var result = await api.askQuestion(
            tc.text, quesState.choices, multi: quesState.value == QuesType.multichoice);
        // local.questions.add(
        //   CardletModel(
        //     id: randomID(),
        //     question: tc.text,
        //     choices: quesState.choices,
        //     type: quesState.value,
        //   ),
        // );
        // await server.db
        //     .collection('questions')
        //     .insert(local.questions.last.toMap());
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.pop(
          context,
        );
      } catch (e) {
        System.showSnackBar("Can't ask question right now $e", context);
      }
    }
  }
}

class QuesTypeWidget extends StatefulWidget {
  const QuesTypeWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<QuesTypeWidget> createState() => _QuesTypeWidgetState();
}

class _QuesTypeWidgetState extends State<QuesTypeWidget> {
  static const types = {
    'single choice': QuesType.choice,
    'multi choice': QuesType.multichoice,
    'free text': QuesType.text
  };
  var value = QuesType.choice;
  List<String> choices = [];

  final tc = TextEditingController();

  @override
  void dispose() {
    tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Expanded(child: Text('Question Type')),
              DropdownButton<QuesType>(
                dropdownColor: Theme.of(context).primaryColor,
                value: value,
                items: [
                  for (final i in types.keys)
                    DropdownMenuItem(
                      value: types[i],
                      child: Text(i),
                    )
                ],
                onChanged: (_) => setState(() => (value = _!)),
              ),
            ],
          ),
        ),
        if (value != QuesType.text)
          Column(
            children: [
              for (final i in choices)
                ListTile(
                  title: Text(i),
                  trailing: const Icon(Icons.delete),
                  onTap: () => setState(() => choices.remove(i)),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(child: BorderTextField(tc: tc)),
                    IconButton(
                        onPressed: addChoice, icon: const Icon(Icons.add))
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void addChoice() {
    if (tc.text.isEmpty) {
      System.showSnackBar('You forgot to type?', context);
      return;
    }
    if (choices.length < (value == QuesType.choice ? 10 : 5)) {
      setState(() => choices.add(tc.text));
      tc.clear();
    } else {
      System.showSnackBar(
          'If you want more choices, contact us, tap this', context);
    }
  }
}
