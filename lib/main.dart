import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:provider/provider.dart';
import 'package:quitz/bin/ad_state.dart';
import 'package:quitz/routes.dart';
import 'package:quitz/screens/Q&Apage.dart';
import 'package:quitz/screens/makeQuesPage.dart';
import 'package:quitz/themes.dart';
import 'package:quitz/widgets/cardlet.dart';

import './bin/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final initAdsFuture = MobileAds.instance.initialize();
  final adState = AdState(initAdsFuture);
  await local.loadMyAnswers();
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

// class NativeAdTest extends StatefulWidget {
//   const NativeAdTest({Key? key}) : super(key: key);

//   @override
//   State<NativeAdTest> createState() => _NativeAdTestState();
// }

// class _NativeAdTestState extends State<NativeAdTest> {
//   bool isAdLoaded = false;
//   NativeAd? ad;
//   @override
//   void initState() {
//     super.initState();
//     ad = NativeAd(
//         adUnitId: AdState.nativeTestId,
//         factoryId: 'listTile',
//         request: AdRequest(),
//         listener: AdState.nativeAdListener(() {
//           print('loaded');
//           setState(() => isAdLoaded = true);
//         }))
//       ..load();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Native Ad'),
//       ),
//       body: Center(
//           child: isAdLoaded
//               ? Container(
//                   padding: const EdgeInsets.all(8.0),
//                   height: MediaQuery.of(context).size.height * 0.5,
//                   color: Colors.red,
//                   child: Center(child: AdWidget(ad: ad!)),
//                 )
//               : Container(
//                   color: Colors.blue,
//                 )),
//     );
//   }
// }

class HomePage extends StatefulWidget {
  static const route = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool something_broke = false;

  @override
  void initState() {
    super.initState();
    api.init();
    retry();

    WidgetsBinding.instance.addObserver(this);
  }

  void retry() {
    something_broke = false;
    onPageChanged(0);

    Future.delayed(Duration(seconds: 5), () {
      if (local.cachedQuestions.isEmpty) {
        setState(() => something_broke = true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) {
      local.end();
    }
  }

  void onPageChanged(int index) {
    if (index > local.cachedQuestions.length - 2) {
      api.getQuestions(10).then((value) {
        something_broke = false;
        value.isNotEmpty
            ? setState(() {
                local.cachedQuestions.addAll(value);
              })
            : null;
      });
    }
  }

  late StreamSubscription adstream;

  BannerAd? bannerAd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((value) => setState(() => bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdState.testBannerId,
        request: AdRequest(),
        listener: AdState.bannerAdListener)
      ..load()));
  }

  @override
  void dispose() {
    super.dispose();
    adstream.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
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
      body: local.cachedQuestions.isEmpty
          ? something_broke
              ? Center(
                  child: TextButton(
                    child: const Text('Tap to Refresh'),
                    onPressed: retry,
                  ),
                )
              : Center(
                  child: CircularProgressIndicator.adaptive(),
                )
          : LoopPageView.builder(
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) => ((i + 1 - (i ~/ 3)) % 3 == 0)
                  ? Center(child: NativeAdWidget())
                  : Center(
                      child: Cardlet(
                        question: local.cachedQuestions[(i - ((i - 1) ~/ 3))],
                      ),
                    ),
              itemCount: local.cachedQuestions.length + 2,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => askQuestion(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void askQuestion(BuildContext context) {
    Navigator.pushNamed(context, MakeQuesPage.route);
  }
}

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({Key? key}) : super(key: key);

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? ad;
  bool isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((value) => setState(() {
          ad = NativeAd(
              adUnitId: AdState.nativeTestId,
              factoryId: 'listTile',
              listener: AdState.nativeAdListener(() {
                setState(() {
                  isAdLoaded = true;
                });
                print('${isAdLoaded}');
              }),
              request: AdRequest())
            ..load();
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Container(
            margin: const EdgeInsets.all(30.0),
            height: MediaQuery.of(context).size.height / 2,
            child: isAdLoaded
                ? AdWidget(ad: ad!)
                : Center(child: CircularProgressIndicator.adaptive())),
      ),
    );
  }
}

/* class MyWidget extends StatefulWidget { */
/*   const MyWidget({Key? key}) : super(key: key); */

/*   @override */
/*   State<MyWidget> createState() => _MyWidgetState(); */
/* } */

/* class _MyWidgetState extends State<MyWidget> { */
/*   @override */
/*   void initState() { */
/*     // TODO: implement initState */
/*     super.initState(); */
/*     print('init ${widget.hashCode}'); */
/*   } */

/*   @override */
/*   void dispose() { */
/*     // TODO: implement dispose */
/*     print('disp ${widget.hashCode}'); */
/*     super.dispose(); */
/*   } */

/*   @override */
/*   Widget build(BuildContext context) { */
/*     return Container(); */
/*   } */
/* } */
