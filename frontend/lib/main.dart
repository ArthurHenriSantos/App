import 'package:app/features/finance/presentation/pages/dashboard_page.dart';
import 'package:app/features/finance/presentation/pages/metas_page.dart';
import 'package:app/features/finance/presentation/pages/transacoes_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MeuAppSimulados());
}

class MeuAppSimulados extends StatelessWidget {
  const MeuAppSimulados({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koin',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: const Scaffold(
      //   body: Center(
      //     child: Text('Modelos de Domínio Implementados!'),
      //   ),
      // ),
      home: TransacoesPage(),
    );
  }
}