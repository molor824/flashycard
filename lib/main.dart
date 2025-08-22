import 'dart:async';

import 'package:flashycard/db_api.dart';
import 'package:flashycard/flashcard.dart';
import 'package:flashycard/flashcard_group.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await dbSetup();
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FlashcardGroupData>? _groups;

  Future<void> _loadGroups() async {
    setState(() => _groups = null);
    final value = await FlashcardGroupData.selectAll();
    setState(() => _groups = value);
  }

  @override
  void initState() {
    _loadGroups();
    super.initState();
  }

  Future<void> _onAddGroup(String title, String? description) async {
    final data = await FlashcardGroupData.insert(
      FlashcardGroupInput(title: title, description: description),
    );
    setState(() => _groups?.add(data));
  }

  Future<void> _showAddDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => CreateGroupDialog(onGroupAdd: _onAddGroup),
    );
  }

  Future<void> _onEdit(
    FlashcardGroupData group,
    String title,
    String? description,
  ) async {
    await FlashcardGroupData.update(
      group.id,
      title: title,
      description: description,
    );

    setState(() {
      final index = _groups!.indexOf(group);
      _groups![index] = FlashcardGroupData(
        title: title,
        description: description,
        id: group.id,
      );
    });
  }

  Future<void> _onDelete(FlashcardGroupData group) async {
    await FlashcardGroupData.delete(group.id);

    setState(() {
      final index = _groups!.indexOf(group);
      _groups!.removeAt(index);
    });
  }

  void _selectGroup(BuildContext context, FlashcardGroupData group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => FlashcardPage(group: group)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: _groups != null
            ? _groups!
                  .map(
                    (group) => FlashcardGroupCard(
                      group: group,
                      onPressed: () => _selectGroup(context, group),
                      onEdit: (title, description) =>
                          _onEdit(group, title, description),
                      onDelete: () => _onDelete(group),
                    ),
                  )
                  .toList()
            : const [CircularProgressIndicator()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
