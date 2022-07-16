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
  List<String> answers;
  List<int> answerCounts;
  DateTime? refreshAfter;

  CardletModel({
    required this.id,
    required this.question,
    this.type = QuesType.choice,
    this.limit = 255,
    this.choices = const [],
    this.answers = const [],
    this.answerCounts = const [],
  });

  static CardletModel? fromMap(Map<String, dynamic> map, {bool local = false}) {
    try {
      List<String> answers = [];
      List<int> answerCounts = [];
      var choices = List<String>.from(map['mc'] ?? map['c'] ?? []);
      var type = map['mc'] != null
          ? QuesType.multichoice
          : map['c'] != null
              ? QuesType.choice
              : QuesType.text;
      if (choices.isNotEmpty) {
        answerCounts = map['a'] != null
            ? List<int>.from(map['a'])
            : List<int>.filled(choices.length, 0);
      } else if (map['a'] != null) {
        answers = List<String>.from(map['a']);
      }
      return CardletModel(
        id: local ? map['id'] : map['_id']!['\$oid'],
        question: map['q'],
        choices: choices,
        type: type,
        answers: answers,
        answerCounts: answerCounts,
      );
    } catch (e) {
      print('error parsing $e $map');
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'q': question,
      if (type == QuesType.choice) 'c': choices,
      if (type == QuesType.multichoice) 'mc': choices,
      'a': answerCounts.isNotEmpty ? answerCounts : answers,
    };
  }

  @override
  String toString() => toMap().toString();
}
