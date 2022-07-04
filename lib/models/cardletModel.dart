
enum QuesType {
  choice,
  multichoice,
  text,
}

class CardletModel{
  final String question;
  final QuesType type;
  final int limit;
  final List<String> choices;
  List<String> answers = [];
  bool submitted = false;


  CardletModel({
    required this.question,
    this.type = QuesType.choice,
    this.limit = 255,
    this.choices = const []
  });
}