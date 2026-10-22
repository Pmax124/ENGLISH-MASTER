import 'package:flutter/material.dart';
import '../models/topic.dart';
import '../models/vocabulary.dart';
import '../services/firebase_service.dart';

class VocabularyDetailPage extends StatefulWidget {
  final Topic topic;

  const VocabularyDetailPage({super.key, required this.topic});

  @override
  State<VocabularyDetailPage> createState() => _VocabularyDetailPageState();
}

class _VocabularyDetailPageState extends State<VocabularyDetailPage> {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentIndex = 0;
  bool _showMeaning = false;
  List<Vocabulary> _vocabularies = [];

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  void _loadVocabulary() {
    _firebaseService.getVocabularyByTopic(widget.topic.id).listen((vocabList) {
      setState(() {
        _vocabularies = vocabList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(widget.topic.color.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.topic.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${_vocabularies.length} từ vựng',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz, color: Colors.white),
            onPressed: () => _startQuiz(context),
            tooltip: 'Làm quiz',
          ),
        ],
      ),
      body: _vocabularies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        '${_currentIndex + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const Text(' / ', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${_vocabularies.length}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / _vocabularies.length,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildVocabCard(color),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavButton(
                        icon: Icons.arrow_back,
                        label: 'Trước',
                        color: color,
                        onPressed: _currentIndex > 0
                            ? () {
                                setState(() {
                                  _currentIndex--;
                                  _showMeaning = false;
                                });
                              }
                            : null,
                      ),
                      _buildNavButton(
                        icon: _showMeaning ? Icons.visibility_off : Icons.visibility,
                        label: _showMeaning ? 'Ẩn nghĩa' : 'Xem nghĩa',
                        color: color,
                        onPressed: () {
                          setState(() {
                            _showMeaning = !_showMeaning;
                          });
                        },
                      ),
                      _buildNavButton(
                        icon: Icons.arrow_forward,
                        label: 'Sau',
                        color: color,
                        onPressed: _currentIndex < _vocabularies.length - 1
                            ? () {
                                setState(() {
                                  _currentIndex++;
                                  _showMeaning = false;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVocabCard(Color color) {
    final vocab = _vocabularies[_currentIndex];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.topic.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  vocab.word,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vocab.pronunciation,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _showMeaning ? color.withValues(alpha: 0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Nghĩa tiếng Việt',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _showMeaning ? vocab.meaning : '???',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _showMeaning ? color : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.format_quote, color: color, size: 20),
                          const SizedBox(width: 4),
                          const Text(
                            'Câu ví dụ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        vocab.exampleSentence,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF333333),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        vocab.exampleTranslation,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: onPressed == null ? Colors.grey[200] : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: onPressed == null ? Colors.grey : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: onPressed == null ? Colors.grey : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context) {
    if (_vocabularies.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VocabularyQuizPage(
          topic: widget.topic,
          vocabularies: _vocabularies,
        ),
      ),
    );
  }
}

// ===== QUIZ PAGE FOR VOCABULARY =====
class VocabularyQuizPage extends StatefulWidget {
  final Topic topic;
  final List<Vocabulary> vocabularies;

  const VocabularyQuizPage({
    super.key,
    required this.topic,
    required this.vocabularies,
  });

  @override
  State<VocabularyQuizPage> createState() => _VocabularyQuizPageState();
}

class _VocabularyQuizPageState extends State<VocabularyQuizPage> {
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    _questions = [];

    for (int i = 0; i < widget.vocabularies.length && i < 10; i++) {
      final vocab = widget.vocabularies[i];
      final wrongMeanings = <String>[];

      for (int j = 0; j < widget.vocabularies.length; j++) {
        if (j != i && wrongMeanings.length < 3) {
          wrongMeanings.add(widget.vocabularies[j].meaning);
        }
      }
      while (wrongMeanings.length < 3) {
        wrongMeanings.add('Nghĩa khác ${wrongMeanings.length + 1}');
      }

      final options = [vocab.meaning, ...wrongMeanings]..shuffle();

      _questions.add({
        'word': vocab.word,
        'pronunciation': vocab.pronunciation,
        'example': vocab.exampleSentence.replaceAll(
          RegExp(vocab.word, caseSensitive: false),
          '_____'),
        'options': options,
        'correct': vocab.meaning,
        'explanation': '"${vocab.word}" means "${vocab.meaning}"',
      });
    }

    _questions.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(widget.topic.color.replaceFirst('#', '0xFF')));
    final question = _questions[_currentQuestion];
    final options = List<String>.from(question['options']);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: color,
        elevation: 0,
        title: const Text('Quiz', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⭐ $_score',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Câu ${_currentQuestion + 1}/${_questions.length}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentQuestion + 1) / _questions.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Từ này có nghĩa là gì?',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question['word'] as String,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question['pronunciation'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '"${question['example']}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(options.length, (index) {
                      final isSelected = _selectedAnswer == index;
                      final isCorrect = options[index] == question['correct'];
                      Color borderColor;
                      Color bgColor;

                      if (_answered) {
                        if (isCorrect) {
                          borderColor = Colors.green;
                          bgColor = Colors.green.withValues(alpha: 0.1);
                        } else if (isSelected) {
                          borderColor = Colors.red;
                          bgColor = Colors.red.withValues(alpha: 0.1);
                        } else {
                          borderColor = Colors.grey[300]!;
                          bgColor = Colors.white;
                        }
                      } else {
                        borderColor = isSelected ? color : Colors.grey[300]!;
                        bgColor = isSelected ? color.withValues(alpha: 0.1) : Colors.white;
                      }

                      return InkWell(
                        onTap: _answered ? null : () {
                          setState(() {
                            _selectedAnswer = index;
                            _answered = true;
                            if (isCorrect) _score++;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border.all(color: borderColor, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: borderColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _answered && isCorrect
                                        ? Colors.green[800]
                                        : _answered && isSelected && !isCorrect
                                            ? Colors.red[800]
                                            : const Color(0xFF333333),
                                  ),
                                ),
                              ),
                              if (_answered && isCorrect)
                                const Icon(Icons.check_circle, color: Colors.green, size: 22),
                              if (_answered && isSelected && !isCorrect)
                                const Icon(Icons.cancel, color: Colors.red, size: 22),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (_answered) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          question['explanation'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.blue[800]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _answered
                    ? () {
                        if (_currentQuestion < _questions.length - 1) {
                          setState(() {
                            _currentQuestion++;
                            _selectedAnswer = null;
                            _answered = false;
                          });
                        } else {
                          _showResult(context, color);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  _currentQuestion < _questions.length - 1 ? 'Câu tiếp theo' : 'Xem kết quả',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResult(BuildContext context, Color color) {
    final percent = (_score / _questions.length * 100).round();
    String message;
    IconData icon;

    if (percent >= 80) {
      message = 'Xuất sắc! ';
      icon = Icons.emoji_events;
    } else if (percent >= 60) {
      message = 'Tốt lắm! 👍';
      icon = Icons.thumb_up;
    } else {
      message = 'Cần cố gắng hơn! 💪';
      icon = Icons.fitness_center;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn trả lời đúng $_score/${_questions.length} câu',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Về trang chủ đề'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestion = 0;
                _score = 0;
                _selectedAnswer = null;
                _answered = false;
                _generateQuestions();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('Làm lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}