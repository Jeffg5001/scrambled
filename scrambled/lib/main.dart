import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yolk_wordo/word_list.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    wordList.shuffle(); 
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          // colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(243, 250, 255, 1)),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(243, 250, 255, 1)),
          useMaterial3: true,
          textTheme: const TextTheme(displayMedium: TextStyle(
            color: Color.fromRGBO(51, 51, 51, 1),
          )),
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

enum Screen { landing, game }

class Tile {
  final int index;
  final String content;
  bool enabled;
  Tile({
    required this.index,
    required this.content,
    required this.enabled,
  });
}

List<Tile> createTileList(List<String> word) {
  int counter = 0;
  List<Tile> result = [];
  for (var element in word) {
    result.add(Tile(index: counter, content: element, enabled: true));
    counter += 1;
  }
  result.shuffle();
  return result;
}

class MyAppState extends ChangeNotifier {
  Screen currentScreen = Screen.landing;
  setCurrentScreen(Screen screen) {
    currentScreen = screen;
    notifyListeners();
  }

  int currentWordIndex = 0;
  List<List<String>> history = [];
  int currentGuessNum = 0;
  String currentGuess = '';
  List<Tile> scrambledWord = createTileList(wordList[0]);
  getNext() {
    history.add(wordList[currentWordIndex]);
    currentWordIndex = (currentWordIndex + 1) % wordList.length;
    currentGuessNum = 0;
    currentGuess = '';
    scrambledWord = createTileList(wordList[currentWordIndex]);
    notifyListeners();
  }

  addGuess(int index) {
    currentGuess += wordList[currentWordIndex][currentGuessNum];
    int indexToDisable = scrambledWord.indexWhere((element) => element.index == index);
    scrambledWord[indexToDisable].enabled = false;
    notifyListeners();
  }

  incrementGuess() {
    currentGuessNum += 1;
  }

  String getTarget() {
    return wordList[currentWordIndex][currentGuessNum];
  }

  scramble() {
    scrambledWord.shuffle();
    notifyListeners();
  }

  reset() {
    wordList.shuffle();
    currentWordIndex = 0;
    currentGuessNum = 0;
    currentGuess = '';
    scrambledWord = createTileList(wordList[0]);
    history = [];
  }

}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;
    switch (appState.currentScreen) {
      case Screen.landing:
        page = const LandingPage();
      case Screen.game:
        page = const Game();
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
        child: page,
      ),
      floatingActionButton: appState.currentScreen == Screen.game ? TextButton(
        onPressed: () {
          appState.getNext();
        },
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
        ),
        child: const Icon(Icons.arrow_forward, size: 48, semanticLabel: 'next word',),
      ) : null,
    );
  }
}

class ShapesPainter extends CustomPainter{

  @override void paint (Canvas canvas, Size size) {
    final paint = Paint();
    // set the color property of the paint
    paint.color = const Color.fromRGBO(246, 191, 108, 1);

    // center of the canvas is (x,y) => (width/2, height/2)
    var offset = const Offset(130, -110);
    
    // draw the circle on centre of canvas having radius 75.0
    canvas.drawCircle(offset, 237.0, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Game extends StatelessWidget {
  const Game({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return CustomPaint(
      painter: ShapesPainter(),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () {
                      appState.reset();
                      appState.setCurrentScreen(Screen.landing);
                    },
                    child: const Icon(Icons.home_outlined, semanticLabel: 'go to homescreen', size: 68),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 64,),
                ...appState.scrambledWord.map((tile) => TileButton(tile: tile)),
                TextButton(
                  onPressed: () {
                    appState.scramble();
                  },
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(Icons.shuffle, size: 36,),
                ),
              ],
            ),
            const SizedBox(
              height: 43,
            ),
            Text(
              appState.currentGuess,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Container(
              height: 18,
              width: 593.2,
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(9)),
                border: Border.all(
                  width: 9,
                  color: const Color.fromRGBO(169, 197, 250, 1),
                )
              )
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class TileButton extends StatelessWidget {
  const TileButton({
    super.key,
    required this.tile,
  });

  final Tile tile;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var target = appState.getTarget();
    return FilledButton(
      onPressed: tile.enabled ? () {
        if (tile.content == target) {
          appState.addGuess(tile.index);
          HapticFeedback.selectionClick();
          if (appState.currentGuessNum < 4) {
            appState.incrementGuess();
          } else {
            Timer(const Duration(milliseconds: 1000), () => appState.getNext());
          }
        } else {
          // incorrect feedback
          HapticFeedback.vibrate();
        }
      } : null,
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: BorderSide(width: 2, color:  Color.fromRGBO(21, 89, 222, 1)),
        ),
        padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
        maximumSize: const Size(100, 100),
        minimumSize: const Size(100, 100),
        backgroundColor: const Color.fromRGBO(254, 255, 220, 1)
      ),
      child: Text(tile.content,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: const Color.fromRGBO(21, 89, 222, 1),
        ),
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // Column is also a layout widget. It takes a list of children and
      // arranges them vertically. By default, it sizes itself to fit its
      // children horizontally, and tries to be as tall as its parent.
      //
      // Column has various properties to control how it sizes itself and
      // how it positions its children. Here we use mainAxisAlignment to
      // center the children vertically; the main axis here is the vertical
      // axis because Columns are vertical (the cross axis would be
      // horizontal).
      //
      // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
      // action in the IDE, or press "p" in the console), to see the
      // wireframe for each widget.
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'images/yolk-wordo-logo.png',
          width: 500
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 160, vertical: 10),
          child: PlayButton(),
        ),
      ],
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    onPressed() {
        appState.setCurrentScreen(Screen.game);
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(254, 255, 220, 1),
        foregroundColor: const Color.fromRGBO(21, 89, 222, 1),
        side: const BorderSide(color: Color.fromRGBO(21, 89, 222, 1), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 48),
      ),
      onPressed: onPressed,
      child: const Text('PLAY'));
  }
}
