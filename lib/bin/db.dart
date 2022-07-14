import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:quitz/models/cardletModel.dart';
import 'package:tuple/tuple.dart';

class local {
  static List<CardletModel> questions = [];
  static List<Tuple2<String, dynamic>> myAnswers = [];

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      final questionBox = await Hive.openLazyBox('local');
      final List<Map<String, dynamic>> list =
          (await questionBox.get('questions')).cast<Map<String, dynamic>>();
      final _ = list.map((e) => CardletModel.fromMap(e)).toList()
        ..removeWhere((element) => element == null);
      questions = _ as List<CardletModel>;
    } catch (e) {
      print('error local storage $e');
    }
  }

  static Future<void> end() async {
    Map<String, List<String>> map = {};
    Hive.openBox('answers').then((value) => value
      ..clear
      ..putAll(map));
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
      if (selectedChoice > 0) {
        final temp = Tuple2(question.id, selectedChoice);
        local.myAnswers.add(temp);
        http
            .get(Uri.parse(DBURL + '/postans/${selectedChoice}/${question.id}'))
            .then((value) =>
                value.statusCode == 200 ? null : local.myAnswers.remove(temp))
            .catchError((err) => local.myAnswers.remove(temp));
      }
    } else {
      final temp = Tuple2(question.id, answers.first);
      local.myAnswers.add(temp);
      http
          .get(Uri.parse(DBURL + '/postans/${answers.first}/${question.id}'))
          .then((value) => value.statusCode == HttpStatus.ok
              ? null
              : local.myAnswers.remove(temp))
          .catchError((err) => local.myAnswers.remove(temp));
    }
  }

  static Future<CardletModel?> askQuestion(
      String question, List<String> choices,
      {bool multi = false}) async {
    if (choices.isEmpty) {
      final result = await http.get(Uri.parse(DBURL + '/freeques/' + question));
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
      final result = await http.post(Uri.parse(DBURL + '/postques'),
          body: jsonEncode(map));
      if (result.body.isNotEmpty) {
        map['id'] = result.body;
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
