import 'dart:typed_data';
import 'dart:convert';
import 'dart:js_util' as js_util;

class SmartOcrResult {
  final String text;
  final List<WordInfo> words;
  final bool success;

  SmartOcrResult({
    required this.text,
    required this.words,
    required this.success,
  });

  factory SmartOcrResult.fromJs(dynamic jsResult) {
    final text = js_util.getProperty(jsResult, 'text') as String;
    final success = js_util.getProperty(jsResult, 'success') as bool;
    final jsWords = js_util.getProperty(jsResult, 'words') as dynamic;
    
    final words = <WordInfo>[];
    final length = js_util.callMethod(jsWords, 'length', []) as int;
    
    for (int i = 0; i < length; i++) {
      final jsWord = js_util.callMethod(jsWords, '[]', [i]);
      words.add(WordInfo.fromJs(jsWord));
    }
    
    return SmartOcrResult(text: text, words: words, success: success);
  }
}

class WordInfo {
  final String text;
  final List<int> bbox; // [x0, y0, x1, y1]
  final Map<String, int> color;
  final bool isRed;
  final bool isDark;
  final double redRatio;
  final double confidence;

  WordInfo({
    required this.text,
    required this.bbox,
    required this.color,
    required this.isRed,
    required this.isDark,
    required this.redRatio,
    required this.confidence,
  });

  factory WordInfo.fromJs(dynamic jsWord) {
    final text = js_util.getProperty(jsWord, 'text') as String;
    final isRed = js_util.getProperty(jsWord, 'isRed') as bool;
    final isDark = js_util.getProperty(jsWord, 'isDark') as bool;
    final redRatio = (js_util.getProperty(jsWord, 'redRatio') as num).toDouble();
    final confidence = (js_util.getProperty(jsWord, 'confidence') as num).toDouble();
    
    final jsBbox = js_util.getProperty(jsWord, 'bbox') as dynamic;
    final bbox = <int>[
      js_util.callMethod(jsBbox, '[]', [0]) as int,
      js_util.callMethod(jsBbox, '[]', [1]) as int,
      js_util.callMethod(jsBbox, '[]', [2]) as int,
      js_util.callMethod(jsBbox, '[]', [3]) as int,
    ];
    
    final jsColor = js_util.getProperty(jsWord, 'color') as dynamic;
    final color = <String, int>{
      'r': js_util.getProperty(jsColor, 'r') as int,
      'g': js_util.getProperty(jsColor, 'g') as int,
      'b': js_util.getProperty(jsColor, 'b') as int,
    };
    
    return WordInfo(
      text: text,
      bbox: bbox,
      color: color,
      isRed: isRed,
      isDark: isDark,
      redRatio: redRatio,
      confidence: confidence,
    );
  }
}

class SmartOcrService {
  /// OCR + detect màu đỏ tại vị trí từng từ (cải tiến)
  static Future<SmartOcrResult> recognizeWithColor(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final dataUrl = 'data:image/png;base64,$base64Image';
      
      final jsResult = await js_util.promiseToFuture(
        js_util.callMethod(
          js_util.getProperty(js_util.globalThis, 'window'),
          'smartOcr',
          [dataUrl],
        ),
      );
      
      return SmartOcrResult.fromJs(jsResult);
    } catch (e) {
      return SmartOcrResult(text: '', words: [], success: false);
    }
  }
  
  /// Tìm đáp án đúng cho một câu hỏi dựa vào vị trí và màu sắc
  static int findCorrectAnswerIndex(
    List<WordInfo> words,
    String optionLetter,
    String optionText,
    int optionStartY,
    int optionEndY,
  ) {
    // Lọc các word trong vùng của đáp án này
    final optionWords = words.where((w) {
      final yCenter = (w.bbox[1] + w.bbox[3]) ~/ 2;
      return yCenter >= optionStartY && yCenter <= optionEndY;
    }).toList();
    
    // Check từng word xem có màu đỏ không
    for (final word in optionWords) {
      if (word.isRed && word.redRatio > 0.2) {
        return words.indexOf(word);
      }
    }
    
    // Nếu không tìm thấy word đỏ, check màu trung bình của cả dòng
    int totalR = 0, totalG = 0, totalB = 0, count = 0;
    for (final word in optionWords) {
      if (word.confidence > 50) { // Chỉ lấy word có confidence cao
        totalR += word.color['r']!;
        totalG += word.color['g']!;
        totalB += word.color['b']!;
        count++;
      }
    }
    
    if (count > 0) {
      final avgR = totalR ~/ count;
      final avgG = totalG ~/ count;
      final avgB = totalB ~/ count;
      
      // Check nếu màu trung bình là đỏ
      if (avgR > 160 && avgG < 120 && avgB < 120) {
        return 0; // Word đầu tiên trong option
      }
    }
    
    return -1; // Không tìm thấy
  }
}