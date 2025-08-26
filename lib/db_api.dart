import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String dbName = 'flashycard_database.db';
const String rowid = 'id';
late Database _db;

Future<void> dbSetup() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final path = join(await getDatabasesPath(), dbName);

  if (kDebugMode) {
    await deleteDatabase(path);
  }

  _db = await openDatabase(
    path,
    onCreate: (db, _) async {
      await FlashcardData.createTable(db);
      await FlashcardGroupData.createTable(db);
    },
    onUpgrade: (db, _, _) async {
      await db.execute('DROP TABLE $flashcardTableName');
      await db.execute('DROP TABLE $groupTableName');
      await FlashcardData.createTable(db);
      await FlashcardGroupData.createTable(db);
    },
    version: 2,
  );
}

class FlashcardInput {
  final int groupId;
  final String question, answer;
  final int rating;
  const FlashcardInput({
    required this.groupId,
    required this.question,
    required this.answer,
    required this.rating,
  });

  Map<String, Object?> toMap() => {
    flashcardGroupIdName: groupId,
    flashcardAnswerName: answer,
    flashcardQuestionName: question,
    flashcardRatingName: rating,
  };
}

const String flashcardTableName = 'flashcard';
const String flashcardGroupIdName = 'groupId';
const String flashcardAnswerName = 'answer';
const String flashcardQuestionName = 'question';
const String flashcardRatingName = 'rating';

class FlashcardData {
  final int id;
  final int groupId;
  final String question, answer;
  final int rating;
  FlashcardData({
    required this.groupId,
    required this.question,
    required this.answer,
    required this.id,
    required this.rating,
  });

  static Future<void> createTable(Database db) {
    return db.execute('''CREATE TABLE $flashcardTableName(
      $rowid INTEGER PRIMARY KEY,
      $flashcardGroupIdName INTEGER,
      $flashcardAnswerName TEXT,
      $flashcardQuestionName TEXT,
      $flashcardRatingName INTEGER
    )''');
  }

  static Future<List<FlashcardData>> selectGroupWithRatingSort(
    int groupId,
  ) async {
    final flashcards = await _db.query(
      flashcardTableName,
      where: '$flashcardGroupIdName = $groupId',
      orderBy: '$flashcardRatingName ASC',
    );
    return [
      for (final {
            rowid: id as int?,
            flashcardGroupIdName: groupId as int?,
            flashcardQuestionName: question as String?,
            flashcardAnswerName: answer as String?,
            flashcardRatingName: rating as int?,
          }
          in flashcards)
        if (id != null &&
            groupId != null &&
            question != null &&
            answer != null &&
            rating != null)
          FlashcardData(
            id: id,
            groupId: groupId,
            question: question,
            answer: answer,
            rating: rating,
          ),
    ];
  }

  static Future<void> update(
    int id, {
    String? question,
    String? answer,
    int? rating,
  }) async {
    await _db.update(flashcardTableName, {
      if (rating != null) flashcardRatingName: rating,
      if (answer != null) flashcardAnswerName: answer,
      if (question != null) flashcardQuestionName: question,
    }, where: '$rowid = $id');
  }

  static Future<FlashcardData> insert(FlashcardInput input) async {
    final id = await _db.insert(flashcardTableName, input.toMap());
    return FlashcardData(
      groupId: input.groupId,
      question: input.question,
      answer: input.answer,
      rating: input.rating,
      id: id,
    );
  }

  static Future<void> delete(int id) async {
    await _db.delete(flashcardTableName, where: '$rowid = $id');
  }

  static Future<void> deleteAllInGroup(int groupId) async {
    await _db.delete(
      flashcardTableName,
      where: '$flashcardGroupIdName = $groupId',
    );
  }
}

class FlashcardGroupInput {
  final String title;
  final String description;
  const FlashcardGroupInput({required this.description, required this.title});

  Map<String, Object?> toMap() => {
    groupTitleName: title,
    groupDescriptionName: description,
  };
}

const groupTableName = 'flashcardGroup';
const groupTitleName = 'title';
const groupDescriptionName = 'description';

class FlashcardGroupData {
  final int id;
  final String title;
  final String description;
  FlashcardGroupData({
    required this.description,
    required this.title,
    required this.id,
  });

  static Future<void> createTable(Database db) {
    return db.execute('''CREATE TABLE $groupTableName(
      $rowid INTEGER PRIMARY KEY,
      $groupTitleName TEXT,
      $groupDescriptionName TEXT
    )''');
  }

  static Future<void> update(
    int id, {
    String? title,
    String? description,
  }) async {
    await _db.update(groupTableName, {
      groupTitleName: title,
      groupDescriptionName: description,
    }, where: '$rowid = $id');
  }

  static Future<void> delete(int id) async {
    await FlashcardData.deleteAllInGroup(id);
    await _db.delete(groupTableName, where: '$rowid = $id');
  }

  static Future<List<FlashcardGroupData>> selectAll() async {
    final queries = await _db.query(groupTableName);
    return [
      for (final {
            rowid: id as int?,
            groupTitleName: title as String?,
            groupDescriptionName: description as String?,
          }
          in queries)
        if (id != null && title != null && description != null)
          FlashcardGroupData(id: id, title: title, description: description),
    ];
  }

  static Future<FlashcardGroupData> insert(FlashcardGroupInput input) async {
    final id = await _db.insert(groupTableName, input.toMap());
    return FlashcardGroupData(
      title: input.title,
      id: id,
      description: input.description,
    );
  }
}
