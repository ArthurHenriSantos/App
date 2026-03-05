import 'package:flutter/material.dart';
import 'models/questao.dart';

void main() {
  runApp(const MeuAppSimulados());
}

class MeuAppSimulados extends StatelessWidget {
  const MeuAppSimulados({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulados Vestibular',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: Center(
          child: Text('Modelos de Domínio Implementados!'),
        ),
      ),
    );
  }
}