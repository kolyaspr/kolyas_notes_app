/// Модель данных для заметки
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isDone;  // ← НОВОЕ ПОЛЕ

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isDone = false,  // по умолчанию не завершена
  });

  /// Создать новую заметку
  factory Note.create({required String title, required String content}) {
    return Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      isDone: false,
    );
  }

  /// Преобразовать в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isDone': isDone,  // ← сохраняем статус
    };
  }

  /// Создать из JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isDone: json['isDone'] as bool? ?? false,  // ← загружаем статус
    );
  }

  /// Создать копию с изменениями
  Note copyWith({String? title, String? content, bool? isDone}) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      isDone: isDone ?? this.isDone,  // ← обновляем статус
    );
  }

  /// Переключить статус выполнения
  Note toggleDone() {
    return copyWith(isDone: !isDone);
  }
}