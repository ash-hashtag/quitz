import 'dart:async';
import 'dart:math';

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
  api.init();
  final initAdsFuture = MobileAds.instance.initialize();
  final adState = AdState(initAdsFuture);
  await local.loadMyAnswers();
  await local.loadMyQuestions();

  // FlutterError.onError = (details) => print(
  // 'Error Details ${details.summary}, ${details.stack}, ${details.library}');

  ErrorWidget.builder = (details) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: SelectableText(
              'This should probably be fixed by restarting...\nif this happens again Report to us\n${details.exceptionAsString()}',
              maxLines: 5,
            ),
          ),
        ),
      );

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
    local.checkForPrivacy(context).whenComplete(retry);
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // InAppUpdate.checkForUpdate()
    //     .then((value) =>
    //         value.updateAvailability == UpdateAvailability.updateAvailable
    //             ? InAppUpdate.performImmediateUpdate()
    //                 .then((value) => null)
    //                 .catchError((err) =>
    //                     System.showSnackBar('failed to update $err', context))
    //             : null)
    //     .catchError(
    //         (err) => System.showSnackBar('update check failed $err', context));
  }

  void retry() {
    setState(() => something_broke = false);
    onPageChanged(0);
    Future.delayed(Duration(seconds: 6), () {
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

  bool getting = false;
  void onPageChanged(int index) {
    if (!getting &&
        (local.cachedQuestions.isEmpty ||
            (index > local.cachedQuestions.length - 2 &&
                Random().nextBool()))) {
      getting = true;
      Future.delayed(Duration(seconds: 10), () => getting = false);
      api.getQuestions().then((value) {
        something_broke = false;
        value.isNotEmpty
            ? setState(() {
                local.cachedQuestions.addAll(value);
              })
            : null;
      });
    }
    // if((index + 1) % 2 == 0 && !AdState.nativeAdLoaded){
    //   print('loading native ad');
    //   AdState.loadUpNativeAd(context);
    // }
  }

  // late StreamSubscription adstream;

  @override
  void dispose() {
    super.dispose();
    // adstream.cancel();
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
      bottomSheet: BannerAdWidget(),
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
              itemBuilder: (_, i) => (i + 1) % 4 == 0
                  ? Center(child: NativeAdWidget())
                  : Center(
                      child: Cardlet(
                        question: local.cachedQuestions[min(
                            i - (i ~/ 4), local.cachedQuestions.length - 1)],
                      ),
                    ),
              itemCount: itemCount(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => askQuestion(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  int itemCount() {
    final total =
        local.cachedQuestions.length + (local.cachedQuestions.length ~/ 4);
    // print(
    // 'total $total: ${local.cachedQuestions.map((e) => e is CardletModel ? e.id : 'ad')}');
    return total + ((total % 4 == 0) ? 1 : 0);
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
              adUnitId: AdState.nativeId,
              factoryId: 'listTile',
              listener: AdState.nativeAdListener(() {
                setState(() => isAdLoaded = true);
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
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
                child: isAdLoaded
                    ? AdWidget(ad: ad!)
                    : CircularProgressIndicator.adaptive())),
      ),
    );
  }
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? bannerAd;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((value) => setState(() => bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdState.bannerId,
        request: AdRequest(),
        listener: AdState.bannerAdListener)
      ..load()));
  }

  @override
  Widget build(BuildContext context) {
    return bannerAd != null
        ? Container(
            height: bannerAd!.size.height.toDouble(),
            color: Theme.of(context).backgroundColor,
            child: Center(child: AdWidget(ad: bannerAd!)))
        : SizedBox();
  }
}
