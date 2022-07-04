import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:provider/provider.dart';
import 'package:quitz/bin/swipe.dart';
import 'package:quitz/models/cardletModel.dart';
import 'package:quitz/routes.dart';
import 'package:quitz/screens/makeQuesPage.dart';
import 'package:quitz/themes.dart';
import 'package:quitz/widgets/cardlet.dart';

import 'constants/examples.dart';
import './bin/db.dart';

void main() {
  server.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SwipeProvider(),
      child: MaterialApp(
        title: 'Quitz',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: Themes.light,
        darkTheme: Themes.dark,
        onGenerateRoute: Routes.generateRoutes,
        initialRoute: '/',
        home: const HomePage(),
      ),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quitz'),
      ),
      body: LoopPageView.builder(
          itemBuilder: (_, i) => Center(
                child: Cardlet(
                  question: quesModels[i],
                ),
              ),
          itemCount: quesModels.length),
      floatingActionButton: FloatingActionButton(
        onPressed: () => askQuestion(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> askQuestion(BuildContext context) async {
    var question = await Navigator.pushNamed(context, MakeQuesPage.route);
    if ( question is CardletModel) {
      setState(() => quesModels.add(question));
    }
  }
}
