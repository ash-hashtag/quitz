import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:quitz/models/cardletModel.dart';

class local {
  static List<CardletModel> questions = [];
  static List cachedQuestions = [];
  static Map<String, dynamic> myAnswers = {};

  static Future<void> loadMyAnswers() async {
    final localBox = await Hive.openBox('local');
    myAnswers = Map<String, dynamic>.from(localBox.get('answers') ?? {});
    localBox.close();
    print(myAnswers);
  }

  static Future<void> loadMyQuestions() async {
    try {
      final questionBox = await Hive.openBox('local');

      List list = questionBox.get('questions') ?? [];
      list = list.map((e) => Map<String, dynamic>.from(e)).toList();
      final _ = list.map((e) => CardletModel.fromMap(e)).toList()
        ..removeWhere((element) => element == null);
      questions = _.cast<CardletModel>();
      questionBox.close();
    } catch (e) {
      print('error local storage $e');
    }
  }

  static Future<bool> end() async {
    try {
      final data = questions.map((e) => e.toMap()).toList();
      final box = await Hive.openBox('local');
      await box.clear();
      await box.put('answers', myAnswers);
      await box.put('questions', data);
      await box.close();
      print("saved data");
      return true;
    } catch (err) {
      print('Error saving locally $err');
      return false;
    }
  }
}

class api {
  static void init() {}

  static const DBURL = 'https://quitz-ash-hashtag.koyeb.app';

  static Future<List<CardletModel>> getQuestions(int len) async {
    List<CardletModel> questions = [];
    try {
      final response = await http.get(Uri.parse(DBURL + '/getques/$len'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (final ques in data) {
          if (!local.cachedQuestions.any((element) =>
              element is CardletModel && element.id == ques['_id'])) {
            final question = CardletModel.fromMap(ques);
            if (question != null) {
              questions.add(question);
            }
          }
        }
      }
    } catch (e) {
      print('err $e');
    }
    return questions;
  }

  static Future<bool?> refreshMyQuestions(int index) async {
    try {
      final NOW = DateTime.now();
      final _sublist = local.questions
          .sublist(index, min(index + 10, local.questions.length))
        ..removeWhere(
            (element) => (element.refreshAfter?.compareTo(NOW) ?? -1) < 0);
      if (_sublist.isEmpty) {
        return null;
      }
      final result = await http.post(
        Uri.parse(DBURL + '/ques'),
        body: _sublist.map((e) => e.id).toList(),
      );
      if (result.statusCode == HttpStatus.ok) {
        final data = jsonDecode(result.body);
        data.forEach((q) {
          final index =
              local.questions.indexWhere((element) => element.id == q['_id']);
          if (index != -1) {
            final question = local.questions[index];
            if (question.type == QuesType.text)
              question.answers = List<String>.from(q['a']);
            else {
              question.answerCounts = List<int>.from(q['a']);
            }
          }
        });
        final _ = NOW.add(Duration(minutes: 5));
        _sublist.forEach((e) => e.refreshAfter = _);
        return true;
      }
    } catch (e) {
      print('Error refreshing $e');
    }
    return false;
  }

  static void submitAnwer(CardletModel question, List<String> answers) async {
    if (question.type != QuesType.text) {
      var selectedChoice = 0;
      for (int i = 0; i < answers.length; i++) {
        if (question.type == QuesType.multichoice) {
          final index = question.choices.indexOf(answers[i]);
          if (index != -1) {
            selectedChoice += 1 << index;
            question.answerCounts[index] += 1;
          }
        } else if (question.type == QuesType.choice) {
          selectedChoice = question.choices.indexOf(answers.first);
          if (selectedChoice != -1) {
            question.answerCounts[selectedChoice] += 1;
          }
        }
      }
      if (selectedChoice >= 0) {
        local.myAnswers[question.id] = selectedChoice;
        http
            .get(Uri.parse(DBURL + '/postans/${selectedChoice}/${question.id}'))
            .then((value) => value.statusCode == HttpStatus.ok
                ? null
                : local.myAnswers.remove(question.id))
            .catchError((err) => local.myAnswers.remove(question.id));
      }
    } else {
      local.myAnswers[question.id] = answers.first;
      http
          .get(Uri.parse(DBURL + '/postans/${answers.first}/${question.id}'))
          .then((value) => value.statusCode == HttpStatus.ok
              ? null
              : local.myAnswers.remove(question.id))
          .catchError((err) => local.myAnswers.remove(question.id));
    }
    print(local.myAnswers);
  }

  static Future<CardletModel?> askQuestion(
      String question, List<String> choices,
      {bool multi = false}) async {
    if (choices.isEmpty) {
      final result = await http.get(Uri.parse(DBURL + '/postques/' + question));
      print(result.statusCode);
      if (result.body.isNotEmpty && result.statusCode == HttpStatus.ok) {
        final _question = CardletModel(
            id: result.body, question: question, type: QuesType.text);
        local.questions.add(_question);
        return _question;
      }
    } else {
      final Map<String, dynamic> map = {
        'q': question,
        if (multi) 'mc': choices else 'c': choices,
      };
      final json = jsonEncode(map);
      print(json);
      final result =
          await http.post(Uri.parse(DBURL + '/postques'), body: json);
      print(result.body);
      print(result.statusCode);
      if (result.body.isNotEmpty) {
        map['_id'] = result.body;
        final _ques = CardletModel.fromMap(map);
        if (_ques != null) {
          local.questions.add(_ques);
        }
        return _ques;
      }
    }
    return null;
  }
}
