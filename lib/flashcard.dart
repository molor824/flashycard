import 'dart:async';

import 'package:flashycard/db_api.dart';
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
  final FutureOr<void> Function(int)? onRatingSubmit;
  const Flashcard({super.key, required this.qna, this.onRatingSubmit});

  @override
  State<StatefulWidget> createState() {
    return FlashcardState();
  }
}

class FlashcardState extends State<Flashcard> {
  bool _reveal = false;
  int? _rating;
  bool _loading = false;

  void _onRatingChange(int rating) {
    setState(() => _rating = rating);
  }

  Future<void> _onRevealPress() async {
    if (_reveal) {
      setState(() => _loading = true);
      await widget.onRatingSubmit?.call(_rating!);
      setState(() => _loading = false);
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
                child: !_loading
                    ? Text(!_reveal ? "Reveal" : "Next")
                    : const CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

class FlashcardDialogWidget extends StatefulWidget {
  final FutureOr<void> Function(Qna flashcard)? onAddFlashcard;
  const FlashcardDialogWidget({super.key, this.onAddFlashcard});

  @override
  State<StatefulWidget> createState() => FlashcardDialogState();
}

class FlashcardDialogState extends State<FlashcardDialogWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? _answer, _question;
  bool? _loading;

  Future<void> _addPressed() async {
    var state = _formKey.currentState!;
    state.save();
    if (state.validate()) {
      setState(() => _loading = true);
      await widget.onAddFlashcard?.call(
        Qna(question: _question!, answer: _answer!),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading == false) {
      Navigator.of(context).pop();
    }
    return AlertDialog(
      title: Text("Add flashcard"),
      actions: [
        ElevatedButton(
          onPressed: _addPressed,
          child: _loading == null
              ? const Text("Add")
              : const CircularProgressIndicator(),
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
  final FlashcardGroupData group;
  const FlashcardPage({super.key, required this.group});

  @override
  State<StatefulWidget> createState() => FlashcardPageState();
}

class FlashcardPageState extends State<FlashcardPage> {
  List<FlashcardData>? _flashcards;
  int _flashcardIndex = 0;

  FlashcardData? get _currentFlashcard => _flashcards?[_flashcardIndex];

  Future<void> _loadFlashcards() async {
    setState(() {
      _flashcards = null;
      _flashcardIndex = 0;
    });
    var data = await FlashcardData.selectGroupWithRatingSort(widget.group.id);
    setState(() => _flashcards = data);
  }

  @override
  void initState() {
    _loadFlashcards();
    super.initState();
  }

  Future<void> _onAddFlashcard(Qna qna) async {
    var data = await FlashcardData.insert(
      FlashcardInput(
        groupId: widget.group.id,
        question: qna.question,
        answer: qna.answer,
      ),
    );
    setState(() => _flashcards?.insert(0, data));
  }

  Future<void> _addFlashcardButton(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => FlashcardDialogWidget(onAddFlashcard: _onAddFlashcard),
    );
  }

  Future<void> _onRatingSubmit(int rating) async {
    if (_currentFlashcard != null) {
      await FlashcardData.updateRating(_currentFlashcard!.id, rating);
    }
    setState(() => _flashcardIndex++);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.group.title),
      ),
      body: Center(
        child: _flashcards != null
            ? _flashcards!.isNotEmpty
                  ? _flashcardIndex < _flashcards!.length
                        ? Flashcard(
                            qna: Qna(
                              answer: _currentFlashcard!.answer,
                              question: _currentFlashcard!.question,
                            ),
                            onRatingSubmit: _onRatingSubmit,
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "No more flashcards left to display...",
                              ),
                              TextButton(
                                onPressed: _loadFlashcards,
                                child: const Text("Restart"),
                              ),
                            ],
                          )
                  : const Text("No flashcards to display...")
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addFlashcardButton(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
