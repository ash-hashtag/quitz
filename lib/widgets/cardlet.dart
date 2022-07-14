import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quitz/bin/db.dart';
import 'package:quitz/models/cardletModel.dart';
import 'package:quitz/widgets/flipCard.dart';

import '../bin/system.dart';

class Cardlet extends StatelessWidget {
  final CardletModel question;

  Cardlet({Key? key, required this.question}) : super(key: key);

  // final tc = TextEditingController();
  final choicesKey = GlobalKey<_ChoicesState>();
  final flipKey = GlobalKey<FlipCardState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      child: FlipCard(
        key: flipKey,
        // back: Container(height: 100, color: Colors.red,),
        back: AnswersWidget(
          flip: flip,
          question: question,
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // if (question.answers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    child: Text('Reveal'),
                    onPressed: flip,
                  ),
                ),
                Expanded(child: SizedBox()),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SubmitButton(choiceKey: choicesKey))
              ],
            )
          ],
        ),
      ),
    );
  }

  void flip() {
    flipKey.currentState?.flip();
  }
}

class SubmitButton extends StatefulWidget {
  final GlobalKey<_ChoicesState>? choiceKey;
  const SubmitButton({Key? key, this.choiceKey}) : super(key: key);

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool isSubmitted() => local.myAnswers.any((element) =>
      element.item1 == widget.choiceKey!.currentState!.widget.question.id);

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
          isSubmitted() ? 'Submitted' : 'Submit',
        ),
      ),
    );
  }
}

class Choices extends StatefulWidget {
  final CardletModel question;
  Choices({Key? key, required this.question}) : super(key: key);
  @override
  State<Choices> createState() => _ChoicesState();
}

class _ChoicesState extends State<Choices> {
  List<String> selectedChoice = [];
  late final textQuestion = widget.question.type == QuesType.text;
  late final TextEditingController? tc = TextEditingController(
      text: selectedChoice.isNotEmpty ? selectedChoice.first : null);

  @override
  void initState() {
    super.initState();
    if (selectedChoice.isEmpty) {
      var index = local.myAnswers
          .indexWhere((element) => element.item1 == widget.question.id);
      if (index != -1) {
        selectedChoice = local.myAnswers[index].item2;
        isSubmitted = true;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    tc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return textQuestion
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(controller: tc, enabled: !isSubmitted),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final i in widget.question.choices)
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    selectedTileColor: Colors.purple,
                    title: Text(i),
                    onTap: local.myAnswers
                            .any((element) => element.item1 == widget.question.id)
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

  bool isSubmitted = false;

  Future<void> submit() async {
    if (!isSubmitted &&
        (selectedChoice.isNotEmpty || (tc?.text.isNotEmpty ?? false))) {
      if (textQuestion) {
        selectedChoice = [tc!.text];
      }
      setState(() {
        api.submitAnwer(widget.question, selectedChoice);
        isSubmitted = true;
      });
    } else {
      System.showSnackBar('Silence is the answer?', context);
    }
  }
}

class AnswersWidget extends StatefulWidget {
  final CardletModel question;
  final VoidCallback? flip;
  const AnswersWidget({Key? key, required this.question, this.flip})
      : super(key: key);

  @override
  State<AnswersWidget> createState() => _AnswersWidgetState();
}

class _AnswersWidgetState extends State<AnswersWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: showValues
          ? values
          : widget.question.type == QuesType.text
              ? [
                  Row(
                    children: [
                      Expanded(child: Text(answer ?? 'Seems Noone Answered')),
                    ],
                  ),
                  TextButton(
                      onPressed: widget.flip, child: const Text('question')),
                ]
              : answers,
    );
  }

  void setAnswer() {
    if (widget.question.answers.isNotEmpty) {
      setState(() => answer = widget
          .question.answers[Random().nextInt(widget.question.answers.length)]);
    }
  }

  @override
  void initState() {
    super.initState();
    if (QuesType.text == widget.question.type) {
      setAnswer();
    } else {
      answers = getChildren();
      values = showActualValues();
    }
  }

  String? answer;

  late final answers;
  late final values;

  List<Widget> getChildren() {
    if (widget.question.type == QuesType.choice) {
      return [
        for (int i = 0; i < widget.question.choices.length; i++)
          ListTile(
            title: Text(
              '${widget.question.choices[i]} (${widget.question.answerCounts[i] * 100 ~/ totalCount}%)',
            ),
          ),
        TextButton(onPressed: widget.flip, child: const Text('question')),
      ];
    } else {
      final highest =
          widget.question.answerCounts.reduce((a, b) => a > b ? a : b);
      return [
        for (int i = 0; i < widget.question.choices.length; i++)
          if ((widget.question.answerCounts[i] * 100 ~/ highest) > 50)
            ListTile(
              title: Text(
                widget.question.choices[i],
              ),
            ),
        Row(
          children: [
            TextButton(onPressed: widget.flip, child: const Text('question')),
            TextButton(
                onPressed: () => setState(() => showValues = true),
                child: const Text('Values')),
          ],
        ),
      ];
    }
  }

  bool showValues = false;

  late final totalCount = widget.question.answerCounts.reduce((a, b) => a + b);
  List<Widget> showActualValues() {
    return [
      for (int i = 0; i < widget.question.choices.length; i++)
        ListTile(
          title: Text(
            '${widget.question.choices[i]} (${widget.question.answerCounts[i] * 100 ~/ totalCount}%)',
          ),
        ),
      Row(
        children: [
          TextButton(
            onPressed: widget.flip,
            child: const Text('Question'),
          ),
          TextButton(
            onPressed: () => setState(() => showValues = false),
            child: const Text('Answers'),
          )
        ],
      )
    ];
  }
}
