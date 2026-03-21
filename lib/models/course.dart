class Course {
  final String id;
  final String name;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final DateTime time; // we care mostly about hour and minute

  Course({
    required this.id,
    required this.name,
    required this.dayOfWeek,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dayOfWeek': dayOfWeek,
      'time': time.toIso8601String(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      time: DateTime.parse(json['time'] as String),
    );
  }
}
