import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import '../bin/db.dart';
import '../bin/system.dart';
import '../models/cardletModel.dart';

class QnAPage extends StatefulWidget {
  static const route = '/qna';
  const QnAPage({Key? key}) : super(key: key);

  @override
  State<QnAPage> createState() => _QnAPageState();
}

class _QnAPageState extends State<QnAPage> {
  bool refresh_active = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Q&A'),
        actions: [
          IconButton(onPressed: refresh, icon: Icon(Icons.refresh_outlined))
        ],
      ),
      body: LoopPageView.builder(
        onPageChanged: refresh_active ? onPageChanged : null,
        itemBuilder: (_, i) => MyCardlet(
          question: local.questions[i],
        ),
        itemCount: local.questions.length,
      ),
    );
  }

  int curIndex = 0;
  int nextIndex = 0;
  void onPageChanged(int index) {
    curIndex = index;
    if (curIndex > nextIndex) {
      nextIndex = index + 10;
    }
  }

  void refresh() {
    refresh_active = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
              child: CircularProgressIndicator.adaptive(),
            ));
    api.refreshMyQuestions(curIndex).then((value) {
      Navigator.pop(context);
      switch (value) {
        case true:
          setState(() {});
          break;
        case false:
          System.showSnackBar('Error refreshing', context);
      }
    });
  }
}

class MyCardlet extends StatelessWidget {
  final CardletModel question;
  MyCardlet({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.4),
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
