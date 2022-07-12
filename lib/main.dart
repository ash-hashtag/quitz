import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:provider/provider.dart';
import 'package:quitz/bin/ad_state.dart';
import 'package:quitz/models/cardletModel.dart';
import 'package:quitz/routes.dart';
import 'package:quitz/screens/Q&Apage.dart';
import 'package:quitz/screens/makeQuesPage.dart';
import 'package:quitz/themes.dart';
import 'package:quitz/widgets/cardlet.dart';

import 'bin/system.dart';
import './bin/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await server.init();
  final initAdsFuture = MobileAds.instance.initialize();
  final adState = AdState(initAdsFuture);
  runApp(Provider.value(
    value: adState,
    builder: (_, child) => const MyApp(),
  ));
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

class HomePage extends StatefulWidget {
  static const route = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CardletModel> questions = [];
  @override
  void initState() {
    super.initState();
    server
        .getQuestions(2)
        .then((value) => setState(() => questions = value))
        .onError((error, stackTrace) => System.showSnackBar(
            'Error getting ques $error on $stackTrace', context));
  }

  late StreamSubscription adstream;

  BannerAd? bannerAd;

  NativeAd? nativeAd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((value) => setState(() {
          bannerAd = BannerAd(
              size: AdSize.banner,
              adUnitId: AdState.testBannerId,
              request: AdRequest(),
              listener: AdState.bannerAdListener)
            ..load();
          nativeAd = NativeAd(
              adUnitId: AdState.nativeTestId,
              factoryId: 'listTile',
              listener: AdState.nativeAdListener(
                  () => isAdLoaded = true),
              request: AdRequest())
            ..load();
        }));
  }

  bool isAdLoaded = false;

  @override
  void dispose() {
    super.dispose();
    adstream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    MyWidget();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quitz'),
        actions: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: TextButton(
              child: const Text('My Q&A'),
              onPressed: () => Navigator.pushNamed(context, QnAPage.route),
            ),
          )
        ],
      ),
      bottomSheet: bannerAd != null
          ? Container(
              color: Theme.of(context).primaryColor,
              height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!))
          : null,
      body: LoopPageView.builder(
        itemBuilder: (_, i) => i < questions.length
            ? Center(
                child: Cardlet(
                  question: questions[i],
                ),
              )
            : Center(
                child: Container(
                  margin: const EdgeInsets.all(30.0),
                  height: MediaQuery.of(context).size.height / 2,
                  child: Card(
                    child: isAdLoaded
                        ? AdWidget(ad: nativeAd!)
                        : CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
        itemCount: questions.length + 1,
      ),

      //if (bannerAd != null) AdWidget(ad: bannerAd!)

      floatingActionButton: FloatingActionButton(
        onPressed: () => askQuestion(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> askQuestion(BuildContext context) async {
    var question = await Navigator.pushNamed(context, MakeQuesPage.route);
    if (question is CardletModel) {
      setState(() => questions.add(question));
    }
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('init ${widget.hashCode}');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('disp ${widget.hashCode}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
