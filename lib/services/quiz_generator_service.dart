import '../models/quiz_question.dart';
import 'smart_ocr_service.dart';

class QuizGeneratorService {
  /// Parse text + tự động detect đáp án đúng từ vị trí màu đỏ
    /// Parse text + tự động detect đáp án đúng từ vị trí màu đỏ (CẢI TIẾN)
  static List<QuizQuestion> generateFromSmartOcr(
    String textContent,
    List<WordInfo> words,
  ) {
    final questions = <QuizQuestion>[];
    final lines = textContent.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    final questionPattern = RegExp(r'^(?:Question\s+)?(\d+)[\.\)]\s+(.+)$', caseSensitive: false);
    final optionPattern = RegExp(r'^([A-D])[\.\)]\s+(.+)$');
    
    String? currentQuestionText;
    List<String> currentOptions = [];
    List<int> currentOptionYPositions = []; // Lưu vị trí Y của mỗi option
    List<bool> currentOptionsRed = [];
    int questionNumber = 0;
    int currentLineIndex = 0;
    
    for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
      final line = lines[lineIdx];
      currentLineIndex = lineIdx;
      
      final qMatch = questionPattern.firstMatch(line);
      if (qMatch != null) {
        if (currentQuestionText != null) {
          questions.add(_buildQuestionImproved(
            currentQuestionText!,
            currentOptions,
            currentOptionsRed,
            currentOptionYPositions,
            words,
            questions.length,
          ));
        }
        questionNumber = int.parse(qMatch.group(1)!);
        currentQuestionText = qMatch.group(2);
        currentOptions = [];
        currentOptionYPositions = [];
        currentOptionsRed = [];
        continue;
      }
      
      final oMatch = optionPattern.firstMatch(line);
      if (oMatch != null && currentQuestionText != null) {
        final optionLetter = oMatch.group(1)!;
        final optionText = oMatch.group(2)!;
        
        // Tìm vị trí Y của dòng option này trong ảnh
        int optionY = _findOptionYPosition(words, optionLetter, optionText, lineIdx);
        
        // Check xem option này có màu đỏ không
        bool isRed = _checkIfOptionIsRed(words, optionLetter, optionText, optionY);
        
        currentOptions.add('$optionLetter. $optionText');
        currentOptionYPositions.add(optionY);
        currentOptionsRed.add(isRed);
        continue;
      }
      
      if (currentQuestionText != null && currentOptions.isEmpty) {
        currentQuestionText += ' $line';
      }
    }
    
    if (currentQuestionText != null) {
      questions.add(_buildQuestionImproved(
        currentQuestionText!,
        currentOptions,
        currentOptionsRed,
        currentOptionYPositions,
        words,
        questions.length,
      ));
    }
    
    return questions;
  }
  
  /// Tìm vị trí Y của option trong ảnh
  static int _findOptionYPosition(List<WordInfo> words, String letter, String text, int lineIndex) {
    // Tìm word chứa letter (A, B, C, D)
    for (final word in words) {
      if (word.text.toUpperCase() == '$letter.' || word.text.toUpperCase() == letter) {
        return word.bbox[1]; // Trả về y0
      }
    }
    return lineIndex * 20; // Fallback
  }
  
  /// Check xem option có màu đỏ không (cải tiến)
  static bool _checkIfOptionIsRed(List<WordInfo> words, String letter, String text, int optionY) {
    // Tìm tất cả word trong vùng của option này
    final optionWords = words.where((w) {
      final yCenter = (w.bbox[1] + w.bbox[3]) ~/ 2;
      // Check nếu word nằm trong cùng dòng với option (±10 pixels)
      return (yCenter - optionY).abs() < 15;
    }).toList();
    
    // Đếm số word màu đỏ trong option
    int redWordCount = 0;
    for (final word in optionWords) {
      if (word.isRed && word.redRatio > 0.15) {
        redWordCount++;
      }
    }
    
    // Nếu có ít nhất 1 word đỏ trong option → option đó là đáp án đúng
    return redWordCount > 0;
  }
  
  /// Build question với logic cải tiến
  static QuizQuestion _buildQuestionImproved(
    String questionText,
    List<String> options,
    List<bool> optionsRed,
    List<int> optionYPositions,
    List<WordInfo> words,
    int index,
  ) {
    // Tìm đáp án đúng (màu đỏ)
    int correctIndex = 0;
    for (int i = 0; i < optionsRed.length; i++) {
      if (optionsRed[i]) {
        correctIndex = i;
        break;
      }
    }
    
    while (options.length < 4) {
      options.add('Đáp án ${String.fromCharCode(65 + options.length)}');
    }
    
    final correctLetter = String.fromCharCode(65 + correctIndex);
    
    return QuizQuestion(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}_$index',
      question: questionText,
      options: options.take(4).toList(),
      correctAnswerIndex: correctIndex,
      explanation: 'Đáp án đúng: $correctLetter',
      sourceImage: 'uploaded_outline',
    );
  }
  
  /// Kiểm tra xem đáp án có màu đỏ không bằng cách tìm word trong danh sách
  static bool _isOptionRed(List<WordInfo> words, String letter, String text, String fullLine) {
    // Tìm word có text = letter (A, B, C, D) và check màu
    for (final word in words) {
      if (word.text.toUpperCase() == '$letter.' || word.text.toUpperCase() == letter) {
        // Kiểm tra màu của word này và các word xung quanh (vì đáp án đỏ có thể là "C. competitive")
        if (word.isRed) return true;
        
        // Check cả text của đáp án (vì đôi khi chỉ text đáp án màu đỏ, không phải letter)
        final textWords = text.split(' ');
        for (final tw in textWords) {
          for (final w in words) {
            if (w.text.toLowerCase() == tw.toLowerCase() && w.isRed) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }
  
  static QuizQuestion _buildQuestion(
    String questionText,
    List<String> options,
    List<bool> optionsRed,
    int index,
  ) {
    // Tìm đáp án đúng (màu đỏ)
    int correctIndex = 0;
    for (int i = 0; i < optionsRed.length; i++) {
      if (optionsRed[i]) {
        correctIndex = i;
        break;
      }
    }
    
    while (options.length < 4) {
      options.add('Đáp án ${String.fromCharCode(65 + options.length)}');
    }
    
    final correctLetter = String.fromCharCode(65 + correctIndex);
    
    return QuizQuestion(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}_$index',
      question: questionText,
      options: options.take(4).toList(),
      correctAnswerIndex: correctIndex,
      explanation: 'Đáp án đúng: $correctLetter (màu đỏ trong đề)',
      sourceImage: 'uploaded_outline',
    );
  }
  
  /// Parse text thường (không có màu) - trả về List<Map>
  static List<Map<String, dynamic>> parseQuestions(String textContent) {
    final questions = <Map<String, dynamic>>[];
    final lines = textContent.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    final questionPattern = RegExp(r'^(?:Question\s+)?(\d+)[\.\)]\s+(.+)$', caseSensitive: false);
    final optionPattern = RegExp(r'^([A-D])[\.\)]\s+(.+)$');
    
    String? currentQuestionText;
    List<String> currentOptions = [];
    int questionNumber = 0;
    
    for (final line in lines) {
      final qMatch = questionPattern.firstMatch(line);
      if (qMatch != null) {
        if (currentQuestionText != null) {
          questions.add({
            'number': questionNumber,
            'question': currentQuestionText!,
            'options': List<String>.from(currentOptions),
          });
        }
        questionNumber = int.parse(qMatch.group(1)!);
        currentQuestionText = qMatch.group(2);
        currentOptions = [];
        continue;
      }
      
      final oMatch = optionPattern.firstMatch(line);
      if (oMatch != null && currentQuestionText != null) {
        currentOptions.add('${oMatch.group(1)}. ${oMatch.group(2)}');
      }
    }
    
    if (currentQuestionText != null) {
      questions.add({
        'number': questionNumber,
        'question': currentQuestionText!,
        'options': List<String>.from(currentOptions),
      });
    }
    
    return questions;
  }
  
  /// Build QuizQuestion từ parsed data với đáp án đúng do user chọn
  static List<QuizQuestion> buildQuizQuestions(
    List<Map<String, dynamic>> parsedQuestions,
    List<int> correctAnswers, // correctAnswers[i] = index đáp án đúng của câu i (0=A, 1=B, 2=C, 3=D)
  ) {
    final questions = <QuizQuestion>[];
    
    for (int i = 0; i < parsedQuestions.length; i++) {
      final q = parsedQuestions[i];
      final options = List<String>.from(q['options'] as List);
      final correctIndex = i < correctAnswers.length ? correctAnswers[i] : 0;
      
      // Đảm bảo có đủ 4 đáp án
      while (options.length < 4) {
        options.add('Đáp án ${String.fromCharCode(65 + options.length)}');
      }
      
      final correctLetter = String.fromCharCode(65 + correctIndex);
      
      questions.add(QuizQuestion(
        id: 'q_${DateTime.now().millisecondsSinceEpoch}_$i',
        question: '${q['question']}',
        options: options.take(4).toList(),
        correctAnswerIndex: correctIndex,
        explanation: 'Đáp án đúng: $correctLetter',
        sourceImage: 'uploaded_outline',
      ));
    }
    
    return questions;
  }
  
  /// Fallback: tạo câu hỏi điền từ nếu không parse được
  static List<QuizQuestion> generateGeneralQuestions(String text) {
    final sentences = text.split(RegExp(r'[.!?]+')).where((s) => s.trim().length > 10).toList();
    final questions = <QuizQuestion>[];
    
    for (int i = 0; i < sentences.length && i < 5; i++) {
      final sentence = sentences[i].trim();
      final words = sentence.split(' ');
      if (words.length < 4) continue;
      
      final hideIndex = words.length ~/ 2;
      final hiddenWord = words[hideIndex];
      words[hideIndex] = '_____';
      
      final options = [hiddenWord, 'từ khác 1', 'từ khác 2', 'từ khác 3']..shuffle();
      
      questions.add(QuizQuestion(
        id: 'q_gen_$i',
        question: 'Điền từ: "${words.join(' ')}"',
        options: options,
        correctAnswerIndex: options.indexOf(hiddenWord),
        explanation: 'Đáp án: $hiddenWord',
      ));
    }
    return questions;
  }
}