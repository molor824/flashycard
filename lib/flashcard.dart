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

String? Function(String?) _emptyFieldValidator(String name) {
  return (String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter $name";
    }
    return null;
  };
}

class FlashcardDialogWidget extends StatefulWidget {
  final void Function(Flashcard flashcard)? onAddFlashcard;
  const FlashcardDialogWidget({super.key, this.onAddFlashcard});

  @override
  State<StatefulWidget> createState() => FlashcardDialogState();
}

class FlashcardDialogState extends State<FlashcardDialogWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? answer, question;

  void addPressed(BuildContext context) {
    var state = _formKey.currentState!;
    state.save();
    if (state.validate()) {
      widget.onAddFlashcard?.call(
        Flashcard(question: question!, answer: answer!),
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
          onPressed: () => addPressed(context),
          child: Text("Add"),
        ),
      ],
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Question"),
              validator: _emptyFieldValidator("Question"),
              onSaved: (newQuestion) => question = newQuestion,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Answer"),
              validator: _emptyFieldValidator("Answer"),
              onSaved: (newAnswer) => answer = newAnswer,
            ),
          ],
        ),
      ),
    );
  }
}
