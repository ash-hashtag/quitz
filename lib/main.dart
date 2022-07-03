import 'package:flutter/material.dart';
import 'package:quitz/routes.dart';
import 'package:quitz/screens/makeQuesPage.dart';
import 'package:quitz/themes.dart';
import 'package:quitz/widgets/cardlet.dart';

import 'constants/examples.dart';

void main() {
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

class HomePage extends StatelessWidget {
  static const route = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Cardlet(question: quesModels[0]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MakeQuesPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
