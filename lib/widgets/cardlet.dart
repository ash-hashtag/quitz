import 'package:flutter/material.dart';
import 'package:quitz/models/cardletModel.dart';

class Cardlet extends StatelessWidget {
  final CardletModel question;

  Cardlet({Key? key, required this.question}) : super(key: key);

  final tc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(question.question),
          (question.type == QuesType.choice ||
                  question.type == QuesType.multichoice)
              ? Choice(
                  choices: question.choices,
                  multichoice: question.type == QuesType.multichoice,
                )
              : TextField(
                  controller: tc,
                  maxLength: question.limit,
                  maxLines: null,
                ),
          const Align(alignment: Alignment.bottomRight, child: SubmitButton()),
        ],
      ),
    );
  }
}

class SubmitButton extends StatefulWidget {
  const SubmitButton({Key? key}) : super(key: key);

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool submitted = false;

  Future<void> submit() async {
    setState(() => submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: submitted ? null : submit, child: Text(submitted ? 'Submitted' : 'Submit'));
  }
}

class Choice extends StatefulWidget {
  final List<String> choices;
  final bool multichoice;
  const Choice({Key? key, required this.choices, this.multichoice = false})
      : super(key: key);

  @override
  State<Choice> createState() => _ChoiceState();
}

class _ChoiceState extends State<Choice> {
  List<String> selectedChoice = [];
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        for (final i in widget.choices)
          ListTile(
            title: Text(i),
            onTap: () => setState(
              () => widget.multichoice
                  ? selectedChoice.contains(i)
                      ? selectedChoice.remove(i)
                      : selectedChoice.add(i)
                  : selectedChoice.isNotEmpty
                      ? selectedChoice = i == selectedChoice.first ? [] : [i]
                      : selectedChoice.add(i),
            ),
            selected: selectedChoice.contains(i),
            selectedColor: Colors.purple,
          ),
      ],
    );
  }
}
