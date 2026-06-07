import 'dart:ui';
import 'package:app/core/services/api_service.dart';
import 'package:app/features/bank_account/domain/entities/bank_account.dart';
import 'package:app/models/enums.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NovaMovimentacaoPage extends StatefulWidget {
  const NovaMovimentacaoPage({super.key});

  @override
  State<NovaMovimentacaoPage> createState() => _NovaMovimentacaoPageState();
}

class _NovaMovimentacaoPageState extends State<NovaMovimentacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  
  TransactionType _selectedType = TransactionType.expense;
  bool _isLoading = false;

  List<BankAccount> _accounts = [];
  bool _isLoadingAccounts = true;
  String? _selectedSourceBankAccountId;
  String? _selectedDestinationBankAccountId;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await ApiService().getAccounts();
      String? defaultSourceId;
      try {
        final primary = await ApiService().getPrimaryAccount();
        defaultSourceId = primary.id;
      } catch (_) {
        if (accounts.isNotEmpty) {
          defaultSourceId = accounts.first.id;
        }
      }
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _selectedSourceBankAccountId = defaultSourceId;
          _isLoadingAccounts = false;
          
          if (_selectedDestinationBankAccountId == null && accounts.length > 1) {
            _selectedDestinationBankAccountId = accounts.firstWhere((a) => a.id != defaultSourceId, orElse: () => accounts.last).id;
          }
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
    _descriptionController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSourceBankAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione a conta/carteira de origem.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }
    if (_selectedType == TransactionType.transfer && _selectedDestinationBankAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione a conta de destino para a transação.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }
    if (_selectedType == TransactionType.transfer && _selectedDestinationBankAccountId == _selectedSourceBankAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A conta de destino deve ser diferente da conta de origem.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      await apiService.createTransaction(
        bankAccountId: _selectedSourceBankAccountId!,
        type: _selectedType,
        amount: amount,
        description: _descriptionController.text.trim(),
        destinationBankAccountId: _selectedType == TransactionType.transfer ? _selectedDestinationBankAccountId : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Movimentação adicionada com sucesso!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erro ao salvar movimentação: ${e.toString().replaceAll('Exception: ', '')}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _selectedType == TransactionType.expense
        ? AppTheme.danger
        : (_selectedType == TransactionType.income ? AppTheme.accent : AppTheme.primary);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova Movimentação',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: themeColor.withOpacity(0.12)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'VALOR DA MOVIMENTAÇÃO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMutedLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'R\$',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 200,
                                child: TextFormField(
                                  controller: _amountController,
                                  focusNode: _amountFocusNode,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.center,
                                  textInputAction: TextInputAction.done,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '0,00',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Por favor, insira o valor';
                                    }
                                    final cleanedValue = value.replaceAll(',', '.');
                                    final number = double.tryParse(cleanedValue);
                                    if (number == null) {
                                      return 'Insira um valor numérico válido';
                                    }
                                    if (number <= 0) {
                                      return 'O valor deve ser maior que zero';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Tipo de Movimentação',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedType = TransactionType.expense;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: _selectedType == TransactionType.expense ? AppTheme.danger.withOpacity(0.08) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedType == TransactionType.expense ? AppTheme.danger.withOpacity(0.4) : Colors.black.withOpacity(0.06),
                                  width: _selectedType == TransactionType.expense ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.trending_down_rounded,
                                    color: _selectedType == TransactionType.expense ? AppTheme.danger : AppTheme.textMutedLight,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Despesa',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedType = TransactionType.income;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: _selectedType == TransactionType.income ? AppTheme.accent.withOpacity(0.08) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedType == TransactionType.income ? AppTheme.accent.withOpacity(0.4) : Colors.black.withOpacity(0.06),
                                  width: _selectedType == TransactionType.income ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    color: _selectedType == TransactionType.income ? AppTheme.accent : AppTheme.textMutedLight,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Receita',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedType = TransactionType.transfer;
                                if (_selectedDestinationBankAccountId == _selectedSourceBankAccountId) {
                                  if (_accounts.length > 1) {
                                    _selectedDestinationBankAccountId = _accounts.firstWhere((a) => a.id != _selectedSourceBankAccountId, orElse: () => _accounts.last).id;
                                  } else {
                                    _selectedDestinationBankAccountId = null;
                                  }
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: _selectedType == TransactionType.transfer ? AppTheme.primary.withOpacity(0.08) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedType == TransactionType.transfer ? AppTheme.primary.withOpacity(0.4) : Colors.black.withOpacity(0.06),
                                  width: _selectedType == TransactionType.transfer ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    color: _selectedType == TransactionType.transfer ? AppTheme.primary : AppTheme.textMutedLight,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Transação',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedType == TransactionType.transfer ? AppTheme.primary : AppTheme.textMutedLight,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    Text(
                      _selectedType == TransactionType.transfer ? 'Conta de Origem' : 'Carteira / Conta',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoadingAccounts
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withOpacity(0.06)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String?>(
                                value: _selectedSourceBankAccountId,
                                decoration: const InputDecoration(border: InputBorder.none),
                                style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
                                hint: const Text('Selecione a conta/carteira', style: TextStyle(color: AppTheme.textMutedLight)),
                                items: _accounts.map((acc) {
                                  return DropdownMenuItem<String?>(
                                    value: acc.id,
                                    child: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedSourceBankAccountId = val;
                                    if (_selectedDestinationBankAccountId == _selectedSourceBankAccountId) {
                                      if (_accounts.length > 1) {
                                        _selectedDestinationBankAccountId = _accounts.firstWhere((a) => a.id != val, orElse: () => _accounts.last).id;
                                      } else {
                                        _selectedDestinationBankAccountId = null;
                                      }
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Por favor, selecione a conta/carteira';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                    if (_selectedType == TransactionType.transfer) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Conta de Destino',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _isLoadingAccounts
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black.withOpacity(0.06)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String?>(
                                  value: _selectedDestinationBankAccountId,
                                  decoration: const InputDecoration(border: InputBorder.none),
                                  style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
                                  hint: const Text('Selecione a conta destino', style: TextStyle(color: AppTheme.textMutedLight)),
                                  items: _accounts
                                      .where((acc) => acc.id != _selectedSourceBankAccountId)
                                      .map((acc) {
                                        return DropdownMenuItem<String?>(
                                          value: acc.id,
                                          child: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        );
                                      }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedDestinationBankAccountId = val;
                                    });
                                  },
                                  validator: (value) {
                                    if (_selectedType == TransactionType.transfer && value == null) {
                                      return 'Por favor, selecione a conta de destino';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                    ],
                    const SizedBox(height: 28),
                    
                    const Text(
                      'Descrição da Movimentação',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: AppTheme.textDark),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_amountFocusNode);
                      },
                      decoration: InputDecoration(
                        hintText: 'Ex: Aluguel, Supermercado, Salário',
                        hintStyle: const TextStyle(color: AppTheme.textMutedLight),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.edit_note_rounded, color: AppTheme.textMutedLight),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.danger),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira a descrição';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [themeColor, themeColor.withOpacity(0.8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withOpacity(0.24),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_rounded, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              'Salvar Movimentação',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
