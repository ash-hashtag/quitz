import 'dart:math';

import 'package:quitz/models/cardletModel.dart';

import '../bin/db.dart';

List<CardletModel> makeExamples(int length) {
  final rand = Random();
  List<CardletModel> examples = [];
  while (length > 0) {
    var ques = randomID(length: 100);
    var choicesLength = rand.nextInt(8);
    List<String> choices = [for (int i = 0; i < choicesLength; i++) randomID()];
    List<String> answers = [
      for (final i in choices)
        if (rand.nextBool()) i
    ];
    length--;

    examples.add(CardletModel(
        id: randomID(), question: ques, choices: choices, answers: answers));
  }
  return examples;
}
