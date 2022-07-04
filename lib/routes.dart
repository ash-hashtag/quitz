import 'package:flutter/material.dart';
import 'package:quitz/main.dart';
import 'package:quitz/screens/Q&Apage.dart';
import 'package:quitz/screens/makeQuesPage.dart';

import 'bin/system.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => required(settings));
  }

  static Widget required(RouteSettings settings) {
    switch (settings.name) {
      case HomePage.route:
        return const HomePage();
      case MakeQuesPage.route:
        return const MakeQuesPage();
      case QnAPage.route:
        return const QnAPage();
      default:
        return System.ErrorWidget;
    }
  }
}
