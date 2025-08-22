import 'dart:async';

import 'package:flashycard/db_api.dart';
import 'package:flashycard/validator.dart';
import 'package:flutter/material.dart';

class FlashcardGroupCard extends StatefulWidget {
  final FlashcardGroupData group;
  final void Function() onPressed;
  final FutureOr<void> Function(String title, String? description) onEdit;
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
  String? _titleInput, _descriptionInput;
  _FlashcardState _state = _FlashcardState.normal;
  bool _loading = false;

  void _onPressed() {
    if (_state != _FlashcardState.normal) {
      setState(() => _state = _FlashcardState.normal);
    } else {
      widget.onPressed();
    }
  }

  void _onEditPressed() {
    setState(() => _state = _FlashcardState.edit);
  }

  void _onDeletePressed() {
    setState(() => _state = _FlashcardState.delete);
  }

  Future<void> _onSubmitPressed() async {
    final formState = _formKey.currentState!;

    formState.save();
    if (!formState.validate()) return;

    setState(() => _loading = true);
    await widget.onEdit(_titleInput!, _descriptionInput);
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
        onTap: !_loading ? _onPressed : null,
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: switch (_state) {
              _FlashcardState.normal => [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.title, style: theme.textTheme.titleLarge),
                    Text(
                      group.description ?? "",
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
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  ],
                ),
              ],
              _FlashcardState.edit => [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: "Title"),
                        validator: emptyFieldValidator("title"),
                        initialValue: _titleInput ?? group.title,
                        onSaved: (v) => _titleInput = v,
                        readOnly: _loading,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Description"),
                        initialValue: _descriptionInput ?? group.description,
                        onSaved: (v) => _descriptionInput = v,
                        readOnly: _loading,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: !_loading ? _onCancelPressed : null,
                      icon: Icon(Icons.close, color: Colors.redAccent),
                    ),
                    IconButton(
                      onPressed: !_loading ? _onSubmitPressed : null,
                      icon: Icon(Icons.done, color: Colors.greenAccent),
                    ),
                  ],
                ),
              ],
              _FlashcardState.delete => [
                Column(
                  children: [
                    Text("Are you sure?"),
                    Text(
                      "This change is permanent, and will remove every flashcards within the group",
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
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
  final FutureOr<void> Function(String, String?)? onGroupAdd;
  const CreateGroupDialog({super.key, this.onGroupAdd});

  @override
  State<StatefulWidget> createState() => CreateGroupDialogState();
}

class CreateGroupDialogState extends State<CreateGroupDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? _name, _description;
  bool? _loading;

  Future<void> _addGroup() async {
    final state = _formKey.currentState!;
    state.save();
    if (state.validate()) {
      setState(() => _loading = true);
      await widget.onGroupAdd?.call(_name!, _description);
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
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Group Name"),
              validator: emptyFieldValidator("group name"),
              onSaved: (value) => _name = value,
              readOnly: _loading == null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Description"),
              onSaved: (value) => _description = value,
              keyboardType: TextInputType.multiline,
              readOnly: _loading == null,
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
