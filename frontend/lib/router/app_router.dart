// Removido MockDatabase import
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/finance/presentation/pages/dashboard_page.dart';
import 'package:app/features/finance/presentation/pages/main_layout.dart';
import 'package:app/features/finance/presentation/pages/metas_page.dart';
import 'package:app/features/finance/presentation/pages/nova_transacao_page.dart';
import 'package:app/features/finance/presentation/pages/transacao_detalhe_page.dart';
import 'package:app/features/finance/presentation/pages/transacoes_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String transacoes = '/transacoes';
  static const String metas = '/metas';
  static const String novaTransacao = '/nova-transacao';
  
  static String detalheTransacao(String id) => '/transacoes/$id';

  // Nomes das rotas
  static const String nomeLogin = 'login';
  static const String nomeDashboard = 'dashboard';
  static const String nomeTransacoes = 'transacoes';
  static const String nomeMetas = 'metas';
  static const String nomeNovaTransacao = 'novaTransacao';
  static const String nomeDetalheTransacao = 'detalheTransacao';
}

class AppRouter {
  static bool isAuthenticated = false;

  static final GoRouter roteador = GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final bool loggingIn = state.matchedLocation == AppRoutes.login;
      
      if (!isAuthenticated) {
        return AppRoutes.login;
      }
      
      if (isAuthenticated && loggingIn) {
        return AppRoutes.dashboard;
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.nomeLogin,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: AppRoutes.nomeDashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transacoes,
                name: AppRoutes.nomeTransacoes,
                builder: (context, state) => const TransacoesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.metas,
                name: AppRoutes.nomeMetas,
                builder: (context, state) => const MetasPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.novaTransacao,
        name: AppRoutes.nomeNovaTransacao,
        builder: (context, state) => const NovaTransacaoPage(),
      ),
      GoRoute(
        path: '/transacoes/:id',
        name: AppRoutes.nomeDetalheTransacao,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailPage(transactionId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'A rota "${state.uri}"\nnão foi encontrada no Koin.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.home_rounded),
              label: const Text('Voltar ao início'),
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
          ],
        ),
      ),
    ),
  );
}
