import 'package:flutter/foundation.dart';
import 'enums.dart';

class Questao {
  final String id;
  final String enunciado;
  final List<String> opcoes;
  final Alternativa respostaCorreta;
  final Materia materia;

  Questao({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorreta,
    required this.materia,
  });

  factory Questao.fromJson(Map<String, dynamic> json) {
    return Questao(
      id: json['id'] as String,
      enunciado: json['enunciado'] as String,
      opcoes: List<String>.from(json['opcoes']),
      respostaCorreta: Alternativa.values.byName(json['respostaCorreta']),
      materia: Materia.values.byName(json['materia']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'enunciado': enunciado,
        'opcoes': opcoes,
        'respostaCorreta': respostaCorreta.name,
        'materia': materia.name,
      };

  Questao copyWith({
    String? enunciado,
    List<String>? opcoes,
    Alternativa? respostaCorreta,
    Materia? materia,
  }) {
    return Questao(
      id: id,
      enunciado: enunciado ?? this.enunciado,
      opcoes: opcoes ?? this.opcoes,
      respostaCorreta: respostaCorreta ?? this.respostaCorreta,
      materia: materia ?? this.materia,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Questao &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          enunciado == other.enunciado &&
          listEquals(opcoes, other.opcoes) &&
          respostaCorreta == other.respostaCorreta &&
          materia == other.materia;

  @override
  int get hashCode =>
      id.hashCode ^
      enunciado.hashCode ^
      opcoes.hashCode ^
      respostaCorreta.hashCode ^
      materia.hashCode;
}