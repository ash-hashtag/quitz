import 'package:flutter/material.dart';
import 'package:quitz/models/cardletModel.dart';

import '../bin/system.dart';

class Cardlet extends StatelessWidget {
  final CardletModel question;

  Cardlet({Key? key, required this.question}) : super(key: key);

  final tc = TextEditingController();
  final choicesKey = GlobalKey<_ChoicesState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                question.question,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Choices(
              key: choicesKey,
              question: question,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SubmitButton(
                  choiceKey: choicesKey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubmitButton extends StatefulWidget {
  final GlobalKey<_ChoicesState>? choiceKey;
  const SubmitButton({Key? key, this.choiceKey}) : super(key: key);

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextButton(
        onPressed: widget.choiceKey!.currentState!.widget.question.submitted
            ? null
            : () => widget.choiceKey!.currentState!
                .submit()
                .whenComplete(() => setState(() {})),
        child: Text(
          widget.choiceKey!.currentState!.widget.question.submitted
              ? 'Submitted'
              : 'Submit',
        ),
      ),
    );
  }
}

class Choices extends StatefulWidget {
  final CardletModel question;
  const Choices({Key? key, required this.question}) : super(key: key);

  @override
  State<Choices> createState() => _ChoicesState();
}

class _ChoicesState extends State<Choices> {
  late List<String> selectedChoice = widget.question.answers;
  late final textQuestion = widget.question.type == QuesType.text;
  late final TextEditingController? tc = TextEditingController(
      text: selectedChoice.isNotEmpty ? selectedChoice.first : null);

  @override
  void dispose() {
    tc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return textQuestion
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                TextField(controller: tc, enabled: !widget.question.submitted),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final i in widget.question.choices)
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(i),
                    onTap: widget.question.submitted
                        ? null
                        : () => setState(
                              () => widget.question.type == QuesType.multichoice
                                  ? selectedChoice.contains(i)
                                      ? selectedChoice.remove(i)
                                      : selectedChoice.add(i)
                                  : selectedChoice.isNotEmpty
                                      ? selectedChoice =
                                          i == selectedChoice.first ? [] : [i]
                                      : selectedChoice.add(i),
                            ),
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(10),
                    //   side: BorderSide(
                    //     color: selectedChoice.contains(i)
                    //         ? Colors.purple
                    //         : Colors.white,
                    //   ),
                    // ),
                    // selectedColor: Colors.purple,
                    selected: selectedChoice.contains(i),
                  ),
                ),
            ],
          );
  }

  Future<void> submit() async {
    if (!widget.question.submitted &&
        (selectedChoice.isNotEmpty || (tc?.text.isNotEmpty ?? false))) {
      if (textQuestion) {
        selectedChoice = [tc!.text];
      }
      try {
        // await server.db.collection('answers').updateOne(
        //       mongo.where.eq('_id', widget.question.id),
        //       mongo.modify.push(
        //         'a',
        //         widget.question.type == QuesType.multichoice
        //             ? selectedChoice
        //             : selectedChoice.first,
        //       ),
        //     );
        setState(() {
          widget.question.submitted = true;
          widget.question.answers = selectedChoice;
        });
      } catch (err) {
        System.showSnackBar("Error submitting answer $err", context);
      }
    } else {
      System.showSnackBar('Silence is the answer?', context);
    }
  }
}
