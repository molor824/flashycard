import 'package:flashycard/rating.dart';
import 'package:flashycard/validator.dart';
import 'package:flutter/material.dart';

class Qna {
  final String question;
  final String answer;
  const Qna({required this.question, required this.answer});
}

class Flashcard extends StatefulWidget {
  final Qna qna;
  final void Function(int)? onRatingSubmit;
  const Flashcard({super.key, required this.qna, this.onRatingSubmit});

  @override
  State<StatefulWidget> createState() {
    return FlashcardState();
  }
}

class FlashcardState extends State<Flashcard> {
  bool _reveal = false;
  int? _rating;

  void _onRatingChange(int rating) {
    setState(() => _rating = rating);
  }

  void _onRevealPress() {
    if (_reveal) {
      widget.onRatingSubmit?.call(_rating!);
    }
    setState(() {
      _reveal = !_reveal;
      _rating = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text(widget.qna.question),
            if (_reveal) Text(widget.qna.answer),
            if (_reveal)
              Rating(rating: _rating ?? 0, onRatingChange: _onRatingChange),
            if (!_reveal || _rating != null)
              TextButton(
                onPressed: _onRevealPress,
                child: Text(!_reveal ? "Reveal" : "Next"),
              ),
          ],
        ),
      ),
    );
  }
}

class FlashcardDialogWidget extends StatefulWidget {
  final void Function(Qna flashcard)? onAddFlashcard;
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
      widget.onAddFlashcard?.call(Qna(question: _question!, answer: _answer!));
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
          mainAxisSize: MainAxisSize.min,
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
  final List<Qna> _flashcards = [];
  final Map<int, int> _ratings = {};
  int _currentFlashcard = 0;

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
    setState(() {
      _currentFlashcard = 0;
    });
  }

  void _onRatingSubmit(int rating) {
    setState(() {
      _ratings[_currentFlashcard] = rating;
      _currentFlashcard++;
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
                  ? Flashcard(
                      qna: _flashcards[_currentFlashcard],
                      onRatingSubmit: _onRatingSubmit,
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
