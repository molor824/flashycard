import 'dart:async';

import 'package:flashycard/db_api.dart';
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
  final FutureOr<void> Function(String, String)? onEdit;
  final FutureOr<void> Function()? onDelete;
  const Flashcard({
    super.key,
    required this.qna,
    this.onRatingSubmit,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<StatefulWidget> createState() {
    return FlashcardState();
  }
}

final List<String> ratingTexts = ['Bad', 'Decent', 'Good'];
final List<Color> ratingColors = [
  Colors.redAccent.shade100,
  Colors.yellowAccent.shade100,
  Colors.greenAccent.shade100,
];

enum _FlashcardStates { normal, editing, deleting }

class FlashcardState extends State<Flashcard> {
  bool _reveal = false;
  bool _loading = false;
  _FlashcardStates _state = _FlashcardStates.normal;

  final TextEditingController _answerController = TextEditingController(),
      _questionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  void _setReveal() {
    setState(() => _reveal = true);
  }

  void _setEditMode() {
    setState(() {
      _state = _FlashcardStates.editing;
      _answerController.text = widget.qna.answer;
      _questionController.text = widget.qna.question;
    });
  }

  void _setDeleteMode() {
    setState(() => _state = _FlashcardStates.deleting);
  }

  Future<void> _rating(int rating) async {
    setState(() => _loading = true);
    await widget.onRatingSubmit?.call(rating);
    setState(() {
      _loading = false;
      _reveal = false;
    });
  }

  void _cancel() {
    setState(() {
      _state = _FlashcardStates.normal;
      _reveal = false;
    });
  }

  Future<void> _formSubmit() async {
    var formState = _formKey.currentState!;
    if (formState.validate()) {
      setState(() => _loading = true);
      await widget.onEdit?.call(
        _questionController.text,
        _answerController.text,
      );
      setState(() => _loading = false);
      _cancel();
    }
  }

  Future<void> _delete() async {
    setState(() => _loading = true);
    await widget.onDelete?.call();
    setState(() => _loading = false);
    _cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: switch (_state) {
            _FlashcardStates.normal => [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  IconButton(onPressed: _setEditMode, icon: Icon(Icons.edit)),
                  Text(widget.qna.question, style: theme.textTheme.titleMedium),
                  IconButton(
                    onPressed: _setDeleteMode,
                    icon: Icon(Icons.delete, color: Colors.redAccent.shade200),
                  ),
                ],
              ),
              if (_reveal) ...[
                Text(widget.qna.answer),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    for (var i = 0; i < 3; i++)
                      ElevatedButton(
                        onPressed: !_loading ? () => _rating(i) : null,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateColor.resolveWith(
                            (_) => ratingColors[i],
                          ),
                        ),
                        child: Text(ratingTexts[i]),
                      ),
                  ],
                ),
              ],
              if (!_reveal)
                TextButton(onPressed: _setReveal, child: Text("Reveal")),
            ],
            _FlashcardStates.editing => [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _questionController,
                      decoration: InputDecoration(labelText: 'Question'),
                      validator: emptyFieldValidator('question'),
                      readOnly: _loading,
                    ),
                    TextFormField(
                      controller: _answerController,
                      decoration: InputDecoration(labelText: 'Answer'),
                      validator: emptyFieldValidator('answer'),
                      readOnly: _loading,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  IconButton(
                    onPressed: !_loading ? _cancel : null,
                    icon: Icon(Icons.close, color: Colors.redAccent.shade200),
                  ),
                  IconButton(
                    onPressed: !_loading ? _formSubmit : null,
                    icon: Icon(Icons.done, color: Colors.greenAccent.shade200),
                  ),
                ],
              ),
            ],
            _FlashcardStates.deleting => [
              Text('Are you sure?'),
              Text('This action cannot be undone!'),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  IconButton(
                    onPressed: !_loading ? _cancel : null,
                    icon: Icon(Icons.close),
                  ),
                  IconButton(
                    onPressed: !_loading ? _delete : null,
                    icon: Icon(Icons.delete, color: Colors.red.shade200),
                  ),
                ],
              ),
            ],
          },
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
  final TextEditingController _question = TextEditingController(),
      _answer = TextEditingController();
  bool? _loading;

  Future<void> _addPressed() async {
    final state = _formKey.currentState!;
    state.save();
    if (state.validate()) {
      setState(() => _loading = true);
      await widget.onAddFlashcard?.call(
        Qna(question: _question.text, answer: _answer.text),
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
              controller: _question,
              decoration: const InputDecoration(labelText: "Question"),
              validator: emptyFieldValidator("question"),
            ),
            TextFormField(
              controller: _answer,
              decoration: const InputDecoration(labelText: "Answer"),
              validator: emptyFieldValidator("answer"),
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

class FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  List<FlashcardData>? _flashcards;
  int _flashcardIndex = 0;
  late TabController _tabController;

  void _updateFlashcardIndex(int index) {
    if (index >= 0 && index < _flashcards!.length) {
      _tabController.index = _flashcards![index].rating ?? 0;
    }
    setState(() => _flashcardIndex = index);
  }

  Future<void> _loadFlashcards() async {
    setState(() {
      _flashcards = null;
      _flashcardIndex = 0;
      _tabController.index = 0;
    });
    final data = await FlashcardData.selectGroupWithRatingSort(widget.group.id);
    setState(() => _flashcards = data);
    _updateFlashcardIndex(0);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFlashcards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onAddFlashcard(Qna qna) async {
    final data = await FlashcardData.insert(
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
    final current = _flashcards![_flashcardIndex];
    await FlashcardData.setRating(current.id, rating);
    _updateFlashcardIndex(_flashcardIndex + 1);
  }

  Future<void> _onEdit(String question, String answer) async {
    final current = _flashcards![_flashcardIndex];
    await FlashcardData.update(current.id, question: question, answer: answer);
    setState(
      () => _flashcards![_flashcardIndex] = FlashcardData(
        id: current.id,
        answer: answer,
        question: question,
        rating: current.rating,
        groupId: current.groupId,
      ),
    );
  }

  Future<void> _onDelete() async {
    final current = _flashcards![_flashcardIndex];
    await FlashcardData.delete(current.id);
    setState(() => _flashcards!.removeAt(_flashcardIndex));
  }

  void Function()? _createMoveLeft() {
    if (_flashcardIndex <= 0) return null;
    return () => _updateFlashcardIndex(_flashcardIndex - 1);
  }

  void Function()? _createMoveRight() {
    if (_flashcards == null || _flashcardIndex >= _flashcards!.length - 1) {
      return null;
    }
    return () => _updateFlashcardIndex(_flashcardIndex + 1);
  }

  void _moveRating(int rating) {
    if (_flashcards == null) return;
    for (var i = 0; i < _flashcards!.length; i++) {
      final flashcard = _flashcards![i];
      if (rating == (flashcard.rating ?? 0)) {
        setState(() => _flashcardIndex = i);
        return;
      }
    }
    _updateFlashcardIndex(_flashcardIndex);
  }

  Widget buildFlashcard(BuildContext context) {
    final current = _flashcards![_flashcardIndex];
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        TabBar.secondary(
          controller: _tabController,
          onTap: _moveRating,
          tabs: [for (var i = 0; i < 3; i++) Tab(text: ratingTexts[i])],
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: _createMoveLeft(),
                ),
                Flashcard(
                  qna: Qna(answer: current.answer, question: current.question),
                  onRatingSubmit: _onRatingSubmit,
                  onEdit: _onEdit,
                  onDelete: _onDelete,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: _createMoveRight(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.group.title),
      ),
      body: Center(
        child: _flashcards != null
            ? _flashcards!.isNotEmpty
                  ? _flashcardIndex < _flashcards!.length
                        ? buildFlashcard(context)
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
