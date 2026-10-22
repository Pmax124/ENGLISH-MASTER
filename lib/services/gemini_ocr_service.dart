import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/quiz_question.dart';

class GeminiOcrService {
  // Thay bằng API key của bạn
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  static const String _apiUrl = 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Gửi ảnh lên Gemini và nhận về câu hỏi + đáp án đúng
  static Future<List<QuizQuestion>> analyzeImage(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      
      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'inline_data': {
                  'mime_type': 'image/png',
                  'data': base64Image,
                }
              },
              {
                'text': '''
Phân tích ảnh đề cương trắc nghiệm tiếng Anh này. Với mỗi câu hỏi, xác định:
1. Nội dung câu hỏi (giữ nguyên text gốc)
2. 4 đáp án A, B, C, D (giữ nguyên text gốc)
3. Đáp án ĐÚNG (là đáp án có chữ màu ĐỎ trong ảnh)

Trả về JSON format sau (CHỈ trả về JSON, không thêm text khác):
{
  "questions": [
    {
      "number": 1,
      "question": "Question text here",
      "options": ["A. option1", "B. option2", "C. option3", "D. option4"],
      "correctAnswerIndex": 2,
      "explanation": "Đáp án C là đúng"
    }
  ]
}

Lưu ý:
- correctAnswerIndex: 0=A, 1=B, 2=C, 3=D
- Giữ nguyên text tiếng Anh, không dịch
- Nếu không thấy màu đỏ, đoán đáp án đúng nhất
'''
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'maxOutputTokens': 4096,
        }
      };

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        return _parseGeminiResponse(text);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gemini API error: $e');
    }
  }

  static List<QuizQuestion> _parseGeminiResponse(String responseText) {
    try {
      // Tìm JSON trong response
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No JSON found in response');
      }
      
      final jsonStr = responseText.substring(jsonStart, jsonEnd);
      final data = jsonDecode(jsonStr);
      final questionsList = data['questions'] as List;
      
      return questionsList.map((q) {
        final options = List<String>.from(q['options'] ?? []);
        final correctIndex = (q['correctAnswerIndex'] ?? 0) as int;
        
        return QuizQuestion(
          id: 'gemini_${DateTime.now().millisecondsSinceEpoch}_${q['number']}',
          question: q['question'] ?? '',
          options: options.length >= 4 ? options : [...options, ...List.filled(4 - options.length, 'N/A')],
          correctAnswerIndex: correctIndex.clamp(0, 3),
          explanation: q['explanation'] ?? 'Đáp án đúng: ${String.fromCharCode(65 + correctIndex)}',
          sourceImage: 'gemini_analyzed',
        );
      }).toList();
    } catch (e) {
      throw Exception('Parse error: $e');
    }
  }
}