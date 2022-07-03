import 'package:quitz/models/cardletModel.dart';

const quesModels = [
  CardletModel(
      question: 'What is wrong with you?', type: QuesType.choice, choices: [
        'nothing',
        'everything',
        'you suck',
      ]),
  CardletModel(question: 'What do you think of me?', type: QuesType.text, limit: 255),
  CardletModel(question: 'MultiChoice', type: QuesType.multichoice, choices: [
    'option 1',
    'option 2',
    'option 3',
  ])
];
