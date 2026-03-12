import 'package:app/features/goal/domain/entities/goal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/enums.dart';

void main() {
  group('Testes da Classe Goal', () {
    final mapaJson = {
      'id': 'g1',
      'userId': 'u1',
      'bankAccountId': 'b1',
      'name': 'Viagem',
      'targetAmount': 5000.0,
      'currentAmount': 1000.0,
      'status': 'inProgress',
      'deadlineDate': '2024-12-31T23:59:59.000'
    };

    test('Deve criar Goal corretamente do JSON', () {
      final goal = Goal.fromJson(mapaJson);
      expect(goal.targetAmount, 5000.0);
      expect(goal.status, GoalStatus.inProgress);
    });

    test('Deve produzir um JSON correto', () {
      final goal = Goal(
        id: 'g1',
        userId: 'u1',
        bankAccountId: 'b1',
        name: 'Viagem',
        targetAmount: 5000.0,
        currentAmount: 1000.0,
        status: GoalStatus.inProgress,
        deadlineDate: DateTime.parse('2024-12-31T23:59:59.000'),
      );
      expect(goal.toJson(), mapaJson);
    });

    test('Deve atualizar valor atual via copyWith', () {
      final goalOrig = Goal.fromJson(mapaJson);
      final editada = goalOrig.copyWith(currentAmount: 1200.0);

      expect(editada.currentAmount, 1200.0);
      expect(editada.targetAmount, goalOrig.targetAmount);
    });
  });
}