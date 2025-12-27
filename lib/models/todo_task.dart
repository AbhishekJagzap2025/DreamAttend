class ToDoTask {
  final int? id;
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;

  ToDoTask({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.createdAt,
  });

  // Add this copyWith() method
  ToDoTask copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return ToDoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'is_completed': isCompleted,
    if (id != null) 'id': id,
    if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
  };

  factory ToDoTask.fromJson(Map<String, dynamic> json) => ToDoTask(
    id: json['id'] as int?,
    title: json['title'] as String,
    isCompleted: json['is_completed'] ?? false,
    createdAt:
        json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
  );
}
