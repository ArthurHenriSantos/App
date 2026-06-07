import 'dart:ui';
import 'package:app/core/services/api_service.dart';
import 'package:app/features/bank_account/domain/entities/bank_account.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NovaMetaPage extends StatefulWidget {
  const NovaMetaPage({super.key});

  @override
  State<NovaMetaPage> createState() => _NovaMetaPageState();
}

class _NovaMetaPageState extends State<NovaMetaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocusNode = FocusNode();
  
  DateTime? _selectedDeadline;
  String? _selectedBankAccountId;
  List<BankAccount> _accounts = [];
  bool _isLoadingAccounts = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
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
    _nameController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDeadlineDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione a data limite.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final targetAmount = double.parse(_amountController.text.replaceAll(',', '.'));
      await ApiService().createGoal(
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        deadlineDate: _selectedDeadline!,
        bankAccountId: _selectedBankAccountId,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Meta criada com sucesso!',
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

        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erro ao criar meta: ${e.toString().replaceAll('Exception: ', '')}',
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
    final themeColor = AppTheme.primary;
    final dateStr = _selectedDeadline == null
        ? 'Selecionar data'
        : '${_selectedDeadline!.day.toString().padLeft(2, '0')}/${_selectedDeadline!.month.toString().padLeft(2, '0')}/${_selectedDeadline!.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova Meta',
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
                            'VALOR ALVO DA META',
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
                                  textInputAction: TextInputAction.next,
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
                      'Nome da Meta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(color: AppTheme.textDark),
                      decoration: InputDecoration(
                        hintText: 'Ex: Viagem Japão, Reserva de Emergência',
                        hintStyle: const TextStyle(color: AppTheme.textMutedLight),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.flag_outlined, color: AppTheme.textMutedLight),
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
                          return 'Por favor, insira o nome da meta';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Prazo da Meta (Data Limite)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectDeadlineDate(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black.withOpacity(0.06)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppTheme.textMutedLight),
                            const SizedBox(width: 12),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDeadline == null ? AppTheme.textMutedLight : AppTheme.textDark,
                                fontWeight: _selectedDeadline == null ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedLight),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Conta Associada (Opcional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoadingAccounts
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withOpacity(0.06)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String?>(
                                value: _selectedBankAccountId,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: AppTheme.textMutedLight),
                                ),
                                style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
                                hint: const Text('Nenhuma conta selecionada', style: TextStyle(color: AppTheme.textMutedLight)),
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMutedLight),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Nenhuma conta (Opcional)', style: TextStyle(color: AppTheme.textMutedLight)),
                                  ),
                                  ..._accounts.map((acc) {
                                    return DropdownMenuItem<String?>(
                                      value: acc.id,
                                      child: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedBankAccountId = val;
                                  });
                                },
                              ),
                            ),
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
                        onPressed: _saveGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Criar Meta',
                              style: TextStyle(
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
          
          if (_isSaving)
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
