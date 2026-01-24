class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final int displayOrder;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.displayOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
      'display_order': displayOrder,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      updatedAt: DateTime.parse(map['updated_at']),
      displayOrder: map['display_order'] ?? 0,
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? updatedAt,
    int? displayOrder,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
