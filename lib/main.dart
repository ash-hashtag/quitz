import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:quitz/models/cardletModel.dart';
import 'package:quitz/routes.dart';
import 'package:quitz/screens/makeQuesPage.dart';
import 'package:quitz/themes.dart';
import 'package:quitz/widgets/cardlet.dart';

import 'bin/system.dart';
import './bin/db.dart';

void main() async {
  await server.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quitz',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: Themes.light,
      darkTheme: Themes.dark,
      onGenerateRoute: Routes.generateRoutes,
      initialRoute: '/',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  static const route = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CardletModel> questions = [];
  @override
  void initState() {
    super.initState();
    server
        .getQuestions(10)
        .then((value) => setState(() => questions = value))
        .onError((error, stackTrace) => System.showSnackBar(
            'Error getting ques $error on $stackTrace', context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quitz'),
        actions: [
          ClipRRect(borderRadius: BorderRadius.circular(50), child: TextButton(child: const Text('My Q&A'), onPressed: () => Navigator.pushNamed(context, ''),),)
        ],
      ),
      body: LoopPageView.builder(
        itemBuilder: (_, i) => Center(
          child: Cardlet(
            question: questions[i],
          ),
        ),
        itemCount: questions.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => askQuestion(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> askQuestion(BuildContext context) async {
    var question = await Navigator.pushNamed(context, MakeQuesPage.route);
    if (question is CardletModel) {
      setState(() => questions.add(question));
    }
  }
}
