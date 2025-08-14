import 'package:flutter/material.dart';
import 'flashcard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      ),
      home: const MyHomePage(title: 'Flashy Card'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Flashcard> _flashcards = [
    Flashcard(question: "テスト", answer: "てすと - Test"),
  ];
  int _currentFlashcard = 0;
  bool _reveal = false;

  void _addFlashcardButton(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => FlashcardDialogWidget(
        onAddFlashcard: (flashcard) =>
            setState(() => _flashcards.add(flashcard)),
      ),
    );
  }

  void _resetFlashcardCounter() {
    setState(() => _currentFlashcard = 0);
  }

  void _revealFlashcard() {
    setState(() {
      if (_reveal) {
        _currentFlashcard++;
      }
      _reveal = !_reveal;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _flashcards.isNotEmpty
            ? _currentFlashcard < _flashcards.length
                  ? FlashcardWidget(
                      reveal: _reveal,
                      flashcard: _flashcards[_currentFlashcard],
                      onReveal: _revealFlashcard,
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("No more flashcards left to display..."),
                        TextButton(
                          onPressed: _resetFlashcardCounter,
                          child: const Text("Restart"),
                        ),
                      ],
                    )
            : const Text("No flashcards to display..."),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addFlashcardButton(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
