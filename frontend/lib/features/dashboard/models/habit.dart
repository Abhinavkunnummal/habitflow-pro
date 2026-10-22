import 'dart:convert';

class Habit {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String type; // 'build' or 'quit'
  final String icon;
  final String colorHex;
  final int targetValue;
  final String targetUnit;
  final int streak;
  final String? reminderTime;
  final bool streakShieldEnabled;
  final bool isArchived;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.title,
    this.description,
    this.category = 'Morning',
    this.type = 'build',
    this.icon = 'bolt',
    this.colorHex = '#5D3ADC',
    this.targetValue = 1,
    this.targetUnit = 'times',
    this.streak = 0,
    this.reminderTime,
    this.streakShieldEnabled = false,
    this.isArchived = false,
    required this.createdAt,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? icon,
    String? colorHex,
    int? targetValue,
    String? targetUnit,
    int? streak,
    String? reminderTime,
    bool? streakShieldEnabled,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      streak: streak ?? this.streak,
      reminderTime: reminderTime ?? this.reminderTime,
      streakShieldEnabled: streakShieldEnabled ?? this.streakShieldEnabled,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'icon': icon,
      'colorHex': colorHex,
      'targetValue': targetValue,
      'targetUnit': targetUnit,
      'streak': streak,
      'reminderTime': reminderTime,
      'streakShieldEnabled': streakShieldEnabled,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      category: map['category'] ?? 'Morning',
      type: map['type'] ?? 'build',
      icon: map['icon'] ?? 'bolt',
      colorHex: map['colorHex'] ?? '#5D3ADC',
      targetValue: (map['targetValue'] as num?)?.toInt() ?? 1,
      targetUnit: map['targetUnit'] ?? 'times',
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      reminderTime: map['reminderTime'],
      streakShieldEnabled: map['streakShieldEnabled'] ?? false,
      isArchived: map['isArchived'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Habit.fromJson(String source) => Habit.fromMap(json.decode(source));
}
