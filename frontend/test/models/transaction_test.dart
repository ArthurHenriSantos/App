import 'package:app/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/enums.dart';

void main() {
  group('Testes da Classe Transaction', () {
    final mapaJson = {
      'id': 't1',
      'bankAccountId': 'b1',
      'destinationBankAccountId': null,
      'type': 'expense',
      'transactionCategoryId': 'cat1',
      'amount': 50.0,
      'description': 'Lanche',
      'transactionDate': '2023-10-27T12:00:00.000',
      'creationDate': '2023-10-27T12:00:00.000'
    };

    test('Deve criar Transaction corretamente do JSON', () {
      final trans = Transaction.fromJson(mapaJson);
      expect(trans.amount, 50.0);
      expect(trans.type, TransactionType.expense);
    });

    test('Deve produzir um JSON correto', () {
      final trans = Transaction(
        id: 't1',
        bankAccountId: 'b1',
        type: TransactionType.expense,
        transactionCategoryId: 'cat1',
        amount: 50.0,
        description: 'Lanche',
        transactionDate: DateTime.parse('2023-10-27T12:00:00.000'),
        creationDate: DateTime.parse('2023-10-27T12:00:00.000'),
      );
      expect(trans.toJson(), mapaJson);
    });

    test('Deve modificar a descrição via copyWith', () {
      final transOrig = Transaction.fromJson(mapaJson);
      final editada = transOrig.copyWith(description: 'Jantar');

      expect(editada.description, 'Jantar');
      expect(editada.amount, transOrig.amount);
    });
  });
}