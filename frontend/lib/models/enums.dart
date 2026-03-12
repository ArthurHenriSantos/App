// lib/models/enums.dart

enum Gender {
  male, female, other, notSpecified;
  static Gender fromString(String val) => Gender.values.firstWhere(
      (e) => e.name == val, orElse: () => Gender.notSpecified);
}

enum BankAccountType {
  checking, savings, cash, creditCard;
  static BankAccountType fromString(String val) => BankAccountType.values.firstWhere(
      (e) => e.name == val, orElse: () => BankAccountType.checking);
}

enum Currency {
  brl, usd;
  static Currency fromString(String val) => Currency.values.firstWhere(
      (e) => e.name == val, orElse: () => Currency.brl);
}

enum TransactionType {
  income, expense, transfer;
  static TransactionType fromString(String val) => TransactionType.values.firstWhere(
      (e) => e.name == val, orElse: () => TransactionType.expense);
}

enum GoalStatus {
  inProgress, completed, cancelled;
  static GoalStatus fromString(String val) => GoalStatus.values.firstWhere(
      (e) => e.name == val, orElse: () => GoalStatus.inProgress);
}