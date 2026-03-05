import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/questao.dart';
import 'package:app/models/enums.dart';

void main() {
  group('Testes da Classe Questao', () {
    final mapaJson = {
      'id': 'q1',
      'enunciado': 'Qual a capital do Brasil?',
      'opcoes': ['Rio', 'Brasília', 'SP'],
      'respostaCorreta': 'B',
      'materia': 'geografia'
    };

    test('Deve criar o objeto Questao corretamente a partir de um JSON', () {
      final questao = Questao.fromJson(mapaJson);
      
      expect(questao.id, 'q1');
      expect(questao.materia, Materia.geografia);
      expect(questao.opcoes.length, 3);
    });

    test('Deve produzir um JSON (Map) correto a partir do objeto', () {
      final questao = Questao(
        id: 'q1',
        enunciado: 'Qual a capital do Brasil?',
        opcoes: ['Rio', 'Brasília', 'SP'],
        respostaCorreta: Alternativa.B,
        materia: Materia.geografia,
      );

      final resultado = questao.toJson();
      expect(resultado, mapaJson);
    });

    test('Deve modificar apenas o enunciado via copyWith', () {
      final questaoOriginal = Questao.fromJson(mapaJson);
      final novoEnunciado = 'Qual a capital federal?';
      
      final questaoEditada = questaoOriginal.copyWith(enunciado: novoEnunciado);

      expect(questaoEditada.enunciado, novoEnunciado);
      expect(questaoEditada.id, questaoOriginal.id);
      expect(questaoEditada.materia, questaoOriginal.materia);
    });
  });
}