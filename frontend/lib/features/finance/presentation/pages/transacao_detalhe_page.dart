import 'package:app/core/services/api_service.dart';
import 'package:app/features/transaction/domain/entities/transaction.dart';
import 'package:app/models/enums.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailPage extends StatefulWidget {
  final String transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  Transaction? _transaction;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tx = await ApiService().getTransactionById(widget.transactionId);
      if (mounted) {
        setState(() {
          _transaction = tx;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      );
    }

    final tx = _transaction;

    // Caso a transação não seja encontrada ou dê erro
    if (tx == null || _errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhe'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 64, color: AppTheme.danger),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Transação não encontrada.',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Voltar'),
              )
            ],
          ),
        ),
      );
    }

    final isIncome = tx.type == TransactionType.income;
    final themeColor = isIncome ? AppTheme.accent : AppTheme.danger;
    final icon = isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final formattedAmount = 'R\$ ${tx.amount.toStringAsFixed(2).replaceAll('.', ',')}';
    final formattedDate =
        '${tx.transactionDate.day.toString().padLeft(2, '0')}/${tx.transactionDate.month.toString().padLeft(2, '0')}/${tx.transactionDate.year} às ${tx.transactionDate.hour.toString().padLeft(2, '0')}:${tx.transactionDate.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          'Detalhes da Transação',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Card Principal Premium de Visualização
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Ícone de Transação Redondo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: themeColor, size: 36),
                  ),
                  const SizedBox(height: 20),
                  // Valor de Destaque
                  Text(
                    isIncome ? '+ $formattedAmount' : '- $formattedAmount',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tx.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 24),
                  // Lista de Propriedades Detalhadas
                  _buildDetailRow(
                    label: 'Status do Pagamento',
                    value: 'Concluído',
                    valueColor: AppTheme.accent,
                    isStatus: true,
                  ),
                  _buildDetailRow(
                    label: 'Data e Hora',
                    value: formattedDate,
                  ),
                  _buildDetailRow(
                    label: 'Tipo de Transação',
                    value: isIncome ? 'Receita' : 'Despesa',
                  ),
                  _buildDetailRow(
                    label: 'Conta de Origem',
                    value: 'Carteira Principal',
                  ),
                  _buildDetailRow(
                    label: 'ID da Transação',
                    value: tx.id,
                    isId: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Botão Voltar para Lista
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: Colors.black.withOpacity(0.08)),
              ),
              child: const Text(
                'Voltar ao Histórico',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isStatus = false,
    bool isId = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMutedLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? (isId ? Colors.grey : AppTheme.textDark),
                fontFamily: isId ? 'monospace' : null,
              ),
            ),
        ],
      ),
    );
  }
}
