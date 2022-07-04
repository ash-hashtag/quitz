import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:provider/provider.dart';
import 'package:quitz/bin/swipe.dart';
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

class HomePage extends StatelessWidget {
  static const route = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quitz'),),
      body: LoopPageView.builder(
          itemBuilder: (_, i) => Center(
                child: Cardlet(
                  question: quesModels[i],
                ),
              ),
          itemCount: quesModels.length),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MakeQuesPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
