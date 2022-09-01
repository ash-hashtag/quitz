import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quitz/models/cardletModel.dart';

class local {
  static List<CardletModel> questions = [];
  static List cachedQuestions = [];
  static Map<String, dynamic> myAnswers = {};

  static Future<void> checkForPrivacy(BuildContext context) async {
    final prefs = await Hive.openBox('prefs');
    if (!(prefs.get('notFirst') ?? false)) {
      final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Agree to the terms\n',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24)),
                    RichText(
                      text: TextSpan(
                          text:
                              "By using this app you are agreeing to the terms\n"
                              "We only store the things which you share on the plarform and only temporarily, they only exist in our database as far as they trend."
                              "We don't collect or share any sensitive data with others"
                              "We don't even ask for authentication to use this app, "
                              "We use local Storage to store your personal data",
                          style: const TextStyle(fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          child: const Text('Agree'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      )),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      if (result == true) {
        await prefs.put('notFirst', true);
        await prefs.close();
      }
    }
  }

  static Future<void> loadMyAnswers() async {
    final localBox = await Hive.openBox('local');
    myAnswers = Map<String, dynamic>.from(localBox.get('answers') ?? {});
    await localBox.close();
    // print('answers $myAnswers');
  }

  static Future<void> loadMyQuestions() async {
    try {
      final questionBox = await Hive.openBox('local');
      List list = questionBox.get('questions') ?? [];
      list = list.map((e) => Map<String, dynamic>.from(e)).toList();
      final _ = list.map((e) => CardletModel.fromMap(e, local: true)).toList()
        ..removeWhere((element) => element == null)
        ..shuffle();
      questions = _.cast<CardletModel>();
      await questionBox.close();
      // print('questions $questions');
    } catch (e) {
      print('error local storage questions $e');
    }
  }

  static Future<bool> end() async {
    try {
      questions =
          questions.sublist(max(questions.length - 20, 0), questions.length);
      List keys = myAnswers.keys.toList();
      keys = keys.sublist(0, max(keys.length - 20, 0));
      keys.forEach((element) => myAnswers.remove(element));
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

  static const SEC5 = Duration(seconds: 5);

  static const DBURL = 'https://quitz-ash-hashtag.koyeb.app';

  static Future<List<CardletModel>> getQuestions() async {
    List<CardletModel> questions = [];
    try {
      // print('getting ques');
      final response = await http.get(Uri.parse(DBURL + '/getques')).timeout(
          SEC5,
          onTimeout: () => throw TimeoutException("timeout bitch"));
      // print('got ques ${response.statusCode}');
      // .timeout(Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (final ques in data) {
          final oid = ques['_id']!['\$oid'];
          if (!(local.cachedQuestions.any(
                  (element) => element is CardletModel && element.id == oid) ||
              local.questions.any((element) => element.id == oid))) {
            final question = CardletModel.fromMap(ques);
            if (question != null) questions.add(question);
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
            (element) => (element.refreshAfter?.compareTo(NOW) ?? 1) < 0);
      if (_sublist.isEmpty) {
        return null;
      }
      final result = await http
          .post(
            Uri.parse(DBURL + '/ques'),
            body: _sublist.map((e) => e.id).toList(),
          )
          .timeout(SEC5,
              onTimeout: () => throw TimeoutException("timeout bitch"));
      if (result.statusCode == HttpStatus.ok) {
        final data = jsonDecode(result.body);
        data.forEach((q) {
          final oid = q['_id']!['\$oid'];
          final index =
              local.questions.indexWhere((element) => element.id == oid);
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
            .timeout(SEC5,
                onTimeout: () => throw TimeoutException("timeout bitch"))
            .then((value) => value.statusCode == HttpStatus.ok
                ? null
                : local.myAnswers.remove(question.id))
            .catchError((err) => local.myAnswers.remove(question.id));
      }
    } else {
      local.myAnswers[question.id] = answers.first;
      question.answers.add(answers.first);
      http
          .get(Uri.parse(DBURL + '/postans/${answers.first}/${question.id}'))
          .timeout(SEC5,
              onTimeout: () => throw TimeoutException("timeout bitch"))
          .then((value) => value.statusCode == HttpStatus.ok
              ? null
              : local.myAnswers.remove(question.id))
          .catchError((err) => local.myAnswers.remove(question.id));
    }
  }

  static Future<CardletModel?> askQuestion(
      String question, List<String> choices,
      {bool multi = false}) async {
    try {
      if (choices.isEmpty) {
        final result = await http
            .get(Uri.parse(DBURL + '/postques/' + question))
            .timeout(SEC5,
                onTimeout: () => throw TimeoutException("timeout bitch"));
        if (result.statusCode == HttpStatus.ok) {
          final id = result.body.substring(10, result.body.length - 2);
          final _question =
              CardletModel(id: id, question: question, type: QuesType.text);
          local.questions.add(_question);
          return _question;
        }
      } else {
        final Map<String, dynamic> map = {
          'q': question,
          if (multi) 'mc': choices else 'c': choices,
        };
        final json = jsonEncode(map);
        final result = await http
            .post(Uri.parse(DBURL + '/postques'), body: json)
            .timeout(SEC5,
                onTimeout: () => throw TimeoutException("timeout bitch"));
        if (result.statusCode == HttpStatus.ok) {
          final id = result.body.substring(10, result.body.length - 2);
          final _ques = CardletModel(
              id: id,
              question: question,
              choices: choices,
              answerCounts: List<int>.filled(choices.length, 0),
              type: multi ? QuesType.multichoice : QuesType.choice);
          local.questions.add(_ques);

          return _ques;
        }
      }
    } catch (err) {
      print('Error submitting quesiton $err');
    }
    return null;
  }
}
