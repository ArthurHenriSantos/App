import 'package:app/models/enums.dart';
import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final Gender gender;
  final DateTime creationDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.gender,
    required this.creationDate,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    gender: Gender.fromString(json['gender'] as String),
    creationDate: DateTime.parse(json['creationDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'gender': gender.name,
    'creationDate': creationDate.toIso8601String(),
  };

  User copyWith({
    String? name,
    String? email,
    String? password,
    Gender? gender,
    DateTime? creationDate,
  }) => User(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    password: password ?? this.password,
    gender: gender ?? this.gender,
    creationDate: creationDate ?? this.creationDate,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || 
    other is User && id == other.id && name == other.name && email == other.email && gender == other.gender;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode ^ gender.hashCode;
}