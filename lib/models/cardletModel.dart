enum QuesType {
  choice,
  multichoice,
  text,
}

class CardletModel {
  final String question;
  final QuesType type;
  final int limit;
  final List<String> choices;
  List<String> answers = [];
  bool submitted = false;

  CardletModel(
      {required this.question,
      this.type = QuesType.choice,
      this.limit = 255,
      this.choices = const []});

  static CardletModel fromMap(Map<String, dynamic> map) {
    return CardletModel(
      question: map['q'],
      choices: List<String>.from(map['c'] ?? map['mc'] ?? []),
      type: map['c'] != null
          ? QuesType.choice
          : map['mc'] != null
              ? QuesType.multichoice
              : QuesType.text,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'q': question,
      if (type == QuesType.choice) 'c': choices,
      if (type == QuesType.multichoice) 'mc': choices,
    };
  }
}
