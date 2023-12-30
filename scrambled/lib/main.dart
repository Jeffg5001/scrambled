import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrambled/word_list.dart';

void main() {
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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xB5D0DFFF)),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

enum Screen { name, game }

class Tile {
  final int index;
  final String content;
  final bool enabled;
  const Tile({
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
  return result;
}

class MyAppState extends ChangeNotifier {
  var userName = '';
  setUsername(input) {
    userName = input;
    notifyListeners();
  }

  Screen currentScreen = Screen.name;
  setCurrentScreen(Screen screen) {
    currentScreen = screen;
    notifyListeners();
  }

  var currentWordIndex = 0;
  var history = [];
  var currentGuessNum = 0;
  var currentGuess = '';
  var scrambledWord = createTileList(wordList[0]);
  getNext() {
    history.add(wordList[currentWordIndex]);
    currentWordIndex = (currentWordIndex + 1) % wordList.length;
    currentGuessNum = 0;
    currentGuess = '';
    scrambledWord = createTileList(wordList[currentWordIndex]);
    scrambledWord.shuffle();
    notifyListeners();
  }

  addGuess() {
    currentGuess += wordList[currentWordIndex][currentGuessNum];
    currentGuessNum += 1;
    notifyListeners();
  }

  String getTarget() {
    return wordList[currentWordIndex][currentGuessNum];
  }

  scramble() {
    scrambledWord.shuffle();
    notifyListeners();
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
      case Screen.name:
        page = const NameForm();
      case Screen.game:
        page = Game();
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
    );
  }
}

class Game extends StatelessWidget {
  const Game({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var user = appState.userName;

    return Column(
      children: [
        Row(
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    size: 100,
                  ),
                )),
            Text('Hello, $user!'),
          ],
        ),
        Row(
          children: [
            ...appState.scrambledWord.map((tile) => TileButton(tile: tile)),
            TextButton(
              onPressed: () {
                appState.scramble();
                // TODO ensure word is scrambled and not the same order as before
                print('shuffled array ${appState.scrambledWord}');
              },
              style: TextButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(Icons.shuffle),
            ),
          ],
        ),
        const SizedBox(
          height: 75,
        ),
        Container(
          height: 20,
          width: 650,
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Text(appState.currentGuess),
        )
      ],
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
          if (appState.currentGuessNum < 4) {
            appState.addGuess();
          } else {
            appState.getNext();
          }
        } else {
          // incorrect feedback
        }
      } : null,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(),
        padding: EdgeInsets.all(25.0),
      ),
      child: Text(tile.content),
    );
  }
}

class NameForm extends StatelessWidget {
  const NameForm({
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
        Text(
          'Name?',
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 160, vertical: 16),
          child: MyCustomForm(),
        ),
      ],
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // Build a Form widget using the _formKey created above.
    handleDone(String data) {
      if (_formKey.currentState!.validate()) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        appState.setUsername(data);
        print('done pressed');
        // switch pages
        appState.setCurrentScreen(Screen.game);
      }
    }

    handleSubmit() {
      if (_formKey.currentState!.validate()) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        appState.setUsername(myController.text);
        print('submitted');
        // switch pages
        appState.setCurrentScreen(Screen.game);
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          // Add TextFormFields and ElevatedButton here.
          TextFormField(
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            controller: myController,
            onFieldSubmitted: handleDone,
          ),
          const SizedBox(height: 5),
          ElevatedButton.icon(
              onPressed: handleSubmit,
              label: const Text('continue'),
              icon: const Icon(Icons.check)),
        ],
      ),
    );
  }
}
