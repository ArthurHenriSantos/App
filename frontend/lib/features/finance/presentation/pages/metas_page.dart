import 'package:flutter/material.dart';

class MetasPage extends StatelessWidget {
  const MetasPage({super.key});

  static const _goals = [
    _Goal('VIAGEM (1 ANO)', 5200, 8000, Color(0xFF2563EB)),
    _Goal('CARRO (5 ANOS)', 31800, 100000, Color(0xFF0891B2)),
    _Goal('BÔNUS', 50, 50, Color(0xFF16A34A)),
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: _goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _GoalCard(goal: _goals[index]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(currentIndex: 2),
    );
  }
}

class _Goal {
  final String title;
  final double current;
  final double total;
  final Color color;
  const _Goal(this.title, this.current, this.total, this.color);

  double get progress => (current / total).clamp(0.0, 1.0);
  bool get completed => current >= total;
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seu Progresso',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Metas',
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

class _GoalCard extends StatelessWidget {
  final _Goal goal;
  const _GoalCard({super.key, required this.goal});

  String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    final isCompleted = goal.completed;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFDCFCE7)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: const Color(0xFF16A34A).withOpacity(0.4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: goal.color,
                  letterSpacing: 1.2,
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Concluído',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: 10),
            Text(
              '+ ${_fmt(goal.current)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16A34A),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: goal.color.withOpacity(0.12),
                color: goal.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_fmt(goal.current)} / ${_fmt(goal.total)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
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
      // showLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Transações'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'Gráficos'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
      ],
    );
  }
}