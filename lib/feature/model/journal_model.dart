class JournalModel {
  final String id;
  final DateTime date;
  final String emotion;
  final String note;
  final String? relatedId;
  final String? type; // 'plan_day' or 'custom'
  final String? folderId; // For custom notes
  final String? title; // e.g., "Monday Journal" or custom title
  final String? content; // Detailed content

  JournalModel({
    required this.id,
    required this.date,
    required this.emotion,
    required this.note,
    this.relatedId,
    this.type = 'custom',
    this.folderId,
    this.title,
    this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'emotion': emotion,
      'note': note,
      'relatedId': relatedId,
      'type': type,
      'folderId': folderId,
      'title': title,
      'content': content,
    };
  }

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      emotion: json['emotion'] ?? 'Calm',
      note: json['note'] ?? '',
      relatedId: json['relatedId'],
      type: json['type'] ?? 'custom',
      folderId: json['folderId'],
      title: json['title'],
      content: json['content'],
    );
  }
}

class JournalFolderModel {
  final String id;
  final String name;
  final int colorValue;
  final int iconCode;

  JournalFolderModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCode': iconCode,
    };
  }

  factory JournalFolderModel.fromJson(Map<String, dynamic> json) {
    return JournalFolderModel(
      id: json['id'],
      name: json['name'],
      colorValue: json['colorValue'],
      iconCode: json['iconCode'],
    );
  }
}
