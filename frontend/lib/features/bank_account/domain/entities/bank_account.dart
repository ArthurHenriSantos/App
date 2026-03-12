import 'package:app/models/enums.dart';
import 'package:flutter/foundation.dart';

class BankAccount {
  final String id;
  final String userId;
  final String name;
  final double balance;
  final BankAccountType type;
  final Currency currency;

  BankAccount({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.type,
    required this.currency,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    balance: (json['balance'] as num).toDouble(),
    type: BankAccountType.fromString(json['type'] as String),
    currency: Currency.fromString(json['currency'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'balance': balance,
    'type': type.name,
    'currency': currency.name,
  };

  BankAccount copyWith({
    String? name,
    double? balance,
    BankAccountType? type,
    Currency? currency,
  }) => BankAccount(
    id: id,
    userId: userId,
    name: name ?? this.name,
    balance: balance ?? this.balance,
    type: type ?? this.type,
    currency: currency ?? this.currency,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || 
    other is BankAccount && id == other.id && balance == other.balance && type == other.type;

  @override
  int get hashCode => id.hashCode ^ balance.hashCode ^ type.hashCode;
}