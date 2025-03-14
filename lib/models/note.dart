import 'package:uuid/uuid.dart';

class Note {
  final String id;
  String title;
  String content;
  String? summary;
  List<String> tags;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    String? id,
    required this.title,
    required this.content,
    this.summary,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? title,
    String? content,
    String? summary,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'tags': tags.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    final tagsString = map['tags'] as String?;
    final tagsList = tagsString != null && tagsString.isNotEmpty 
        ? tagsString.split(',').where((tag) => tag.isNotEmpty).toList() 
        : <String>[];
        
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      summary: map['summary'],
      tags: tagsList,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Add a tag to the note
  void addTag(String tag) {
    if (!tags.contains(tag) && tag.isNotEmpty) {
      tags.add(tag);
    }
  }

  // Remove a tag from the note
  void removeTag(String tag) {
    tags.remove(tag);
  }
}
