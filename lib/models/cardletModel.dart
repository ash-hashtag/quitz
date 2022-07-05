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

  CardletModel({
    required this.id,
    required this.question,
    this.type = QuesType.choice,
    this.limit = 255,
    this.choices = const [],
    this.answers = const [],
  });

  static CardletModel fromMap(Map<String, dynamic> map) {
    List<String> answers = [];
    var choices = List<String>.from(map['mc'] ?? map['c'] ?? []);
    if (map['mc'] ?? map['c'] != null) {
      if (map['a'] != null) {
        var combination = map['a'].codeUnitAt(0);
        var optionIndex = 1;
        for (final i in choices) {
          if (optionIndex == optionIndex & combination) {
            answers.add(i);
          }
          optionIndex <<= 1;
        }
      }
    } else if (map['a'] != null) {
      answers = [map['a']];
    }
    return CardletModel(
      id: map['_id'],
      question: map['q'],
      choices: choices,
      type: map['c'] != null
          ? QuesType.choice
          : map['mc'] != null
              ? QuesType.multichoice
              : QuesType.text,
      answers: answers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'q': question,
      if (type == QuesType.choice) 'c': choices,
      if (type == QuesType.multichoice) 'mc': choices,
      if (answers.isNotEmpty) 'a': answers,
    };
  }
}

class Pair {
  final String first;
  final List<String> last;

  Pair(this.first, this.last);

  Map<String, List<String>> toMap() => {first: last};

  static Pair fromMap(Map<String, List<String>> map) =>
      Pair(map.keys.first, map.values.first);
}
