import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/quiz_question.dart';

class QuizPlayPage extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String title;
  final File? sourceImage;
  final String? sourceImageUrl;
  final Uint8List? sourceImageBytes;

  const QuizPlayPage({
    super.key,
    required this.questions,
    required this.title,
    this.sourceImage,
    this.sourceImageUrl,
    this.sourceImageBytes,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  final List<int?> _answers = [];

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Câu ${_currentIndex + 1}/${widget.questions.length}',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _confirmExit(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⭐ $_score',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            height: 6,
            color: Colors.grey[200],
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                color: const Color(0xFF9C27B0),
              ),
            ),
          ),

          // Source image (if any)
          // Hiển thị ảnh nguồn ở đầu quiz
if ((widget.sourceImage != null || widget.sourceImageBytes != null) && _currentIndex == 0)
  Container(
    margin: const EdgeInsets.all(16),
    height: 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: kIsWeb
          ? (widget.sourceImageBytes != null
              ? Image.memory(
                  widget.sourceImageBytes!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : const SizedBox())
          : (widget.sourceImage != null
              ? Image.file(
                  widget.sourceImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : const SizedBox()),
    ),
  ),

          // Question
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Câu hỏi ${_currentIndex + 1}',
                        style: const TextStyle(
                          color: Color(0xFF9C27B0),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      question.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(question.options.length, (index) {
                      final isSelected = _selectedAnswer == index;
                      final isCorrect = index == question.correctAnswerIndex;
                      Color borderColor;
                      Color bgColor;

                      if (_answered) {
                        if (isCorrect) {
                          borderColor = Colors.green;
                          bgColor = Colors.green.withOpacity(0.1);
                        } else if (isSelected) {
                          borderColor = Colors.red;
                          bgColor = Colors.red.withOpacity(0.1);
                        } else {
                          borderColor = Colors.grey[300]!;
                          bgColor = Colors.white;
                        }
                      } else {
                        borderColor = isSelected ? const Color(0xFF9C27B0) : Colors.grey[300]!;
                        bgColor = isSelected ? const Color(0xFF9C27B0).withOpacity(0.1) : Colors.white;
                      }

                      return InkWell(
                        onTap: _answered ? null : () {
                          setState(() {
                            _selectedAnswer = index;
                            _answered = true;
                            _answers.add(index);
                            if (isCorrect) _score++;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border.all(color: borderColor, width: 2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
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
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question.options[index],
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
                    if (_answered && question.explanation.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                question.explanation,
                                style: TextStyle(fontSize: 13, color: Colors.blue[800], height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _answered
                    ? () {
                        if (_currentIndex < widget.questions.length - 1) {
                          setState(() {
                            _currentIndex++;
                            _selectedAnswer = null;
                            _answered = false;
                          });
                        } else {
                          _showFinalResult(context);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  _currentIndex < widget.questions.length - 1 ? 'Câu tiếp theo →' : 'Xem kết quả 🏆',
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

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thoát quiz?'),
        content: const Text('Tiến trình của bạn sẽ bị mất.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục làm'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Thoát', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFinalResult(BuildContext context) {
    final percent = (_score / widget.questions.length * 100).round();
    String message, subMessage;
    IconData icon;
    Color iconColor;

    if (percent >= 90) {
      message = 'Xuất sắc! 🎉';
      subMessage = 'Bạn nắm rất vững kiến thức!';
      icon = Icons.emoji_events;
      iconColor = Colors.amber;
    } else if (percent >= 70) {
      message = 'Tốt lắm! 👏';
      subMessage = 'Còn một chút nữa là hoàn hảo!';
      icon = Icons.thumb_up;
      iconColor = Colors.green;
    } else if (percent >= 50) {
      message = 'Khá ổn! 💪';
      subMessage = 'Hãy ôn tập thêm nhé!';
      icon = Icons.school;
      iconColor = Colors.blue;
    } else {
      message = 'Cần cố gắng! 📚';
      subMessage = 'Đừng bỏ cuộc, hãy thử lại!';
      icon = Icons.fitness_center;
      iconColor = Colors.orange;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: iconColor),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subMessage,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResultStat('Đúng', '$_score', Colors.green),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _buildResultStat('Sai', '${widget.questions.length - _score}', Colors.red),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _buildResultStat('Tỷ lệ', '$percent%', iconColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Về trang chủ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentIndex = 0;
                          _score = 0;
                          _selectedAnswer = null;
                          _answered = false;
                          _answers.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Làm lại',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}