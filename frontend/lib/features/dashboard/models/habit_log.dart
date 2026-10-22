import 'dart:convert';

class HabitLog {
  final String id;
  final String habitId;
  final String date; // YYYY-MM-DD
  final bool completed;
  final int progressValue;
  final String? note;
  final DateTime updatedAt;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.progressValue = 1,
    this.note,
    required this.updatedAt,
  });

  HabitLog copyWith({
    String? id,
    String? habitId,
    String? date,
    bool? completed,
    int? progressValue,
    String? note,
    DateTime? updatedAt,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      progressValue: progressValue ?? this.progressValue,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date,
      'completed': completed,
      'progressValue': progressValue,
      'note': note,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] ?? '',
      habitId: map['habitId'] ?? '',
      date: map['date'] ?? '',
      completed: map['completed'] ?? false,
      progressValue: (map['progressValue'] as num?)?.toInt() ?? 1,
      note: map['note'],
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory HabitLog.fromJson(String source) => HabitLog.fromMap(json.decode(source));
}
