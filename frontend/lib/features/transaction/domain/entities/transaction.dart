import 'package:app/models/enums.dart';
import 'package:flutter/foundation.dart';

class Transaction {
  final String id;
  final String bankAccountId;
  final String? destinationBankAccountId;
  final TransactionType type;
  final String? transactionCategoryId;
  final double amount;
  final String description;
  final DateTime transactionDate;
  final DateTime creationDate;

  Transaction({
    required this.id,
    required this.bankAccountId,
    this.destinationBankAccountId,
    required this.type,
    this.transactionCategoryId,
    required this.amount,
    required this.description,
    required this.transactionDate,
    required this.creationDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    bankAccountId: json['bankAccountId'] as String,
    destinationBankAccountId: json['destinationBankAccountId'] as String?,
    type: TransactionType.fromString(json['type'] as String),
    transactionCategoryId: json['transactionCategoryId'] as String?,
    amount: (json['amount'] as num).toDouble(),
    description: json['description'] as String,
    transactionDate: DateTime.parse(json['transactionDate'] as String),
    creationDate: DateTime.parse(json['creationDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bankAccountId': bankAccountId,
    'destinationBankAccountId': destinationBankAccountId,
    'type': type.name,
    'transactionCategoryId': transactionCategoryId,
    'amount': amount,
    'description': description,
    'transactionDate': transactionDate.toIso8601String(),
    'creationDate': creationDate.toIso8601String(),
  };

  Transaction copyWith({
    String? bankAccountId,
    String? destinationBankAccountId,
    TransactionType? type,
    String? transactionCategoryId,
    double? amount,
    String? description,
    DateTime? transactionDate,
  }) => Transaction(
    id: id,
    bankAccountId: bankAccountId ?? this.bankAccountId,
    destinationBankAccountId: destinationBankAccountId ?? this.destinationBankAccountId,
    type: type ?? this.type,
    transactionCategoryId: transactionCategoryId ?? this.transactionCategoryId,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    transactionDate: transactionDate ?? this.transactionDate,
    creationDate: creationDate,
  );

  @override
  bool operator ==(Object other) => identical(this, other) || 
    other is Transaction && id == other.id && amount == other.amount;

  @override
  int get hashCode => id.hashCode ^ amount.hashCode;
}