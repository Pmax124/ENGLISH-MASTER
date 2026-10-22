import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/quiz_question.dart';
import '../services/ocr_service.dart';
import '../services/ocr_web_service.dart';
import '../services/smart_ocr_service.dart';
import '../services/quiz_generator_service.dart';
import 'quiz_play_page.dart';

class QuizUploadPage extends StatefulWidget {
  const QuizUploadPage({super.key});

  @override
  State<QuizUploadPage> createState() => _QuizUploadPageState();
}

class _QuizUploadPageState extends State<QuizUploadPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _imageBytes;
  String? _imageUrl;
  
  bool _isProcessing = false;
  bool _isOcrRunning = false;
  String _status = '';
  
  final TextEditingController _textController = TextEditingController();
  bool _showTextEditor = false;
  
  // Review step
  List<Map<String, dynamic>> _parsedQuestions = [];
  List<int> _correctAnswers = []; 
  bool _showReview = false;

  // Gemini API
  String _geminiApiKey = '';
  final TextEditingController _apiKeyController = TextEditingController();
  bool _showApiKeyInput = true;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _imageUrl = image.path;
            _selectedImage = null;
            _showTextEditor = true;
            _isOcrRunning = true;
            _showReview = false;
            _status = 'Đang nhận diện text...';
          });
          await _autoOcr(bytes);
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _showTextEditor = true;
            _isOcrRunning = true;
            _showReview = false;
            _status = 'Đang nhận diện text...';
          });
          final text = await OcrService.extractTextFromImage(File(image.path));
          setState(() {
            _textController.text = text;
            _isOcrRunning = false;
            _status = '';
          });
        }
      }
    } catch (e) {
      _showError('Lỗi chọn ảnh: $e');
      setState(() {
        _isOcrRunning = false;
        _status = '';
      });
    }
  }

  Future<void> _autoOcr(Uint8List bytes) async {
    try {
      final text = await OcrWebService.recognizeText(bytes);
      setState(() {
        _textController.text = text;
        _isOcrRunning = false;
        _status = text.isEmpty ? 'Không nhận diện được text. Vui lòng nhập thủ công.' : 'Đã nhận diện xong!';
      });
    } catch (e) {
      setState(() {
        _isOcrRunning = false;
        _status = 'Lỗi OCR. Vui lòng nhập thủ công.';
      });
      _showError('Lỗi OCR: $e');
    }
  }

  bool get _hasImage => kIsWeb ? (_imageBytes != null) : (_selectedImage != null);

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Chọn nguồn ảnh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(10)), child: Icon(Icons.photo_camera, color: Colors.blue[700])),
              title: const Text('Chụp ảnh'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(10)), child: Icon(Icons.photo_library, color: Colors.green[700])),
              title: const Text('Chọn từ thư viện'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Parse text và chuyển sang bước review
  void _parseAndReview() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showError('Vui lòng nhập nội dung đề cương.');
      return;
    }

    final parsed = QuizGeneratorService.parseQuestions(text);
    
    if (parsed.isEmpty) {
      _showError('Không nhận diện được câu hỏi. Kiểm tra format:\n"Question 1. ..."\nA. ...\nB. ...\nC. ...\nD. ...');
      return;
    }

    setState(() {
      _parsedQuestions = parsed;
      _correctAnswers = List.filled(parsed.length, 0);
      _showReview = true;
    });
  }

  /// Tạo quiz và chuyển sang trang chơi
  void _startQuiz() {
    if (_parsedQuestions.isEmpty) return;

    final questions = QuizGeneratorService.buildQuizQuestions(_parsedQuestions, _correctAnswers);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPlayPage(
          questions: questions,
          title: 'Quiz từ ảnh',
          sourceImage: _selectedImage,
          sourceImageUrl: _imageUrl,
          sourceImageBytes: _imageBytes,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text('Tạo Quiz từ Ảnh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]), borderRadius: BorderRadius.circular(20)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.auto_awesome, color: Colors.white, size: 28), SizedBox(width: 12), Text('Tạo Quiz từ Đề Cương', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
                  SizedBox(height: 12),
                  Text('Tải ảnh, nhập text và chọn đáp án đúng để tạo quiz.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_showReview) ...[
              _buildReviewStep(),
            ] else ...[
              const Text('Ảnh đề cương', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const SizedBox(height: 12),
              InkWell(
                onTap: _isProcessing || _isOcrRunning ? null : _showImageSourceDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _hasImage ? Colors.green : Colors.grey[300]!, width: 2)),
                  child: _hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              kIsWeb
                                  ? (_imageBytes != null ? Image.memory(_imageBytes!, width: double.infinity, height: double.infinity, fit: BoxFit.cover) : const Center(child: CircularProgressIndicator()))
                                  : (_selectedImage != null ? Image.file(_selectedImage!, width: double.infinity, height: double.infinity, fit: BoxFit.cover) : const SizedBox()),
                              if (_isOcrRunning)
                                Container(color: Colors.black.withValues(alpha: 0.5), child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: Colors.white), SizedBox(height: 12), Text('Đang OCR...', style: TextStyle(color: Colors.white))]))),
                              Positioned(top: 10, right: 10, child: InkWell(onTap: () => setState(() { _selectedImage = null; _imageBytes = null; _imageUrl = null; _showTextEditor = false; _textController.clear(); _isOcrRunning = false; _status = ''; }), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 20)))),
                            ],
                          ),
                        )
                      : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle), child: Icon(Icons.cloud_upload, color: Colors.blue[400], size: 40)), const SizedBox(height: 16), const Text('Nhấn để tải ảnh lên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))), const SizedBox(height: 8), Text('Hỗ trợ: JPG, PNG', style: TextStyle(fontSize: 13, color: Colors.grey[500]))]),
                ),
              ),
              const SizedBox(height: 24),

              if (_showTextEditor) ...[
                const Text('Nội dung đề cương', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 8),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber[200]!)), child: Row(children: [Icon(Icons.lightbulb, color: Colors.amber[700], size: 20), const SizedBox(width: 8), Expanded(child: Text('Nhập đề cương theo format:\nQuestion 1. ...\nA. ...\nB. ...\nC. ...\nD. ...\n\nApp sẽ tự động parse và bạn chỉ cần click chọn đáp án đúng.', style: TextStyle(fontSize: 12, color: Colors.amber[900])))])),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                  child: TextField(
                    controller: _textController,
                    maxLines: 15,
                    decoration: InputDecoration(hintText: 'Question 1. Innovation is key to staying _____ in the market.\nA. competitively\nB. competition\nC. competitive\nD. compete\n\nQuestion 2. ...', hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
                    style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _textController.text.trim().isNotEmpty ? _parseAndReview : null,
                    icon: const Icon(Icons.analytics, color: Colors.white),
                    label: const Text('Parse và chọn đáp án đúng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle), child: Icon(Icons.check_circle, color: Colors.green[700])),
            const SizedBox(width: 12),
            Expanded(child: Text('Đã parse ${_parsedQuestions.length} câu hỏi', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[200]!)), child: Row(children: [Icon(Icons.touch_app, color: Colors.blue[700], size: 20), const SizedBox(width: 8), Expanded(child: Text('Click vào đáp án ĐÚNG (màu đỏ trong đề) cho mỗi câu hỏi.', style: TextStyle(fontSize: 13, color: Colors.blue[900])))])),
        const SizedBox(height: 16),
        ...List.generate(_parsedQuestions.length, (i) => _buildQuestionReview(i)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _startQuiz,
            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
            label: const Text('Bắt đầu Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => setState(() => _showReview = false),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          child: const Text('Quay lại chỉnh sửa text'),
        ),
      ],
    );
  }

  Widget _buildQuestionReview(int index) {
    final q = _parsedQuestions[index];
    final options = List<String>.from(q['options'] as List);
    final correctIndex = _correctAnswers[index];
    final letters = ['A', 'B', 'C', 'D'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.purple[100], shape: BoxShape.circle), child: Center(child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple[700])))),
              const SizedBox(width: 12),
              Expanded(child: Text(q['question'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length > 4 ? 4 : options.length, (optIdx) {
            final isSelected = correctIndex == optIdx;
            return InkWell(
              onTap: () => setState(() => _correctAnswers[index] = optIdx),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.withValues(alpha: 0.1) : Colors.grey[50],
                  border: Border.all(color: isSelected ? Colors.red : Colors.grey[300]!, width: isSelected ? 2 : 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(width: 28, height: 28, decoration: BoxDecoration(color: isSelected ? Colors.red : Colors.grey[300], shape: BoxShape.circle), child: Center(child: Text(letters[optIdx], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(options[optIdx], style: TextStyle(fontSize: 14, color: isSelected ? Colors.red[900] : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.red, size: 22),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }
}