import 'dart:async';

import 'package:flashycard/db_api.dart';
import 'package:flashycard/validator.dart';
import 'package:flutter/material.dart';

class FlashcardGroupCard extends StatefulWidget {
  final FlashcardGroupData group;
  final void Function() onPressed;
  final FutureOr<void> Function(String title, String description) onEdit;
  final FutureOr<void> Function() onDelete;
  const FlashcardGroupCard({
    super.key,
    required this.group,
    required this.onPressed,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<FlashcardGroupCard> createState() => _FlashcardGroupCardState();
}

enum _FlashcardState { normal, edit, delete }

class _FlashcardGroupCardState extends State<FlashcardGroupCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  _FlashcardState _state = _FlashcardState.normal;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.group.title;
    _descriptionController.text = widget.group.description;
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
  }

  void _onEditPressed() {
    setState(() => _state = _FlashcardState.edit);
  }

  void _onDeletePressed() {
    setState(() => _state = _FlashcardState.delete);
  }

  Future<void> _onSubmitPressed() async {
    final formState = _formKey.currentState!;

    if (!formState.validate()) return;

    setState(() => _loading = true);
    await widget.onEdit(_titleController.text, _descriptionController.text);
    setState(() {
      _state = _FlashcardState.normal;
      _loading = false;
    });
  }

  Future<void> _onDeleteConfirmed() async {
    setState(() => _loading = true);
    await widget.onDelete();
    setState(() => _loading = false);
  }

  void _onCancelPressed() {
    setState(() => _state = _FlashcardState.normal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = widget.group;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: !_loading && _state == _FlashcardState.normal
            ? widget.onPressed
            : null,
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 32,
            children: switch (_state) {
              _FlashcardState.normal => [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.title, style: theme.textTheme.titleLarge),
                    Text(
                      group.description,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: !_loading ? _onEditPressed : null,
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: !_loading ? _onDeletePressed : null,
                      icon: Icon(
                        Icons.delete,
                        color: Colors.redAccent.shade200,
                      ),
                    ),
                  ],
                ),
              ],
              _FlashcardState.edit => [
                Flexible(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(labelText: "Title"),
                          validator: emptyFieldValidator("title"),
                          readOnly: _loading,
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: "Description"),
                          readOnly: _loading,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: !_loading ? _onCancelPressed : null,
                      icon: Icon(Icons.close, color: Colors.redAccent.shade200),
                    ),
                    IconButton(
                      onPressed: !_loading ? _onSubmitPressed : null,
                      icon: Icon(
                        Icons.done,
                        color: Colors.greenAccent.shade200,
                      ),
                    ),
                  ],
                ),
              ],
              _FlashcardState.delete => [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Are you sure?", style: theme.textTheme.titleLarge),
                      Text(
                        "This change is permanent, and will remove every flashcards within the group",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: !_loading ? _onCancelPressed : null,
                      icon: Icon(Icons.close),
                    ),
                    IconButton(
                      onPressed: !_loading ? _onDeleteConfirmed : null,
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  ],
                ),
              ],
            },
          ),
        ),
      ),
    );
  }
}

class CreateGroupDialog extends StatefulWidget {
  final FutureOr<void> Function(String, String)? onGroupAdd;
  const CreateGroupDialog({super.key, this.onGroupAdd});

  @override
  State<StatefulWidget> createState() => CreateGroupDialogState();
}

class CreateGroupDialogState extends State<CreateGroupDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _name = TextEditingController(),
      _description = TextEditingController();
  bool? _loading;

  Future<void> _addGroup() async {
    final state = _formKey.currentState!;
    state.save();
    if (state.validate()) {
      setState(() => _loading = true);
      await widget.onGroupAdd?.call(_name.text, _description.text);
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading == false) {
      Navigator.of(context).pop();
    }
    return AlertDialog(
      title: const Text("Create new flashcard group"),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: "Group Name"),
              validator: emptyFieldValidator("group name"),
              readOnly: _loading != null,
            ),
            TextFormField(
              controller: _description,
              decoration: InputDecoration(labelText: "Description"),
              readOnly: _loading != null,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _loading == null ? _addGroup : null,
          child: Text("Add"),
        ),
      ],
    );
  }
}
