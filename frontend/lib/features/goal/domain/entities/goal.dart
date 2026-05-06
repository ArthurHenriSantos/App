import 'package:app/models/enums.dart';

class Goal {
  final String id;
  final String userId;
  final String? bankAccountId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final GoalStatus status;
  final DateTime deadlineDate;

  Goal({
    required this.id,
    required this.userId,
    this.bankAccountId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.status,
    required this.deadlineDate,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'] as String,
    userId: json['userId'] as String,
    bankAccountId: json['bankAccountId'] as String?,
    name: json['name'] as String,
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num).toDouble(),
    status: GoalStatus.fromString(json['status'] as String),
    deadlineDate: DateTime.parse(json['deadlineDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'bankAccountId': bankAccountId,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'status': status.name,
    'deadlineDate': deadlineDate.toIso8601String(),
  };

  Goal copyWith({
    String? bankAccountId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    GoalStatus? status,
    DateTime? deadlineDate,
  }) => Goal(
    id: id,
    userId: userId,
    bankAccountId: bankAccountId ?? this.bankAccountId,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    status: status ?? this.status,
    deadlineDate: deadlineDate ?? this.deadlineDate,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || 
    other is Goal && id == other.id && currentAmount == other.currentAmount && status == other.status;

  @override
  int get hashCode => id.hashCode ^ currentAmount.hashCode ^ status.hashCode;
}