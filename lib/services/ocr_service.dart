import 'dart:io';
import 'dart:typed_data';

class OcrService {
  /// Trích xuất text từ File (mobile)
  static Future<String> extractTextFromImage(File imageFile) async {
    await Future.delayed(const Duration(seconds: 2));

    return '''
English Learning Outline - Chapter 5: Communication Skills

1. Verbal Communication
   - Clear articulation of ideas
   - Active listening techniques
   - Non-verbal cues and body language

2. Written Communication
   - Email etiquette
   - Report writing structure
   - Grammar and punctuation rules

3. Digital Communication
   - Video conferencing best practices
   - Social media professionalism
   - Online collaboration tools

4. Cross-cultural Communication
   - Understanding cultural differences
   - Adapting communication style
   - Avoiding misunderstandings

5. Public Speaking
   - Overcoming stage fright
   - Structuring a presentation
   - Engaging the audience
''';
  }

  /// Trích xuất text từ bytes (web)
  static Future<String> extractTextFromBytes(Uint8List imageBytes) async {
    // Trên web, dùng cùng logic mock
    await Future.delayed(const Duration(seconds: 2));

    return '''
English Learning Outline - Chapter 5: Communication Skills

1. Verbal Communication
   - Clear articulation of ideas
   - Active listening techniques
   - Non-verbal cues and body language

2. Written Communication
   - Email etiquette
   - Report writing structure
   - Grammar and punctuation rules

3. Digital Communication
   - Video conferencing best practices
   - Social media professionalism
   - Online collaboration tools

4. Cross-cultural Communication
   - Understanding cultural differences
   - Adapting communication style
   - Avoiding misunderstandings

5. Public Speaking
   - Overcoming stage fright
   - Structuring a presentation
   - Engaging the audience
''';
  }
}