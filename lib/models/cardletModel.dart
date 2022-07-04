import 'package:quitz/bin/db.dart';

enum QuesType {
  choice,
  multichoice,
  text,
}

class CardletModel {
  final String id;
  final String question;
  final QuesType type;
  final int limit;
  final List<String> choices;
  List<String> answers = [];
  bool submitted = false;

  CardletModel({
    required this.id,
    required this.question,
    this.type = QuesType.choice,
    this.limit = 255,
    this.choices = const [],
    this.answers = const [],
  });

  static CardletModel fromMap(Map<String, dynamic> map) {
    return CardletModel(
      id: map['_id'],
      question: map['q'],
      choices: List<String>.from(map['c'] ?? map['mc'] ?? []),
      type: map['c'] != null
          ? QuesType.choice
          : map['mc'] != null
              ? QuesType.multichoice
              : QuesType.text,
      answers: local.answers
          .firstWhere((element) => element.keys.first == map['_id'])
          .values
          .first,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'q': question,
      if (type == QuesType.choice) 'c': choices,
      if (type == QuesType.multichoice) 'mc': choices,
    };
  }
}
