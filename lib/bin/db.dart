import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:quitz/constants/examples.dart';
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
    return makeExamples(count);
    // try {
    //   var questions = await db
    //       .collection('questions')
    //       .find(where.exists('q').limit(10))
    //       .toList();
    //   var questionModels =
    //       questions.map((e) => CardletModel.fromMap(e)).toList();
    //   return questionModels;
    // } catch (e) {
    //   print('error getting questions $e');
    //   return [];
    // }
  }

  static Future<void> submitAnwer(
      CardletModel question, List<String> answer) async {
    local.answers.add(Pair(question.id, answer));
    // var choice = 0;
    // for (final i in answer) {
    //   int index = question.choices.indexOf(i);
    //   if (index != -1) {
    //     choice += 1 << index;
    //   }
    // }
    // await db.collection('answers').insert({
    //   '_id': randomID(),
    //   'q': question.id,
    //   if (question.type == QuesType.text) 'a': answer.first,
    //   if (question.type != QuesType.text) 'a': String.fromCharCode(choice),
    // });
  }

  static void end() async {
    db.close();
  }
}

class local {
  static late String myID;
  static List<Pair> answers = [];
  static List<CardletModel> questions = [];

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      final box = await Hive.openBox('answers');
      answers = List<Pair>.from(box.values);
      box.close();
      final prefs = await Hive.openBox('prefs');
      if (prefs.isOpen) {
        String? uid = prefs.get('uid');
        if (uid == null) {
          uid = randomID();
          prefs.put('uid', uid);
        }
        myID = uid;
        prefs.close();
      }
    } catch (e) {
      print('error local storage $e');
    }
  }

  static Future<void> end() async {
    Map<String, List<String>> map = {};
    answers.forEach((element) => map.addAll(element.toMap()));
    Hive.openBox('answers').then((value) => value
      ..clear
      ..putAll(map));
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
