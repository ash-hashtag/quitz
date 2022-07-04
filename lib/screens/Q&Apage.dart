import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import '../bin/db.dart';
import '../widgets/cardlet.dart';

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
        title: const Text('My Q&A'),
      ),
      body: LoopPageView.builder(
        itemBuilder: (_, i) => Cardlet(
          question: local.questions[i],
          myQuestion: true,
        ),
        itemCount: local.questions.length,
      ),
    );
  }
}
