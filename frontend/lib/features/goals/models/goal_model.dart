import 'dart:convert';

class GoalModel {
  final String id;
  final String title;
  final String? description;
  final String tier; // 'Bronze' | 'Silver' | 'Gold'
  final int targetValue;
  final String targetUnit;
  final int currentProgress;
  final String status; // 'active' | 'completed' | 'archived'
  final int xpReward;
  final List<String> linkedHabitIds;
  final DateTime? createdAt;

  const GoalModel({
    required this.id,
    required this.title,
    this.description,
    this.tier = 'Silver',
    this.targetValue = 30,
    this.targetUnit = 'days',
    this.currentProgress = 0,
    this.status = 'active',
    this.xpReward = 150,
    this.linkedHabitIds = const [],
    this.createdAt,
  });

  bool get isCompleted => status == 'completed' || currentProgress >= targetValue;

  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    final ratio = currentProgress / targetValue;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    String? tier,
    int? targetValue,
    String? targetUnit,
    int? currentProgress,
    String? status,
    int? xpReward,
    List<String>? linkedHabitIds,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tier: tier ?? this.tier,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      currentProgress: currentProgress ?? this.currentProgress,
      status: status ?? this.status,
      xpReward: xpReward ?? this.xpReward,
      linkedHabitIds: linkedHabitIds ?? this.linkedHabitIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'tier': tier,
      'targetValue': targetValue,
      'targetUnit': targetUnit,
      'currentProgress': currentProgress,
      'status': status,
      'xpReward': xpReward,
      'linkedHabitIds': linkedHabitIds,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      tier: map['tier']?.toString() ?? 'Silver',
      targetValue: (map['targetValue'] as num?)?.toInt() ?? 30,
      targetUnit: map['targetUnit']?.toString() ?? 'days',
      currentProgress: (map['currentProgress'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'active',
      xpReward: (map['xpReward'] as num?)?.toInt() ?? 150,
      linkedHabitIds: (map['linkedHabitIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoalModel.fromJson(String source) => GoalModel.fromMap(json.decode(source));
}
