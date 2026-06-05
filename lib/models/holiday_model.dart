class Holiday {
  final int? id;
  final String name;
  final DateTime date;
  final String? description;

  Holiday({
    this.id,
    required this.name,
    required this.date,
    this.description,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Holiday',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      description: json['description'] as String?,
    );
  }

  @override
  String toString() {
    return 'Holiday(id: $id, name: $name, date: ${date.toIso8601String().split('T')[0]})';
  }
}