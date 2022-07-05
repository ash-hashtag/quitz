import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:quitz/bin/db.dart';
import 'package:quitz/models/cardletModel.dart';

import '../bin/system.dart';

class Cardlet extends StatelessWidget {
  final CardletModel question;
  final bool myQuestion;

  Cardlet({Key? key, required this.question, this.myQuestion = false})
      : super(key: key);

  final tc = TextEditingController();
  final choicesKey = GlobalKey<_ChoicesState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      child: FlipCard(
        back: Container(color: Colors.red),
        flipOnTouch: false,
        front: Column(
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
            if (!myQuestion)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (question.answers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        child: const Text('Reveal'),
                        onPressed: revealAnswer,
                      ),
                    ),
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SubmitButton(
                      choiceKey: choicesKey,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void revealAnswer() {}
}

class SubmitButton extends StatefulWidget {
  final GlobalKey<_ChoicesState>? choiceKey;
  const SubmitButton({Key? key, this.choiceKey}) : super(key: key);

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool isSubmitted() => local.answers.any((element) =>
      element.first == widget.choiceKey!.currentState!.widget.question.id);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextButton(
        onPressed: isSubmitted()
            ? null
            : () => widget.choiceKey!.currentState!
                .submit()
                .whenComplete(() => setState(() {})),
        child: Text(
          widget.choiceKey!.currentState!.widget.question.answers.isNotEmpty
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
            child: TextField(
                controller: tc, enabled: widget.question.answers.isEmpty),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final i in widget.question.choices)
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(i),
                    onTap: widget.question.answers.isNotEmpty
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
    if (widget.question.answers.isEmpty &&
        (selectedChoice.isNotEmpty || (tc?.text.isNotEmpty ?? false))) {
      if (textQuestion) {
        selectedChoice = [tc!.text];
      }
      await server.submitAnwer(widget.question, selectedChoice);
      setState(() {});
      // try {
      //   await server.db.collection('answers').insert({
      //     '_id': randomID(),
      //     'q': widget.question.id,
      //     'a': selectedChoice,
      //   });
      //   setState(() => widget.question.answers = selectedChoice);
      // } catch (err) {
      //   System.showSnackBar("Error submitting answer $err", context);
      // }
    } else {
      System.showSnackBar('Silence is the answer?', context);
    }
  }
}
