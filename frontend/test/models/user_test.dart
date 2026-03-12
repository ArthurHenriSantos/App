import 'package:app/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/enums.dart';

void main() {
  group('Testes da Classe User', () {
    final mapaJson = {
      'id': 'u1',
      'name': 'João Silva',
      'email': 'joao@email.com',
      'password': 'hash_password',
      'gender': 'male',
      'creationDate': '2023-10-27T10:00:00.000'
    };

    test('Deve criar o objeto User corretamente a partir de um JSON', () {
      final user = User.fromJson(mapaJson);
      
      expect(user.id, 'u1');
      expect(user.gender, Gender.male);
      expect(user.name, 'João Silva');
    });

    test('Deve produzir um JSON (Map) correto a partir do objeto', () {
      final user = User(
        id: 'u1',
        name: 'João Silva',
        email: 'joao@email.com',
        password: 'hash_password',
        gender: Gender.male,
        creationDate: DateTime.parse('2023-10-27T10:00:00.000'),
      );

      final resultado = user.toJson();
      expect(resultado, mapaJson);
    });

    test('Deve modificar apenas o nome via copyWith', () {
      final userOriginal = User.fromJson(mapaJson);
      final novoNome = 'João Santos';
      
      final userEditado = userOriginal.copyWith(name: novoNome);

      expect(userEditado.name, novoNome);
      expect(userEditado.id, userOriginal.id);
      expect(userEditado.email, userOriginal.email);
    });
  });
}