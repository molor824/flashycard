import 'package:flashycard/flashcard.dart';
import 'package:flashycard/validator.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      ),
      home: const MyHomePage(title: 'Flashy Card'),
    );
  }
}

class FlashcardGroup {
  final String name;
  final String? description;
  const FlashcardGroup({required this.name, this.description});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<FlashcardGroup> _groups = [];

  void _onAddGroup(String name, String? description) {
    setState(
      () => _groups.add(FlashcardGroup(name: name, description: description)),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => CreateGroupDialog(onGroupAdd: _onAddGroup),
    );
  }

  void _selectGroup(BuildContext context, FlashcardGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => FlashcardPage(title: group.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: _groups
            .map(
              (group) => FlashcardGroupCard(
                group: group,
                onPressed: (context) => _selectGroup(context, group),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

class FlashcardGroupCard extends StatelessWidget {
  final FlashcardGroup group;
  final void Function(BuildContext) onPressed;
  const FlashcardGroupCard({
    super.key,
    required this.group,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: theme.textTheme.titleLarge),
                Text(
                  group.description ?? "",
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
            IconButton(
              onPressed: () => onPressed(context),
              icon: const Icon(Icons.arrow_right),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateGroupDialog extends StatefulWidget {
  final void Function(String, String?)? onGroupAdd;
  const CreateGroupDialog({super.key, this.onGroupAdd});

  @override
  State<StatefulWidget> createState() => CreateGroupDialogState();
}

class CreateGroupDialogState extends State<CreateGroupDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? _name, _description;

  void _addGroup(BuildContext context) {
    var state = _formKey.currentState!;
    state.save();
    if (state.validate()) {
      widget.onGroupAdd?.call(_name!, _description);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create new flashcard group"),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Group Name"),
              validator: emptyFieldValidator("group name"),
              onSaved: (value) => _name = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Description"),
              onSaved: (value) => _description = value,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => _addGroup(context),
          child: const Text("Add"),
        ),
      ],
    );
  }
}
