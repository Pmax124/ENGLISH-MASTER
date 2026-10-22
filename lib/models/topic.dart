class Topic {
  final String id;
  final String name;
  final String nameVi;
  final String icon;
  final String color;
  final int vocabularyCount;

  Topic({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.color,
    this.vocabularyCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameVi': nameVi,
      'icon': icon,
      'color': color,
      'vocabularyCount': vocabularyCount,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameVi: map['nameVi'] ?? '',
      icon: map['icon'] ?? '📚',
      color: map['color'] ?? 'blue',
      vocabularyCount: map['vocabularyCount'] ?? 0,
    );
  }
}