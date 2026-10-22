import 'quiz_question.dart';

class QuizSession {
  final String id;
  final String title;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  int currentIndex;
  int score;
  List<int?> userAnswers;

  QuizSession({
    required this.id,
    required this.title,
    required this.questions,
    required this.createdAt,
    this.currentIndex = 0,
    this.score = 0,
  }) : userAnswers = List.filled(questions.length, null);

  bool get isCompleted => currentIndex >= questions.length;
  double get progress => questions.isEmpty ? 0 : currentIndex / questions.length;
  double get scorePercent => questions.isEmpty ? 0 : (score / questions.length) * 100;
}