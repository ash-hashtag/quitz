import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:quitz/models/cardletModel.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../constants/sensitive.dart';

class server {
  static late Db db;
  static Future<void> init() async {
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

class local {
  static List<Map<String, List<String>>> answers = [];
  static List<CardletModel> questions = [];

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      final box = await Hive.openBox('answers');
      answers = List<Map<String, List<String>>>.from(box.values);
    } catch (e) {
      print('error local storage $e');
    }
  }
}

String randomID({int length = 20}) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  return String.fromCharCodes([
    for (int i = 0; i < length; i++)
      characters.codeUnitAt(rand.nextInt(characters.length))
  ]);
}
