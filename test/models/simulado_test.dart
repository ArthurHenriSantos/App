import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/simulado.dart';
import 'package:app/models/questao.dart';
import 'package:app/models/enums.dart';

void main() {
  group('Testes da Classe Simulado', () {
    final questaoExemplo = Questao(
      id: 'q1',
      enunciado: '2+2?',
      opcoes: ['3', '4'],
      respostaCorreta: Alternativa.B,
      materia: Materia.matematica,
    );

    final mapaSimuladoJson = {
      'id': 's1',
      'titulo': 'Simulado de Matemática',
      'tempoEmMinutos': 60,
      'questoes': [
        {
          'id': 'q1',
          'enunciado': '2+2?',
          'opcoes': ['3', '4'],
          'respostaCorreta': 'B',
          'materia': 'matematica'
        }
      ]
    };

    test('Deve criar Simulado corretamente a partir de JSON', () {
      final simulado = Simulado.fromJson(mapaSimuladoJson);

      expect(simulado.titulo, 'Simulado de Matemática');
      expect(simulado.questoes.first.enunciado, '2+2?');
      expect(simulado.tempoEmMinutos, 60);
    });

    test('Deve converter Simulado para JSON corretamente', () {
      final simulado = Simulado(
        id: 's1',
        titulo: 'Simulado de Matemática',
        questoes: [questaoExemplo],
        tempoEmMinutos: 60,
      );

      final jsonResult = simulado.toJson();
      expect(jsonResult['titulo'], 'Simulado de Matemática');
      expect(jsonResult['questoes'], isA<List>());
    });

    test('Deve alterar apenas o tempo via copyWith', () {
      final simuladoOriginal = Simulado(
        id: 's1',
        titulo: 'Original',
        questoes: [],
        tempoEmMinutos: 30,
      );

      final simuladoEditado = simuladoOriginal.copyWith(tempoEmMinutos: 45);

      expect(simuladoEditado.tempoEmMinutos, 45);
      expect(simuladoEditado.titulo, 'Original');
      expect(simuladoEditado.id, 's1');
    });
  });
}