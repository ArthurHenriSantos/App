import 'package:flutter/foundation.dart';
import 'questao.dart';

class Simulado {
  final String id;
  final String titulo;
  final List<Questao> questoes;
  final int tempoEmMinutos;

  Simulado({
    required this.id,
    required this.titulo,
    required this.questoes,
    required this.tempoEmMinutos,
  });

  factory Simulado.fromJson(Map<String, dynamic> json) {
    return Simulado(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      tempoEmMinutos: json['tempoEmMinutos'] as int,
      questoes: (json['questoes'] as List)
          .map((q) => Questao.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'tempoEmMinutos': tempoEmMinutos,
        'questoes': questoes.map((q) => q.toJson()).toList(),
      };

  Simulado copyWith({
    String? titulo,
    List<Questao>? questoes,
    int? tempoEmMinutos,
  }) {
    return Simulado(
      id: id,
      titulo: titulo ?? this.titulo,
      questoes: questoes ?? this.questoes,
      tempoEmMinutos: tempoEmMinutos ?? this.tempoEmMinutos,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Simulado &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          titulo == other.titulo &&
          listEquals(questoes, other.questoes) &&
          tempoEmMinutos == other.tempoEmMinutos;

  @override
  int get hashCode =>
      id.hashCode ^
      titulo.hashCode ^
      questoes.hashCode ^
      tempoEmMinutos.hashCode;
}