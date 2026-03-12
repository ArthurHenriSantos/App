import 'package:app/features/transaction/domain/entities/transaction_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/enums.dart';

void main() {
  group('Testes da Classe TransactionCategory', () {
    final mapaJson = {
      'id': 'cat1',
      'userId': 'u1',
      'name': 'Alimentação',
      'icon': 'fastfood',
      'color': '#FF0000',
      'type': 'expense'
    };

    test('Deve criar TransactionCategory corretamente do JSON', () {
      final cat = TransactionCategory.fromJson(mapaJson);
      expect(cat.name, 'Alimentação');
      expect(cat.type, TransactionType.expense);
    });

    test('Deve produzir um JSON correto', () {
      final cat = TransactionCategory(
        id: 'cat1',
        userId: 'u1',
        name: 'Alimentação',
        icon: 'fastfood',
        color: '#FF0000',
        type: TransactionType.expense,
      );
      expect(cat.toJson(), mapaJson);
    });

    test('Deve modificar a cor via copyWith', () {
      final catOrig = TransactionCategory.fromJson(mapaJson);
      final editada = catOrig.copyWith(color: '#000000');

      expect(editada.color, '#000000');
      expect(editada.name, catOrig.name);
    });
  });
}