import 'dart:typed_data';
import 'dart:convert';
import 'dart:js_util' as js_util;

class OcrWebService {
  /// Nhận diện text từ ảnh bằng Tesseract.js
  static Future<String> recognizeText(Uint8List imageBytes) async {
    try {
      String base64Image = base64Encode(imageBytes);
      String dataUrl = 'data:image/png;base64,$base64Image';
      
      final result = await js_util.promiseToFuture(
        js_util.callMethod(
          js_util.getProperty(js_util.globalThis, 'Tesseract'),
          'recognize',
          [dataUrl],
        ),
      );
      
      final data = js_util.getProperty(result, 'data');
      final text = js_util.getProperty(data, 'text') as String;
      
      return text.trim();
    } catch (e) {
      throw Exception('OCR failed: $e');
    }
  }

  /// Phân tích ảnh để tìm vùng màu đỏ (đáp án đúng)
  /// Trả về danh sách các dòng có chứa màu đỏ
  static Future<List<int>> detectRedLines(Uint8List imageBytes) async {
    try {
      // Tạo canvas element
      final canvas = js_util.callMethod(
        js_util.getProperty(js_util.globalThis, 'document'),
        'createElement',
        ['canvas'],
      );
      
      final ctx = js_util.callMethod(canvas, 'getContext', ['2d']);
      final img = js_util.callMethod(
        js_util.getProperty(js_util.globalThis, 'document'),
        'createElement',
        ['img'],
      );
      
      // Load image
      await js_util.promiseToFuture(
        js_util.callMethod(img, 'addEventListener', ['load', js_util.allowInterop((_) {})]),
      );
      
      js_util.setProperty(img, 'src', 'data:image/png;base64,${base64Encode(imageBytes)}');
      
      // Đợi ảnh load
      await Future.delayed(const Duration(milliseconds: 500));
      
      js_util.setProperty(canvas, 'width', js_util.getProperty(img, 'width'));
      js_util.setProperty(canvas, 'height', js_util.getProperty(img, 'height'));
      js_util.callMethod(ctx, 'drawImage', [img, 0, 0]);
      
      // Phân tích từng dòng (chia ảnh thành các phần ngang)
      final height = js_util.getProperty(canvas, 'height') as int;
      final width = js_util.getProperty(canvas, 'width') as int;
      final imageData = js_util.callMethod(ctx, 'getImageData', [0, 0, width, height]);
      final pixels = js_util.getProperty(imageData, 'data');
      
      final redLines = <int>[];
      final lineHeight = height ~/ 20; // Giả sử khoảng 20 dòng
      
      for (int line = 0; line < 20; line++) {
        final startY = line * lineHeight;
        final endY = startY + lineHeight;
        int redPixelCount = 0;
        int totalPixels = 0;
        
        for (int y = startY; y < endY && y < height; y++) {
          for (int x = 0; x < width; x += 4) { // Sample mỗi 4 pixel
            final idx = (y * width + x) * 4;
            final r = pixels[idx] as int;
            final g = pixels[idx + 1] as int;
            final b = pixels[idx + 2] as int;
            
            // Kiểm tra màu đỏ (R cao, G và B thấp)
            if (r > 150 && g < 100 && b < 100) {
              redPixelCount++;
            }
            totalPixels++;
          }
        }
        
        // Nếu có nhiều pixel đỏ trong dòng này → đánh dấu là đáp án đúng
        if (redPixelCount > totalPixels * 0.05) {
          redLines.add(line);
        }
      }
      
      return redLines;
    } catch (e) {
      return []; // Trả về empty nếu lỗi
    }
  }
}