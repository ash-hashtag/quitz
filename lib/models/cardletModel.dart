
enum QuesType {
  choice,
  multichoice,
  text,
}

class CardletModel{
  final String question;
  final QuesType type;
  final int? limit;
  final List<String> choices;

  const CardletModel({
    required this.question,
    this.type = QuesType.choice,
    this.limit,
    this.choices = const []
  });
}