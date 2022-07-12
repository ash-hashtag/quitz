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

  CardletModel({
    required this.id,
    required this.question,
    this.type = QuesType.choice,
    this.limit = 255,
    this.choices = const [],
    this.answers = const [],
    this.answerCounts = const [],
  });

  static CardletModel? fromMap(Map<String, dynamic> map) {
    try{
	List<String> answers = [];
    List<int> answerCounts = [];
    var choices = List<String>.from(map['mc'] ?? map['c'] ?? []);
    var type = map['mc'] != null
        ? QuesType.multichoice
        : map['c'] != null
            ? QuesType.choice
            : QuesType.text;
    if (choices.isNotEmpty) {
      answerCounts = List<int>.from(map['a']);
    } else if (map['a'] != null) {
      answers = [map['a']];
    }
    return CardletModel(
      id: map['_id'],
      question: map['q'],
      choices: choices,
      type: type,
      answers: answers,
      answerCounts: answerCounts,
    );
	}
	catch(e) {
		print('error parsing $e');
		return null;
	}
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
