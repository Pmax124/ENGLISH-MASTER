class Vocabulary {
  final String id;
  final String word;
  final String pronunciation;
  final String meaning;
  final String exampleSentence;
  final String exampleTranslation;
  final String topic;
  final String? imageUrl;

  Vocabulary({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.meaning,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.topic,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'pronunciation': pronunciation,
      'meaning': meaning,
      'exampleSentence': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'topic': topic,
      'imageUrl': imageUrl,
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'] ?? '',
      word: map['word'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      meaning: map['meaning'] ?? '',
      exampleSentence: map['exampleSentence'] ?? '',
      exampleTranslation: map['exampleTranslation'] ?? '',
      topic: map['topic'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
}