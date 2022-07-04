import 'package:quitz/models/cardletModel.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../constants/sensitive.dart';

class server {
  static late Db db;
  static void init() async {
    try {
      db = await Db.create(dburl);
      await db.open();
    } catch (e) {
      print('mongo err $e');
    }
  }

  static Future<List<CardletModel>> getQuestions(int count) async {
    try {
      var questions = await db
          .collection('questions')
          .find(where.exists('q').limit(10))
          .toList();
      var questionModels =
          questions.map((e) => CardletModel.fromMap(e)).toList();
      return questionModels;
    } catch (e) {
      print('error getting questions $e');
      return [];
    }
  }

  static void end() async {
    db.close();
  }
}
