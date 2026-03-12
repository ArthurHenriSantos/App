import 'package:app/features/bank_account/domain/entities/bank_account.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/enums.dart';

void main() {
  group('Testes da Classe BankAccount', () {
    final mapaJson = {
      'id': 'b1',
      'userId': 'u1',
      'name': 'Nubank',
      'balance': 1500.5,
      'type': 'checking',
      'currency': 'brl'
    };

    test('Deve criar o objeto BankAccount corretamente a partir de um JSON', () {
      final conta = BankAccount.fromJson(mapaJson);
      expect(conta.name, 'Nubank');
      expect(conta.type, BankAccountType.checking);
      expect(conta.balance, 1500.5);
    });

    test('Deve produzir um JSON correto a partir do objeto', () {
      final conta = BankAccount(
        id: 'b1',
        userId: 'u1',
        name: 'Nubank',
        balance: 1500.5,
        type: BankAccountType.checking,
        currency: Currency.brl,
      );

      expect(conta.toJson(), mapaJson);
    });

    test('Deve modificar apenas o saldo via copyWith', () {
      final contaOrig = BankAccount.fromJson(mapaJson);
      final editada = contaOrig.copyWith(balance: 2000.0);

      expect(editada.balance, 2000.0);
      expect(editada.name, contaOrig.name);
    });
  });
}