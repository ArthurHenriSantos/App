import 'package:app/models/enums.dart';
import 'package:flutter/foundation.dart';

class TransactionCategory {
  final String id;
  final String? userId;
  final String name;
  final String icon;
  final String color;
  final TransactionType type;

  TransactionCategory({
    required this.id,
    this.userId,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) => TransactionCategory(
    id: json['id'] as String,
    userId: json['userId'] as String?,
    name: json['name'] as String,
    icon: json['icon'] as String,
    color: json['color'] as String,
    type: TransactionType.fromString(json['type'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'icon': icon,
    'color': color,
    'type': type.name,
  };

  TransactionCategory copyWith({
    String? name,
    String? icon,
    String? color,
    TransactionType? type,
  }) => TransactionCategory(
    id: id,
    userId: userId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    type: type ?? this.type,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || 
    other is TransactionCategory && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}