import 'package:flashycard/validator.dart';
import 'package:flutter/material.dart';

class Flashcard {
  final String question;
  final String answer;
  const Flashcard({required this.question, required this.answer});
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
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text(flashcard.question),
            if (reveal) Text(flashcard.answer),
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

class FlashcardDialogWidget extends StatefulWidget {
  final void Function(Flashcard flashcard)? onAddFlashcard;
  const FlashcardDialogWidget({super.key, this.onAddFlashcard});

  @override
  State<StatefulWidget> createState() => FlashcardDialogState();
}

class FlashcardDialogState extends State<FlashcardDialogWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? _answer, _question;

  void _addPressed(BuildContext context) {
    var state = _formKey.currentState!;
    state.save();
    if (state.validate()) {
      widget.onAddFlashcard?.call(
        Flashcard(question: _question!, answer: _answer!),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add flashcard"),
      actions: [
        ElevatedButton(
          onPressed: () => _addPressed(context),
          child: Text("Add"),
        ),
      ],
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Question"),
              validator: emptyFieldValidator("question"),
              onSaved: (newQuestion) => _question = newQuestion,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Answer"),
              validator: emptyFieldValidator("answer"),
              onSaved: (newAnswer) => _answer = newAnswer,
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardPage extends StatefulWidget {
  final String title;
  const FlashcardPage({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => FlashcardPageState();
}

class FlashcardPageState extends State<FlashcardPage> {
  final List<Flashcard> _flashcards = [];
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
