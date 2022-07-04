import 'package:quitz/constants/examples.dart';
import 'package:quitz/models/cardletModel.dart';
import 'package:mongo_dart/mongo_dart.dart';

class server {
  static late Db db;
  static const dburl =
      'mongodb+srv://rash_studios:rash_studios@cluster0.vagw5.mongodb.net/quitz?retryWrites=true&w=majority';
  static void init() async {
    try {
      db = await Db.create(dburl);
      await db.open();
      var data = await db
          .collection('questions')
          .find(where.exists('q').limit(10))
          .toList();
      print(data);
    } catch (e) {
      print('mongo err $e');
    }
  }

  static Future<List<CardletModel>> getQuestions(int count) async {
    try {} catch (e) {}
    return quesModels;
  }

  static void end() async {
    db.close();
  }
}
