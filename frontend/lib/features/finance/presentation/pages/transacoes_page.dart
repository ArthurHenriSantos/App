import 'package:app/core/services/api_service.dart';
import 'package:app/features/bank_account/domain/entities/bank_account.dart';
import 'package:app/features/transaction/domain/entities/transaction.dart';
import 'package:app/models/enums.dart';
import 'package:app/router/app_router.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransacoesPage extends StatefulWidget {
  final String? initialBankAccountId;

  const TransacoesPage({super.key, this.initialBankAccountId});

  @override
  State<TransacoesPage> createState() => _TransacoesPageState();
}

class _TransacoesPageState extends State<TransacoesPage> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  TransactionType? _selectedTypeFilter;
  final TextEditingController _searchController = TextEditingController();

  List<BankAccount> _accounts = [];
  String? _selectedBankAccountIdFilter;
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _selectedBankAccountIdFilter = widget.initialBankAccountId;
    _loadTransactions();
    _loadAccounts();
  }

  @override
  void didUpdateWidget(covariant TransacoesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBankAccountId != oldWidget.initialBankAccountId) {
      setState(() {
        _selectedBankAccountIdFilter = widget.initialBankAccountId;
      });
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final txs = await ApiService().getTransactions(
        bankAccountId: _selectedBankAccountIdFilter,
      );
      if (mounted) {
        setState(() {
          _transactions = txs;
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

  Future<void> _loadAccounts() async {
    try {
      final accounts = await ApiService().getAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isLoadingAccounts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAccounts = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'Movimentações',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'Movimentações',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.danger),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar movimentações:\n$_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tentar Novamente'),
                  onPressed: _loadTransactions,
                ),
              ],
            ),
          ),
        ),
      );
    }

    
    final filteredTransactions = _transactions.where((tx) {
      final matchesSearch = tx.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedTypeFilter == null || tx.type == _selectedTypeFilter;
      return matchesSearch && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              'Movimentações',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Pesquisar movimentação...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textMutedLight),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.textMutedLight),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.04)),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todas', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Receitas', TransactionType.income),
                    const SizedBox(width: 8),
                    _buildFilterChip('Despesas', TransactionType.expense),
                    const SizedBox(width: 8),
                    _buildFilterChip('Transferências', TransactionType.transfer),
                  ],
                ),
              ),
            ),
            
            if (!_isLoadingAccounts && _accounts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedBankAccountIdFilter,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMutedLight),
                      style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primary, size: 20),
                              SizedBox(width: 10),
                              Text('Todas as Carteiras', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        ..._accounts.map((acc) {
                          IconData iconData = Icons.credit_card_rounded;
                          switch (acc.type) {
                            case BankAccountType.checking: iconData = Icons.account_balance_rounded; break;
                            case BankAccountType.savings: iconData = Icons.savings_rounded; break;
                            case BankAccountType.cash: iconData = Icons.payments_rounded; break;
                            case BankAccountType.creditCard: iconData = Icons.credit_card_rounded; break;
                          }
                          return DropdownMenuItem<String?>(
                            value: acc.id,
                            child: Row(
                              children: [
                                Icon(iconData, color: AppTheme.primary, size: 20),
                                const SizedBox(width: 10),
                                Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text(
                                  'R\$ ${acc.balance.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    color: AppTheme.textMutedLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedBankAccountIdFilter = val;
                        });
                        _loadTransactions();
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            
            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: AppTheme.textMutedLight.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma movimentação encontrada.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 800) {
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 90,
                            ),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) =>
                                _TransactionTile(tx: filteredTransactions[index]),
                          );
                        } else {
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            itemCount: filteredTransactions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) =>
                                _TransactionTile(tx: filteredTransactions[index]),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_movimentacoes',
        onPressed: () async {
          await context.push(AppRoutes.novaTransacao);
          _loadTransactions();
        },
        backgroundColor: AppTheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionType? type) {
    final isSelected = _selectedTypeFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTypeFilter = type;
        });
      },
      selectedColor: AppTheme.primary.withOpacity(0.12),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : AppTheme.textMutedLight,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primary.withOpacity(0.3) : Colors.black.withOpacity(0.05),
        ),
      ),
      showCheckmark: false,
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? AppTheme.accent : AppTheme.danger;
    final icon = isIncome ? Icons.trending_up : Icons.trending_down;

    final amountStr = isIncome
        ? '+ R\$ ${tx.amount.toStringAsFixed(2).replaceAll('.', ',')}'
        : '- R\$ ${tx.amount.toStringAsFixed(2).replaceAll('.', ',')}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.detalheTransacao(tx.id)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tx.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${tx.transactionDate.day.toString().padLeft(2, '0')}/${tx.transactionDate.month.toString().padLeft(2, '0')}/${tx.transactionDate.year}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMutedLight),
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
              color: color,
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}