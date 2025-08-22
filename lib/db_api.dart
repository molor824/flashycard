import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String dbName = 'flashycard_database.db';
const String rowid = 'id';
late Future<Database> _db;

Future<void> dbSetup() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  _db = openDatabase(
    join(await getDatabasesPath(), dbName),
    onCreate: (db, version) async {
      await FlashcardData.createTable(db);
      await FlashcardGroupData.createTable(db);
    },
    version: 1,
  );
}

class FlashcardInput {
  final int groupId;
  final String question, answer;
  const FlashcardInput({
    required this.groupId,
    required this.question,
    required this.answer,
  });

  Map<String, Object?> toMap() => {
    flashcardGroupIdName: groupId,
    flashcardAnswerName: answer,
    flashcardQuestionName: question,
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
  final int? rating;
  FlashcardData({
    required this.groupId,
    required this.question,
    required this.answer,
    required this.id,
    this.rating,
  });

  FlashcardData.fromMap(Map<String, Object?> map)
    : id = map[rowid] as int,
      groupId = map[flashcardGroupIdName] as int,
      answer = map[flashcardAnswerName] as String,
      question = map[flashcardQuestionName] as String,
      rating = map[flashcardRatingName] as int?;

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
    final db = await _db;
    final flashcards = await db.query(
      flashcardTableName,
      where: '$flashcardGroupIdName = $groupId',
      orderBy: '$flashcardRatingName ASC',
    );
    return [
      for (final {
            rowid: id as int,
            flashcardGroupIdName: groupId as int,
            flashcardQuestionName: question as String,
            flashcardAnswerName: answer as String,
            flashcardRatingName: rating as int?,
          }
          in flashcards)
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
    final db = await _db;
    await db.update(flashcardTableName, {
      flashcardRatingName: rating,
      flashcardAnswerName: answer,
      flashcardQuestionName: question,
    }, where: '$rowid = $id');
  }

  static Future<FlashcardData> insert(FlashcardInput input) async {
    final db = await _db;
    final id = await db.insert(flashcardTableName, input.toMap());
    return FlashcardData(
      groupId: input.groupId,
      question: input.question,
      answer: input.answer,
      id: id,
    );
  }

  static Future<void> delete(int id) async {
    final db = await _db;
    await db.delete(flashcardTableName, where: '$rowid = $id');
  }

  static Future<void> deleteAllInGroup(int groupId) async {
    final db = await _db;
    await db.delete(
      flashcardTableName,
      where: '$flashcardGroupIdName = $groupId',
    );
  }
}

class FlashcardGroupInput {
  final String title;
  final String? description;
  const FlashcardGroupInput({this.description, required this.title});

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
  final String? description;
  FlashcardGroupData({this.description, required this.title, required this.id});

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
    final db = await _db;
    await db.update(groupTableName, {
      groupTitleName: title,
      groupDescriptionName: description,
    }, where: '$rowid = $id');
  }

  static Future<void> delete(int id) async {
    final db = await _db;
    await FlashcardData.deleteAllInGroup(id);
    await db.delete(groupTableName, where: '$rowid = $id');
  }

  static Future<List<FlashcardGroupData>> selectAll() async {
    final db = await _db;
    final queries = await db.query(groupTableName);
    return [
      for (final {
            rowid: id as int,
            groupTitleName: title as String,
            groupDescriptionName: description as String?,
          }
          in queries)
        FlashcardGroupData(id: id, title: title, description: description),
    ];
  }

  static Future<FlashcardGroupData> insert(FlashcardGroupInput input) async {
    final db = await _db;
    final id = await db.insert(groupTableName, input.toMap());
    return FlashcardGroupData(
      title: input.title,
      id: id,
      description: input.description,
    );
  }
}
