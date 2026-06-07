import 'dart:ui';
import 'package:app/core/services/api_service.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/bank_account/domain/entities/bank_account.dart';
import 'package:app/models/enums.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:app/router/app_router.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? _user;
  List<BankAccount> _accounts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final user = await apiService.getMe();
      final accounts = await apiService.getAccounts();

      if (mounted) {
        setState(() {
          _user = user;
          _accounts = accounts;
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

  void _showCreateAccountBottomSheet() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    BankAccountType selectedType = BankAccountType.checking;
    Currency selectedCurrency = Currency.brl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Nova Carteira',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Nome da Carteira',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          style: const TextStyle(color: AppTheme.textDark),
                          decoration: InputDecoration(
                            hintText: 'Ex: Carteira Nubank, Conta Poupança',
                            hintStyle: const TextStyle(color: AppTheme.textMutedLight),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.black.withOpacity(0.04)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Digite o nome';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Saldo Inicial (R\$)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: balanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: AppTheme.textDark),
                          decoration: InputDecoration(
                            hintText: '0,00',
                            hintStyle: const TextStyle(color: AppTheme.textMutedLight),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.black.withOpacity(0.04)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Digite o saldo';
                            final cleaned = value.replaceAll(',', '.');
                            if (double.tryParse(cleaned) == null) return 'Valor inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tipo de Conta',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<BankAccountType>(
                                        value: selectedType,
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
                                        items: BankAccountType.values.map((type) {
                                          String label = '';
                                          switch (type) {
                                            case BankAccountType.checking: label = 'Corrente'; break;
                                            case BankAccountType.savings: label = 'Poupança'; break;
                                            case BankAccountType.cash: label = 'Dinheiro'; break;
                                            case BankAccountType.creditCard: label = 'Crédito'; break;
                                          }
                                          return DropdownMenuItem<BankAccountType>(
                                            value: type,
                                            child: Text(label),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setModalState(() {
                                              selectedType = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Moeda',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Currency>(
                                        value: selectedCurrency,
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
                                        items: Currency.values.map((currency) {
                                          return DropdownMenuItem<Currency>(
                                            value: currency,
                                            child: Text(currency.name.toUpperCase()),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setModalState(() {
                                              selectedCurrency = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            Navigator.pop(context);
                            
                            setState(() {
                              _isLoading = true;
                            });
                            
                            try {
                              final name = nameController.text.trim();
                              final balance = double.parse(balanceController.text.replaceAll(',', '.'));
                              await ApiService().createAccount(
                                name: name,
                                balance: balance,
                                type: selectedType,
                                currency: selectedCurrency,
                              );
                              _loadData();
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao criar carteira: $e'),
                                    backgroundColor: AppTheme.danger,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Criar Carteira',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAccountActionsBottomSheet(BankAccount account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final accountsCount = _accounts.length;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  account.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'Saldo: R\$ ${account.balance.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMutedLight,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.list_alt_rounded, color: AppTheme.primary),
                  title: const Text('Visualizar Movimentações', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/transacoes?bankAccountId=${account.id}');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                  title: const Text('Editar Carteira', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditAccountBottomSheet(account);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger),
                  title: const Text('Excluir Carteira', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.danger)),
                  onTap: () {
                    Navigator.pop(context);
                    if (accountsCount <= 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você precisa ter pelo menos uma carteira ativa.'),
                          backgroundColor: AppTheme.danger,
                        ),
                      );
                      return;
                    }
                    _showDeleteAccountConfirmDialog(account);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountConfirmDialog(BankAccount account) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Excluir "${account.name}"?'),
          content: const Text(
            'ATENÇÃO: Ao excluir esta carteira, todas as movimentações associadas a ela serão excluídas permanentemente do sistema.\n\nEsta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMutedLight)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                });
                try {
                  await ApiService().deleteAccount(account.id);
                  _loadData();
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir carteira: $e'),
                        backgroundColor: AppTheme.danger,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showEditAccountBottomSheet(BankAccount account) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: account.name);
    BankAccountType selectedType = account.type;
    Currency selectedCurrency = account.currency;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Editar Carteira',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Nome da Carteira',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          style: const TextStyle(color: AppTheme.textDark),
                          decoration: InputDecoration(
                            hintText: 'Ex: Carteira Nubank, Conta Poupança',
                            hintStyle: const TextStyle(color: AppTheme.textMutedLight),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.black.withOpacity(0.04)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Digite o nome';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tipo de Conta',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<BankAccountType>(
                                        value: selectedType,
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
                                        items: BankAccountType.values.map((type) {
                                          String label = '';
                                          switch (type) {
                                            case BankAccountType.checking: label = 'Corrente'; break;
                                            case BankAccountType.savings: label = 'Poupança'; break;
                                            case BankAccountType.cash: label = 'Dinheiro'; break;
                                            case BankAccountType.creditCard: label = 'Crédito'; break;
                                          }
                                          return DropdownMenuItem<BankAccountType>(
                                            value: type,
                                            child: Text(label),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setModalState(() {
                                              selectedType = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Moeda',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Currency>(
                                        value: selectedCurrency,
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
                                        items: Currency.values.map((currency) {
                                          return DropdownMenuItem<Currency>(
                                            value: currency,
                                            child: Text(currency.name.toUpperCase()),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setModalState(() {
                                              selectedCurrency = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            Navigator.pop(context);
                            
                            setState(() {
                              _isLoading = true;
                            });
                            
                            try {
                              final name = nameController.text.trim();
                              await ApiService().updateAccount(
                                id: account.id,
                                name: name,
                                type: selectedType,
                                currency: selectedCurrency,
                              );
                              _loadData();
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao editar carteira: $e'),
                                    backgroundColor: AppTheme.danger,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Salvar Alterações',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.danger),
                const SizedBox(height: 16),
                Text(
                  'Erro ao conectar à API:\n$_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tentar Novamente'),
                  onPressed: _loadData,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = _user!;
    final accounts = _accounts;
    
    final mediaQuery = MediaQuery.of(context);
    final isCompact = mediaQuery.size.height < 700;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppTheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${user.name.split(' ').first}!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                ),
                Text(
                  'Bem-vindo de volta',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.textMutedLight,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sair da conta'),
                  content: const Text('Deseja realmente sair?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sair',
                          style: TextStyle(color: AppTheme.danger)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                ApiService().logout();
                AppRouter.isAuthenticated = false;
                context.go(AppRoutes.login);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: isCompact ? 12 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: accounts.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    if (index == accounts.length) {
                      return _AddAccountCard(onTap: _showCreateAccountBottomSheet);
                    }
                    final account = accounts[index];
                    return _SavingsCreditCard(
                      account: account,
                      onTap: () => _showAccountActionsBottomSheet(account),
                    );
                  },
                ),
              ),
              SizedBox(height: isCompact ? 16 : 24),
              const _WeeklyChartSection(),
              SizedBox(height: isCompact ? 16 : 24),
              const _HabitsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavingsCreditCard extends StatelessWidget {
  final BankAccount account;
  final VoidCallback onTap;

  const _SavingsCreditCard({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 290,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -60,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondary.withOpacity(0.15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        account.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Saldo Disponível',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'R\$ ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        account.balance.toStringAsFixed(2).replaceAll('.', ','),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            account.currency.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _AddAccountCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAccountCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 150,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.15),
            style: BorderStyle.solid,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppTheme.primary, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nova Carteira',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChartSection extends StatelessWidget {
  const _WeeklyChartSection();

  final List<double> values = const [0.4, 0.6, 0.5, 0.7, 0.9, 0.8, 1.0];
  final List<String> days = const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ECONOMIA SEMANAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final isToday = i == 6;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (i * 50)),
                        width: 14,
                        height: 90 * values[i],
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isToday
                                ? [AppTheme.secondary, AppTheme.primary]
                                : [
                                    AppTheme.primary.withOpacity(0.15),
                                    AppTheme.primary.withOpacity(0.25)
                                  ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday ? AppTheme.primary : AppTheme.textMutedLight,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsSection extends StatelessWidget {
  const _HabitsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HÁBITOS EM FOCO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _HabitCard(
                icon: Icons.smoke_free,
                label: 'Sem Cigarros',
                days: 8,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _HabitCard(
                icon: Icons.no_drinks,
                label: 'Sem Álcool',
                days: 12,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HabitCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int days;
  final Color color;

  const _HabitCard({
    required this.icon,
    required this.label,
    required this.days,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMutedLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$days dias',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}