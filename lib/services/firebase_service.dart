import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocabulary.dart';
import '../models/topic.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== TOPICS =====
  Stream<List<Topic>> getTopics() {
    return _firestore.collection('topics').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Topic.fromMap(doc.data())).toList();
    });
  }

  Future<void> addTopic(Topic topic) async {
    await _firestore.collection('topics').doc(topic.id).set(topic.toMap());
  }

  // ===== VOCABULARY =====
  Stream<List<Vocabulary>> getVocabularyByTopic(String topicId) {
    return _firestore
        .collection('vocabulary')
        .where('topic', isEqualTo: topicId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Vocabulary.fromMap(doc.data())).toList();
    });
  }

  Stream<List<Vocabulary>> getAllVocabulary() {
    return _firestore.collection('vocabulary').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Vocabulary.fromMap(doc.data())).toList();
    });
  }

  Future<void> addVocabulary(Vocabulary vocab) async {
    await _firestore.collection('vocabulary').doc(vocab.id).set(vocab.toMap());
  }

  Future<void> deleteVocabulary(String id) async {
    await _firestore.collection('vocabulary').doc(id).delete();
  }

  // ===== SEED DATA =====
  Future<void> seedData() async {
    final topics = [
      Topic(id: 'daily_life', name: 'Daily Life', nameVi: 'Đời sống hàng ngày', icon: '🏠', color: '#4CAF50'),
      Topic(id: 'business', name: 'Business', nameVi: 'Kinh doanh', icon: '💼', color: '#2196F3'),
      Topic(id: 'travel', name: 'Travel', nameVi: 'Du lịch', icon: '✈️', color: '#FF9800'),
      Topic(id: 'food', name: 'Food & Drink', nameVi: 'Ẩm thực', icon: '🍕', color: '#E91E63'),
      Topic(id: 'technology', name: 'Technology', nameVi: 'Công nghệ', icon: '💻', color: '#9C27B0'),
      Topic(id: 'education', name: 'Education', nameVi: 'Giáo dục', icon: '', color: '#00BCD4'),
      Topic(id: 'health', name: 'Health', nameVi: 'Sức khỏe', icon: '', color: '#F44336'),
      Topic(id: 'environment', name: 'Environment', nameVi: 'Môi trường', icon: '🌍', color: '#8BC34A'),
    ];

    for (var topic in topics) {
      await addTopic(topic);
    }

    final vocabularies = [
      // Daily Life
      Vocabulary(id: 'v1', word: 'Routine', pronunciation: '/ruːtiːn/', meaning: 'Thói quen, lề thói hàng ngày', exampleSentence: 'My morning routine includes exercising and reading.', exampleTranslation: 'Thói quen buổi sáng của tôi bao gồm tập thể dục và đọc sách.', topic: 'daily_life'),
      Vocabulary(id: 'v2', word: 'Commute', pronunciation: '/kəmjuːt/', meaning: 'Đi lại (từ nhà đến nơi làm việc)', exampleSentence: 'My daily commute takes about 30 minutes by train.', exampleTranslation: 'Chuyến đi làm hàng ngày của tôi mất khoảng 30 phút bằng tàu.', topic: 'daily_life'),
      Vocabulary(id: 'v3', word: 'Chore', pronunciation: '/tʃːr/', meaning: 'Việc vặt trong nhà', exampleSentence: 'I hate doing household chores on weekends.', exampleTranslation: 'Tôi ghét làm việc nhà vào cuối tuần.', topic: 'daily_life'),
      Vocabulary(id: 'v4', word: 'Errand', pronunciation: '/er.ənd/', meaning: 'Việc phải chạy đi làm', exampleSentence: 'I need to run some errands this afternoon.', exampleTranslation: 'Tôi cần chạy vài việc vặt chiều nay.', topic: 'daily_life'),
      Vocabulary(id: 'v5', word: 'Leisure', pronunciation: '/ˈleʒ.ər/', meaning: 'Thời gian rảnh rỗi', exampleSentence: 'I enjoy reading books in my leisure time.', exampleTranslation: 'Tôi thích đọc sách vào thời gian rảnh.', topic: 'daily_life'),

      // Business
      Vocabulary(id: 'v6', word: 'Revenue', pronunciation: '/ˈrev.ən.juː/', meaning: 'Doanh thu', exampleSentence: 'The company\'s revenue increased by 20% this year.', exampleTranslation: 'Doanh thu của công ty tăng 20% trong năm nay.', topic: 'business'),
      Vocabulary(id: 'v7', word: 'Stakeholder', pronunciation: '/ˈsteɪkˌhoʊl.dər/', meaning: 'Bên liên quan, cổ đông', exampleSentence: 'All stakeholders must agree on the new policy.', exampleTranslation: 'Tất cả các bên liên quan phải đồng ý với chính sách mới.', topic: 'business'),
      Vocabulary(id: 'v8', word: 'Deadline', pronunciation: '/ˈded.laɪn/', meaning: 'Hạn chót', exampleSentence: 'We must finish the project before the deadline.', exampleTranslation: 'Chúng ta phải hoàn thành dự án trước hạn chót.', topic: 'business'),
      Vocabulary(id: 'v9', word: 'Negotiate', pronunciation: '/nɪˈɡoʊ.ʃi.eɪt/', meaning: 'Đàm phán, thương lượng', exampleSentence: 'We need to negotiate the terms of the contract.', exampleTranslation: 'Chúng ta cần đàm phán các điều khoản của hợp đồng.', topic: 'business'),
      Vocabulary(id: 'v10', word: 'Innovation', pronunciation: '/ˌɪn.əveɪ.ʃən/', meaning: 'Sự đổi mới, sáng tạo', exampleSentence: 'Innovation is key to staying competitive in the market.', exampleTranslation: 'Đổi mới sáng tạo là chìa khóa để duy trì cạnh tranh trên thị trường.', topic: 'business'),

      // Travel
      Vocabulary(id: 'v11', word: 'Itinerary', pronunciation: '/aɪˈtɪn.ər.er.i/', meaning: 'Lịch trình chuyến đi', exampleSentence: 'Our itinerary includes visits to three cities.', exampleTranslation: 'Lịch trình của chúng tôi bao gồm tham quan ba thành phố.', topic: 'travel'),
      Vocabulary(id: 'v12', word: 'Accommodation', pronunciation: '/əˌkɒm.əˈdeɪ.ən/', meaning: 'Chỗ ở', exampleSentence: 'We booked accommodation near the beach.', exampleTranslation: 'Chúng tôi đã đặt chỗ ở gần bãi biển.', topic: 'travel'),
      Vocabulary(id: 'v13', word: 'Departure', pronunciation: '/dɪˈpɑːr.tʃər/', meaning: 'Sự khởi hành', exampleSentence: 'The departure time is 8 AM tomorrow.', exampleTranslation: 'Giờ khởi hành là 8 giờ sáng ngày mai.', topic: 'travel'),
      Vocabulary(id: 'v14', word: 'Destination', pronunciation: '/des.tɪˈneɪ.ʃən/', meaning: 'Điểm đến', exampleSentence: 'Paris is a popular tourist destination.', exampleTranslation: 'Paris là điểm đến du lịch phổ biến.', topic: 'travel'),
      Vocabulary(id: 'v15', word: 'Souvenir', pronunciation: '/ˌsuː.vəˈnɪr/', meaning: 'Quà lưu niệm', exampleSentence: 'I bought some souvenirs for my family.', exampleTranslation: 'Tôi đã mua vài món quà lưu niệm cho gia đình.', topic: 'travel'),

      // Food
      Vocabulary(id: 'v16', word: 'Appetizer', pronunciation: '/ˈæp.ɪ.taɪ.zər/', meaning: 'Món khai vị', exampleSentence: 'We started the meal with a delicious appetizer.', exampleTranslation: 'Chúng tôi bắt đầu bữa ăn với một món khai vị ngon.', topic: 'food'),
      Vocabulary(id: 'v17', word: 'Cuisine', pronunciation: '/kwɪˈziːn/', meaning: 'Ẩm thực, phong cách nấu ăn', exampleSentence: 'Italian cuisine is famous worldwide.', exampleTranslation: 'Ẩm thực Ý nổi tiếng trên toàn thế giới.', topic: 'food'),
      Vocabulary(id: 'v18', word: 'Ingredient', pronunciation: '/nˈɡriː.di.ənt/', meaning: 'Nguyên liệu', exampleSentence: 'Fresh ingredients make the best dishes.', exampleTranslation: 'Nguyên liệu tươi ngon tạo nên những món ăn ngon nhất.', topic: 'food'),
      Vocabulary(id: 'v19', word: 'Recipe', pronunciation: '/ˈres.ə.pi/', meaning: 'Công thức nấu ăn', exampleSentence: 'She shared her secret recipe with me.', exampleTranslation: 'Cô ấy đã chia sẻ công thức bí mật với tôi.', topic: 'food'),
      Vocabulary(id: 'v20', word: 'Beverage', pronunciation: '/ˈbev.ər.ɪdʒ/', meaning: 'Đồ uống', exampleSentence: 'What beverage would you like with your meal?', exampleTranslation: 'Bạn muốn dùng đồ uống gì với bữa ăn?', topic: 'food'),

      // Technology
      Vocabulary(id: 'v21', word: 'Algorithm', pronunciation: '/ˈæl.ɡə.rɪ.ðəm/', meaning: 'Thuật toán', exampleSentence: 'The search algorithm has been improved significantly.', exampleTranslation: 'Thuật toán tìm kiếm đã được cải thiện đáng kể.', topic: 'technology'),
      Vocabulary(id: 'v22', word: 'Bandwidth', pronunciation: '/ˈbænd.wɪdθ/', meaning: 'Băng thông', exampleSentence: 'We need more bandwidth to handle the traffic.', exampleTranslation: 'Chúng ta cần thêm băng thông để xử lý lưu lượng truy cập.', topic: 'technology'),
      Vocabulary(id: 'v23', word: 'Cloud', pronunciation: '/klaʊd/', meaning: 'Đám mây (lưu trữ trực tuyến)', exampleSentence: 'All our data is stored in the cloud.', exampleTranslation: 'Tất cả dữ liệu của chúng tôi được lưu trữ trên đám mây.', topic: 'technology'),
      Vocabulary(id: 'v24', word: 'Interface', pronunciation: '/ˈɪn.tər.feɪs/', meaning: 'Giao diện', exampleSentence: 'The user interface is very intuitive.', exampleTranslation: 'Giao diện người dùng rất trực quan.', topic: 'technology'),
      Vocabulary(id: 'v25', word: 'Database', pronunciation: '/ˈdeɪ.tə.beɪs/', meaning: 'Cơ sở dữ liệu', exampleSentence: 'The database contains millions of records.', exampleTranslation: 'Cơ sở dữ liệu chứa hàng triệu bản ghi.', topic: 'technology'),

      // Education
      Vocabulary(id: 'v26', word: 'Curriculum', pronunciation: '/kəˈrɪk.jə.ləm/', meaning: 'Chương trình giảng dạy', exampleSentence: 'The school updated its curriculum this year.', exampleTranslation: 'Trường đã cập nhật chương trình giảng dạy năm nay.', topic: 'education'),
      Vocabulary(id: 'v27', word: 'Dissertation', pronunciation: '/ˌdɪs.ərˈteɪ.ən/', meaning: 'Luận văn', exampleSentence: 'She is writing her dissertation on climate change.', exampleTranslation: 'Cô ấy đang viết luận văn về biến đổi khí hậu.', topic: 'education'),
      Vocabulary(id: 'v28', word: 'Seminar', pronunciation: '/ˈsem.ɪ.nɑːr/', meaning: 'Hội thảo, buổi seminar', exampleSentence: 'We attended a seminar on digital marketing.', exampleTranslation: 'Chúng tôi đã tham dự một hội thảo về marketing kỹ thuật số.', topic: 'education'),
      Vocabulary(id: 'v29', word: 'Scholarship', pronunciation: '/ˈskɒl.ər.ʃɪp/', meaning: 'Học bổng', exampleSentence: 'He received a full scholarship to study abroad.', exampleTranslation: 'Anh ấy nhận được học bổng toàn phần để du học.', topic: 'education'),
      Vocabulary(id: 'v30', word: 'Assignment', pronunciation: '/əˈsaɪn.mənt/', meaning: 'Bài tập được giao', exampleSentence: 'The assignment is due next Friday.', exampleTranslation: 'Bài tập phải nộp vào thứ Sáu tuần sau.', topic: 'education'),

      // Health
      Vocabulary(id: 'v31', word: 'Symptom', pronunciation: '/ˈsɪmp.təm/', meaning: 'Triệu chứng', exampleSentence: 'Fever is a common symptom of the flu.', exampleTranslation: 'Sốt là triệu chứng phổ biến của bệnh cúm.', topic: 'health'),
      Vocabulary(id: 'v32', word: 'Diagnosis', pronunciation: '/ˌdaɪ.əɡˈnoʊ.sɪs/', meaning: 'Chẩn đoán', exampleSentence: 'The doctor gave a clear diagnosis.', exampleTranslation: 'Bác sĩ đã đưa ra chẩn đoán rõ ràng.', topic: 'health'),
      Vocabulary(id: 'v33', word: 'Prescription', pronunciation: '/prɪˈskrɪp.ʃən/', meaning: 'Đơn thuốc', exampleSentence: 'You need a prescription for this medication.', exampleTranslation: 'Bạn cần đơn thuốc cho loại thuốc này.', topic: 'health'),
      Vocabulary(id: 'v34', word: 'Therapy', pronunciation: '/ˈθer.ə.pi/', meaning: 'Liệu pháp điều trị', exampleSentence: 'Physical therapy helped him recover faster.', exampleTranslation: 'Vật lý trị liệu giúp anh ấy hồi phục nhanh hơn.', topic: 'health'),
      Vocabulary(id: 'v35', word: 'Immunity', pronunciation: '/ˈmjuː.nə.ti/', meaning: 'Miễn dịch', exampleSentence: 'Exercise can boost your immunity.', exampleTranslation: 'Tập thể dục có thể tăng cường hệ miễn dịch của bạn.', topic: 'health'),

      // Environment
      Vocabulary(id: 'v36', word: 'Sustainability', pronunciation: '/səˌsteɪ.nəˈbɪl.ə.ti/', meaning: 'Sự bền vững', exampleSentence: 'Sustainability is crucial for our future.', exampleTranslation: 'Tính bền vững rất quan trọng cho tương lai của chúng ta.', topic: 'environment'),
      Vocabulary(id: 'v37', word: 'Emission', pronunciation: '/ɪˈmɪʃ.ən/', meaning: 'Khí thải', exampleSentence: 'We must reduce carbon emissions.', exampleTranslation: 'Chúng ta phải giảm khí thải carbon.', topic: 'environment'),
      Vocabulary(id: 'v38', word: 'Renewable', pronunciation: '/rɪˈnjuː.ə.bəl/', meaning: 'Có thể tái tạo', exampleSentence: 'Solar energy is a renewable resource.', exampleTranslation: 'Năng lượng mặt trời là nguồn tài nguyên có thể tái tạo.', topic: 'environment'),
      Vocabulary(id: 'v39', word: 'Conservation', pronunciation: '/ˌkɒn.sərˈveɪ.ʃən/', meaning: 'Bảo tồn', exampleSentence: 'Wildlife conservation is everyone\'s responsibility.', exampleTranslation: 'Bảo tồn động vật hoang dã là trách nhiệm của mọi người.', topic: 'environment'),
      Vocabulary(id: 'v40', word: 'Pollution', pronunciation: '/pəˈluː.ʃən/', meaning: 'Ô nhiễm', exampleSentence: 'Air pollution is a major problem in big cities.', exampleTranslation: 'Ô nhiễm không khí là vấn đề lớn ở các thành phố lớn.', topic: 'environment'),
    ];

    for (var vocab in vocabularies) {
      await addVocabulary(vocab);
    }
  }
}