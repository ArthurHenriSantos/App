import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/auth/presentation/pages/register_page.dart';
import 'package:app/features/finance/presentation/pages/dashboard_page.dart';
import 'package:app/features/finance/presentation/pages/main_layout.dart';
import 'package:app/features/finance/presentation/pages/metas_page.dart';
import 'package:app/features/finance/presentation/pages/nova_transacao_page.dart';
import 'package:app/features/finance/presentation/pages/transacao_detalhe_page.dart';
import 'package:app/features/finance/presentation/pages/transacoes_page.dart';
import 'package:app/features/finance/presentation/pages/nova_meta_page.dart';
import 'package:app/features/finance/presentation/pages/meta_detalhe_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String transacoes = '/transacoes';
  static const String metas = '/metas';
  static const String novaTransacao = '/nova-transacao';
  static const String novaMeta = '/metas/nova';

  static String detalheTransacao(String id) => '/transacoes/$id';
  static String detalheMeta(String id) => '/metas/$id';

  
  static const String nomeLogin = 'login';
  static const String nomeRegister = 'register';
  static const String nomeDashboard = 'dashboard';
  static const String nomeTransacoes = 'transacoes';
  static const String nomeMetas = 'metas';
  static const String nomeNovaTransacao = 'novaTransacao';
  static const String nomeDetalheTransacao = 'detalheTransacao';
  static const String nomeNovaMeta = 'novaMeta';
  static const String nomeDetalheMeta = 'detalheMeta';
}

class AppRouter {
  static bool isAuthenticated = false;

  static final GoRouter roteador = GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final bool loggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isAuthenticated && !loggingIn) {
        return AppRoutes.login;
      }

      if (isAuthenticated && state.matchedLocation == AppRoutes.login) {
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
      GoRoute(
        path: AppRoutes.register,
        name: AppRoutes.nomeRegister,
        builder: (context, state) => const RegisterPage(),
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
                builder: (context, state) {
                  final initialBankAccountId = state.uri.queryParameters['bankAccountId'];
                  return TransacoesPage(initialBankAccountId: initialBankAccountId);
                },
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
        builder: (context, state) => const NovaMovimentacaoPage(),
      ),
      GoRoute(
        path: '/transacoes/:id',
        name: AppRoutes.nomeDetalheTransacao,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailPage(transactionId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.novaMeta,
        name: AppRoutes.nomeNovaMeta,
        builder: (context, state) => const NovaMetaPage(),
      ),
      GoRoute(
        path: '/metas/:id',
        name: AppRoutes.nomeDetalheMeta,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MetaDetalhePage(goalId: id);
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
