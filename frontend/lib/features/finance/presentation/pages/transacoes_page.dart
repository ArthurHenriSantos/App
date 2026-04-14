import 'package:flutter/material.dart';

class TransacoesPage extends StatelessWidget {
  const TransacoesPage({super.key});

  static const _transactions = [
    _Transaction('Almoço Executivo', 'Hoje, 12:30', -45.0, Icons.restaurant),
    _Transaction('Economia Hábito', 'Hoje, 09:00', 20.0, Icons.eco),
    _Transaction('Transporte', 'Ontem, 18:15', -8.5, Icons.directions_bus),
    _Transaction('Supermercado', 'Ontem, 14:00', -120.0, Icons.shopping_cart),
    _Transaction('Rendimento', '01 Mar, 2026', 12.4, Icons.trending_up),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 cards por linha
                        crossAxisSpacing: 16, // Espaço horizontal
                        mainAxisSpacing: 16, // Espaço vertical
                        mainAxisExtent: 90, // Altura fixa com respiro para evitar overflow
                      ),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) =>
                          _TransactionTile(tx: _transactions[index]),
                    );
                  } 
                  else {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: _transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _TransactionTile(tx: _transactions[index]),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 1),
    );
  }
}

class _Transaction {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  const _Transaction(this.title, this.subtitle, this.amount, this.icon);
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Transações',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2340),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final _Transaction tx;
  const _TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.amount > 0;
    final amountColor = isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final amountStr = isPositive ? '+ R\$ ${tx.amount.toStringAsFixed(2).replaceAll('.', ',')}' : '- R\$ ${tx.amount.abs().toStringAsFixed(2).replaceAll('.', ',')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tx.icon, color: const Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2340),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tx.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountStr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: Colors.grey[400],
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Transações'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'Gráficos'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
      ],
    );
  }
}