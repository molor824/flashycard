import 'package:flutter/material.dart';

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

class Flashcard {
  final String word;
  final String hiragana;
  final String meaning;
  const Flashcard({
    required this.word,
    required this.hiragana,
    required this.meaning,
  });
}

class FlashcardWidget extends StatelessWidget {
  final Flashcard flashcard;
  final bool reveal;
  final void Function()? onReveal;
  const FlashcardWidget({
    super.key,
    this.onReveal,
    required this.reveal,
    required this.flashcard,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            if (reveal)
              Text(
                flashcard.hiragana,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            Text(reveal ? flashcard.meaning : flashcard.word),
            TextButton(
              onPressed: onReveal,
              child: Text(!reveal ? "Reveal" : "Next"),
            ),
          ],
        ),
      ),
    );
  }
}

class AddFlashcardWidget extends StatefulWidget {
  const AddFlashcardWidget({super.key});

  @override
  State<AddFlashcardWidget> createState() => _AddFlashcardWidgetState();
}

class _AddFlashcardWidgetState extends State<AddFlashcardWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  String? Function(String?) _emptyFieldValidator(String name) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return "Please enter $name";
      }
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add New Flashcard"),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    children: [
                      const Text("Word"),
                      const Text("Hiragana"),
                      TextFormField(
                        decoration: const InputDecoration(hintText: "言葉"),
                        validator: _emptyFieldValidator("Word"),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(hintText: "ことば"),
                        validator: _emptyFieldValidator("Hiragana"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Flashcard> _flashcards = [
    Flashcard(word: "テスト", hiragana: "てすと", meaning: "Test"),
  ];
  int _currentFlashcard = 0;
  bool _reveal = false;
  bool _flashcardForm = false;

  void _addFlashcard(Flashcard flashcard) {
    setState(() => _flashcards.add(flashcard));
  }

  void _addFlashcardButton() async {
    await showDialog(context: context, builder: (_) => Card());
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
        onPressed: _addFlashcardButton,
        child: Icon(!_flashcardForm ? Icons.add : Icons.close),
      ),
    );
  }
}
