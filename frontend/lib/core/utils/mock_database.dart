import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/bank_account/domain/entities/bank_account.dart';
import 'package:app/features/goal/domain/entities/goal.dart';
import 'package:app/features/transaction/domain/entities/transaction.dart';
import 'package:app/models/enums.dart';

class MockDatabase {
  static final User currentUser = User(
    id: 'usr_lucas123',
    name: 'Lucas Antunes',
    email: 'lucas@koin.com',
    password: 'hashed_password_here',
    gender: Gender.male,
    creationDate: DateTime.now().subtract(const Duration(days: 30)),
  );

  static BankAccount currentAccount = BankAccount(
    id: 'acc_wallet_01',
    userId: 'usr_lucas123',
    name: 'Carteira Principal',
    balance: 10300.00,
    type: BankAccountType.checking,
    currency: Currency.brl,
  );

  static final List<Goal> userGoals = [
    Goal(
      id: 'goal_01',
      userId: 'usr_lucas123',
      name: 'Viagem Japão (1 ano)',
      targetAmount: 8000.00,
      currentAmount: 5200.00,
      status: GoalStatus.inProgress,
      deadlineDate: DateTime.now().add(const Duration(days: 365)),
    ),
    Goal(
      id: 'goal_02',
      userId: 'usr_lucas123',
      name: 'Troca de Carro (5 anos)',
      targetAmount: 100000.00,
      currentAmount: 31800.00,
      status: GoalStatus.inProgress,
      deadlineDate: DateTime.now().add(const Duration(days: 1825)),
    ),
    Goal(
      id: 'goal_03',
      userId: 'usr_lucas123',
      name: 'Reserva de Emergência',
      targetAmount: 5000.00,
      currentAmount: 5000.00,
      status: GoalStatus.completed,
      deadlineDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static final List<Transaction> userTransactions = [
    Transaction(
      id: 'tx_01',
      bankAccountId: 'acc_wallet_01',
      type: TransactionType.expense,
      amount: 45.0,
      description: 'Almoço Executivo',
      transactionDate: DateTime.now(),
      creationDate: DateTime.now(),
    ),
    Transaction(
      id: 'tx_02',
      bankAccountId: 'acc_wallet_01',
      type: TransactionType.income,
      amount: 20.0,
      description: 'Economia Diária Hábito',
      transactionDate: DateTime.now(),
      creationDate: DateTime.now(),
    ),
    Transaction(
      id: 'tx_03',
      bankAccountId: 'acc_wallet_01',
      type: TransactionType.expense,
      amount: 8.5,
      description: 'Passagem Ônibus',
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      creationDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: 'tx_04',
      bankAccountId: 'acc_wallet_01',
      type: TransactionType.expense,
      amount: 120.0,
      description: 'Supermercado Mensal',
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      creationDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: 'tx_05',
      bankAccountId: 'acc_wallet_01',
      type: TransactionType.income,
      amount: 12.4,
      description: 'Rendimento Poupança',
      transactionDate: DateTime.now().subtract(const Duration(days: 5)),
      creationDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static void addTransaction(Transaction tx) {
    userTransactions.insert(0, tx);
    // Atualiza o saldo da conta com base na nova transação
    if (tx.type == TransactionType.income) {
      currentAccount = currentAccount.copyWith(balance: currentAccount.balance + tx.amount);
    } else if (tx.type == TransactionType.expense) {
      currentAccount = currentAccount.copyWith(balance: currentAccount.balance - tx.amount);
    }
  }

  static Transaction? getTransactionById(String id) {
    try {
      return userTransactions.firstWhere((tx) => tx.id == id);
    } catch (_) {
      return null;
    }
  }
}
