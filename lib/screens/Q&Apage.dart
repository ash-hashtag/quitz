import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import '../bin/db.dart';
import '../models/cardletModel.dart';

class QnAPage extends StatefulWidget {
  static const route = '/qna';
  const QnAPage({Key? key}) : super(key: key);

  @override
  State<QnAPage> createState() => _QnAPageState();
}

class _QnAPageState extends State<QnAPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Q&A'),
      ),
      body: LoopPageView.builder(
        itemBuilder: (_, i) => MyCardlet(
          question: local.questions[i],
        ),
        itemCount: local.questions.length,
      ),
    );
  }
}

class MyCardlet extends StatelessWidget {
  final CardletModel question;
  MyCardlet({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(question.question),
            if (question.type == QuesType.text)
              for (final i in question.answers) Text(i)
            else
              for (int i = 0; i < question.answers.length; i++)
                Text(
                    '${question.answers[i]} (${question.answerCounts[i] * 100 ~/ max}%)')
          ],
        ),
      ),
    );
  }

  late final max = question.type != QuesType.text
      ? question.answerCounts.reduce((a, b) => a + b)
      : 0;
}
