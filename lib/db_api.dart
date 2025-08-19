import 'dart:math';

final List<FlashcardGroupData> _sampleGroupData = [
  FlashcardGroupData(
    id: 1,
    title: "Japanese",
    description: "Japanese vocab list",
  ),
  FlashcardGroupData(id: 2, title: "Driving school"),
];
final List<FlashcardData> _sampleFlashcardData = [
  FlashcardData(id: 1, groupId: 1, question: "日本", answer: "にほん - Japan"),
  FlashcardData(
    id: 2,
    groupId: 1,
    question: "フラッシュカード",
    answer: "ふらっしゅかーど - Flashcard",
  ),
  FlashcardData(
    id: 3,
    groupId: 2,
    question: "Equal road intersection rule name",
    answer: "Right-hand rule",
    rating: 2,
  ),
  FlashcardData(
    id: 4,
    groupId: 2,
    question: "Speed limit for regular roads for regular cars",
    answer: "60km/h",
  ),
];

class FlashcardInput {
  final int groupId;
  final String question, answer;
  const FlashcardInput({
    required this.groupId,
    required this.question,
    required this.answer,
  });
}

class FlashcardData {
  final int id;
  final int groupId;
  final String question, answer;
  final int rating;
  const FlashcardData({
    required this.id,
    required this.groupId,
    required this.question,
    required this.answer,
    this.rating = 0,
  });

  static List<FlashcardData> selectGroupWithRatingSort(int groupId) {
    List<FlashcardData> flashcards = _sampleFlashcardData
        .where((e) => e.groupId == groupId)
        .toList();
    flashcards.sort((a, b) => a.rating.compareTo(b.rating));
    return flashcards;
  }

  static void updateRating(int id, int rating) {
    var index = _sampleFlashcardData.indexWhere((e) => e.id == id);
    var data = _sampleFlashcardData[index];
    _sampleFlashcardData[index] = FlashcardData(
      id: data.id,
      groupId: data.groupId,
      question: data.question,
      answer: data.answer,
      rating: rating,
    );
  }

  static void insert(FlashcardInput input) {
    var currentCounter = _sampleFlashcardData.fold(0, (n, e) => max(n, e.id));
    _sampleFlashcardData.add(
      FlashcardData(
        id: currentCounter + 1,
        groupId: input.groupId,
        question: input.question,
        answer: input.answer,
      ),
    );
  }
}

class FlashcardGroupInput {
  final String title;
  final String? description;
  const FlashcardGroupInput({this.description, required this.title});
}

class FlashcardGroupData {
  final int id;
  final String title;
  final String? description;
  const FlashcardGroupData({
    this.description,
    required this.title,
    required this.id,
  });

  static List<FlashcardGroupData> selectAll() {
    return _sampleGroupData;
  }

  static void insert(FlashcardGroupInput input) {
    var currentCounter = _sampleGroupData.fold(0, (n, e) => max(n, e.id));
    _sampleGroupData.add(
      FlashcardGroupData(
        title: input.title,
        id: currentCounter + 1,
        description: input.description,
      ),
    );
  }
}
