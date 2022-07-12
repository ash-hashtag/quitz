import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:quitz/models/cardletModel.dart';

/* class server { */
/*   static late Db db; */
/*   static late DbCollection questionsCollection; */
/*   static late DbCollection answerscollection; */
/*   static Future<void> init() async { */
/*     try { */
/*       db = await Db.create(dburl); */
/*       await db.open(); */
/*       questionsCollection = db.collection('questions'); */
/*       answerscollection = db.collection('answers'); */
/*       await local.init(); */
/*     } catch (e) { */
/*       print('mongo err $e'); */
/*     } */
/*   } */

/*   static Future<List<CardletModel>> getQuestions(int count) async { */
/*     try { */
/*       var questions = await questionsCollection.aggregateToStream([ */
/*         { */
/*           '\$sample': {'size': 10} */
/*         } */
/*       ]).toList(); */
/*       var questionModels = */
/*           questions.map((e) => CardletModel.fromMap(e)).toList(); */
/*       local.questions.addAll(questionModels); */
/*       return questionModels; */
/*     } catch (e) { */
/*       print('error getting questions $e'); */
/*       return []; */
/*     } */
/*   } */

/*   static Future<List<String>> getAnswers(CardletModel question) async { */
/*     try { */
/*       var doc = await answerscollection.findOne(where.eq('_id', question.id)); */
/*       if (doc?['a'] != null) { */
/*         return List<String>.from(doc!['a']); */
/*       } */
/*     } catch (e) { */
/*       print('error getting answeres $e'); */
/*     } */
/*     return []; */
/*   } */

/*   static Future<CardletModel?> askQuestion( */
/*       String question, List<String> choices, QuesType type) async { */
/*     try { */
/*       var id = randomID(); */
/*       Map<String, dynamic> map = {'_id': id, 'q': question}; */
/*       if (type != QuesType.text) { */
/*         if (type == QuesType.choice) { */
/*           map['c'] = choices; */
/*         } else { */
/*           map['mc'] = choices; */
/*         } */
/*         map['a'] = [for (final i in choices) 0]; */
/*       } */
/*       await questionsCollection.insertOne(map); */
/*       var result = CardletModel.fromMap(map); */
/*       local.questions.add(result); */
/*       return result; */
/*     } catch (e) { */
/*       print('error asking question $e'); */
/*     } */
/*     return null; */
/*   } */

/*   static Future<bool> chooseAnswer(CardletModel question, String answer) async { */
/*     try { */
/*       await questionsCollection.updateOne( */
/*           where.eq('_id', question.id), modify.set('a', answer)); */
/*       question.answers = [answer]; */
/*       return true; */
/*     } catch (e) { */
/*       print('error choosing answer $e'); */
/*     } */
/*     return false; */
/*   } */

/*   static Future<bool> submitAnwer( */
/*       CardletModel question, List<String> answer) async { */
/*     local.answers.add(Pair(question.id, answer)); */
/*     switch (question.type) { */
/*       case QuesType.text: */
/*         answerscollection.update( */
/*             where.eq('_id', question.id), modify.push('a', answer.first), upsert: true); */
/*         break; */
/*       default: */
/*         answer.forEach((element) { */
/*           var index = question.choices.indexOf(element); */
/*           questionsCollection.update( */
/*               where.eq('_id', question.id), modify.inc('a.$index', 1)); */
/*           question.answerCounts[index] += 1; */
/*         }); */
/*     } */
/*     // var choice = 0; */
/*     // for (final i in answer) { */
/*     //   int index = question.choices.indexOf(i); */
/*     //   if (index != -1) { */
/*     //     choice += 1 << index; */
/*     //   } */
/*     // } */
/*     // await db.collection('answers').insert({ */
/*     //   '_id': randomID(), */
/*     //   'q': question.id, */
/*     //   if (question.type == QuesType.text) 'a': answer.first, */
/*     //   if (question.type != QuesType.text) 'a': String.fromCharCode(choice), */
/*     // }); */
/*     return false; */
/*   } */

/*   static void end() async { */
/*     db.close(); */
/*   } */
/* } */

class pear {
  final String key;
  final dynamic value;

  pear(this.key, this.value);
}

class local {
  static List<CardletModel> questions = [];

  static List<String> myQuestions = [];
  static List<pear> myAnswers = [];

  static Future<void> init() async {
    // try {
    //   await Hive.initFlutter();
    //   final box = await Hive.openBox('answers');
    //   answers = List<Pair>.from(box.values);
    //   box.close();
    //   final prefs = await Hive.openBox('prefs');
    //   if (prefs.isOpen) {
    //     String? uid = prefs.get('uid');
    //     if (uid == null) {
    //       uid = randomID();
    //       prefs.put('uid', uid);
    //     }
    //     myID = uid;
    //     prefs.close();
    //   }
    // } catch (e) {
    //   print('error local storage $e');
    // }
  }

  static Future<void> end() async {
    Map<String, List<String>> map = {};
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

class api {
  static void init() {
  }

  static const DBURL = 'https://quitz-ash-hashtag.koyeb.app';

  static Future<List<CardletModel>> getQuestions(int len) async {
    List<CardletModel> questions = [];
    try {
      final response = await http.get(Uri.parse(DBURL + '/getques/$len'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (final ques in data) {
          final question = CardletModel.fromMap(ques);
          if (question != null) {
            questions.add(question);
          }
        }
      }
    } catch (e) {
      print('err $e');
    }
    return questions;
  }

  static Future<bool> submitAnwer(
      CardletModel question, List<String> answers) async {
    if (question.type != QuesType.text) {
      var selectedChoice = 0;
      for (int i = 0; i < answers.length; i++) {
        if (question.type == QuesType.multichoice) {
          final index = question.choices.indexOf(answers[i]);
          if (index != -1) {
            selectedChoice += 1 << index;
          }
        } else if (question.type == QuesType.choice) {
          selectedChoice = question.choices.indexOf(answers.first);
        }
      }
      if (selectedChoice > 0) {
        final result = await http.get(
            Uri.parse(DBURL + '/postans/${selectedChoice}/${question.id}'));

        if (result.statusCode == HttpStatus.ok) {
          local.myAnswers.add(pear(question.id, answers));
          return true;
        }
      }
    } else {
      final result = await http
          .get(Uri.parse(DBURL + '/postans/${answers.first}/${question.id}'));
      if (result.statusCode == HttpStatus.ok) {
        local.myAnswers.add(pear(question.id, answers));
        return true;
      }
    }

    return false;
  }

  static Future<CardletModel?> askQuestion(
      String question, List<String> choices,
      {bool multi = false}) async {
    if (choices.isEmpty) {
      final result = await http.get(Uri.parse(DBURL + '/freeques/' + question));
      if (result.body.isNotEmpty) {
        final _question = CardletModel(
            id: result.body, question: question, type: QuesType.text);
        local.myQuestions.add(result.body);
        return _question;
      }
    } else {
      final Map<String, dynamic> map = {
        'q': question,
        if (multi) 'mc': choices else 'c': choices,
      };
      final result = await http.post(Uri.parse(DBURL + '/postques'),
          body: jsonEncode(map));
      if (result.body.isNotEmpty) {
        map['id'] = result.body;
        final _ques = CardletModel.fromMap(map);
        if (_ques != null) {
          local.questions.add(_ques);
          local.myQuestions.add(result.body);
        }
        return _ques;
      }
    }
    return null;
  }
}
