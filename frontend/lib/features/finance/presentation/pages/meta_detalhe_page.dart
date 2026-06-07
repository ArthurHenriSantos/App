import 'dart:ui';
import 'package:app/core/services/api_service.dart';
import 'package:app/features/bank_account/domain/entities/bank_account.dart';
import 'package:app/features/goal/domain/entities/goal.dart';
import 'package:app/models/enums.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MetaDetalhePage extends StatefulWidget {
  final String goalId;
  const MetaDetalhePage({super.key, required this.goalId});

  @override
  State<MetaDetalhePage> createState() => _MetaDetalhePageState();
}

class _MetaDetalhePageState extends State<MetaDetalhePage> {
  Goal? _goal;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  DateTime? _selectedDeadline;
  String? _selectedBankAccountId;
  GoalStatus? _selectedStatus;

  List<BankAccount> _accounts = [];
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _loadGoalDetails();
    _loadAccounts();
  }

  Future<void> _loadGoalDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final goal = await ApiService().getGoalById(widget.goalId);
      if (mounted) {
        setState(() {
          _goal = goal;
          _isLoading = false;
          _initControllers(goal);
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

  void _initControllers(Goal goal) {
    _nameController = TextEditingController(text: goal.name);
    _targetAmountController = TextEditingController(
        text: goal.targetAmount.toStringAsFixed(2).replaceAll('.', ','));
    _currentAmountController = TextEditingController(
        text: goal.currentAmount.toStringAsFixed(2).replaceAll('.', ','));
    _selectedDeadline = goal.deadlineDate;
    _selectedBankAccountId = goal.bankAccountId;
    _selectedStatus = goal.status;
  }

  @override
  void dispose() {
    if (_goal != null) {
      _nameController.dispose();
      _targetAmountController.dispose();
      _currentAmountController.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDeadlineDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 365)), 
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

  Future<void> _saveGoalEdits() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDeadline == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final targetAmount = double.parse(_targetAmountController.text.replaceAll(',', '.'));
      final currentAmount = double.parse(_currentAmountController.text.replaceAll(',', '.'));
      
      final updatedGoal = await ApiService().updateGoal(
        id: widget.goalId,
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadlineDate: _selectedDeadline,
        status: _selectedStatus,
        bankAccountId: _selectedBankAccountId,
      );

      if (mounted) {
        setState(() {
          _goal = updatedGoal;
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Meta atualizada com sucesso!',
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
                    'Erro ao salvar alterações: ${e.toString().replaceAll('Exception: ', '')}',
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

  Future<void> _deleteGoal() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Meta'),
        content: const Text(
            'Tem certeza de que deseja excluir permanentemente esta meta? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMutedLight)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir',
                style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ApiService().deleteGoal(widget.goalId);
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.delete_outline_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Meta excluída com sucesso!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppTheme.danger,
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
            content: Text('Erro ao excluir meta: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  String _getStatusLabel(GoalStatus status) {
    switch (status) {
      case GoalStatus.inProgress:
        return 'Em Progresso';
      case GoalStatus.completed:
        return 'Concluída';
      case GoalStatus.cancelled:
        return 'Cancelada';
    }
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.inProgress:
        return AppTheme.primary;
      case GoalStatus.completed:
        return AppTheme.accent;
      case GoalStatus.cancelled:
        return AppTheme.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes da Meta'),
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

    final goal = _goal;

    if (goal == null || _errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes da Meta'),
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
                _errorMessage ?? 'Meta não encontrada.',
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

    final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    final percent = (progress * 100).toStringAsFixed(0);
    final deadlineStr =
        '${goal.deadlineDate.day.toString().padLeft(2, '0')}/${goal.deadlineDate.month.toString().padLeft(2, '0')}/${goal.deadlineDate.year}';
    final dateEditStr = _selectedDeadline == null
        ? 'Selecionar data'
        : '${_selectedDeadline!.day.toString().padLeft(2, '0')}/${_selectedDeadline!.month.toString().padLeft(2, '0')}/${_selectedDeadline!.year}';

    
    final associatedAccount = _accounts.firstWhere(
      (acc) => acc.id == goal.bankAccountId,
      orElse: () => BankAccount(
        id: '',
        userId: '',
        name: 'Nenhuma conta',
        balance: 0,
        type: BankAccountType.checking,
        currency: Currency.brl,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Meta' : 'Detalhes da Meta',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(true),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _isEditing
                  ? _buildEditForm(dateEditStr)
                  : _buildDetailsView(goal, progress, percent, deadlineStr, associatedAccount),
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

  Widget _buildDetailsView(
      Goal goal, double progress, String percent, String deadlineStr, BankAccount associatedAccount) {
    final statusColor = _getStatusColor(goal.status);
    final statusLabel = _getStatusLabel(goal.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
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
              
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.flag_rounded, color: statusColor, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                goal.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 24),
              
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: statusColor.withOpacity(0.12),
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_fmt(goal.currentAmount)} poupados',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 24),
              
              _buildDetailRow(
                label: 'Status da Meta',
                value: statusLabel,
                valueColor: statusColor,
                isStatus: true,
              ),
              _buildDetailRow(
                label: 'Valor Alvo Total',
                value: _fmt(goal.targetAmount),
              ),
              _buildDetailRow(
                label: 'Prazo Limite',
                value: deadlineStr,
              ),
              _buildDetailRow(
                label: 'Conta Associada',
                value: goal.bankAccountId != null ? associatedAccount.name : 'Nenhuma conta',
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        
        OutlinedButton(
          onPressed: () => context.pop(true),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: Colors.black.withOpacity(0.08)),
          ),
          child: const Text(
            'Voltar às Metas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(String dateEditStr) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
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
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: AppTheme.textDark),
            decoration: InputDecoration(
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
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Insira o nome da meta';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valor Alvo (R\$)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _targetAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppTheme.textDark),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Obrigatório';
                        final cleaned = value.replaceAll(',', '.');
                        final val = double.tryParse(cleaned);
                        if (val == null || val <= 0) return 'Inválido';
                        return null;
                      },
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
                      'Valor Guardado (R\$)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppTheme.textDark),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Obrigatório';
                        final cleaned = value.replaceAll(',', '.');
                        final val = double.tryParse(cleaned);
                        if (val == null || val < 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
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
                    dateEditStr,
                    style: const TextStyle(
                        fontSize: 16, color: AppTheme.textDark, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedLight),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
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
                      value: _selectedBankAccountId,
                      decoration: const InputDecoration(border: InputBorder.none),
                      style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Nenhuma conta (Opcional)',
                              style: TextStyle(color: AppTheme.textMutedLight)),
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
          const SizedBox(height: 20),
          
          const Text(
            'Status da Meta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<GoalStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
                items: GoalStatus.values.map((status) {
                  return DropdownMenuItem<GoalStatus>(
                    value: status,
                    child: Text(_getStatusLabel(status),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    if (val != null) _selectedStatus = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _initControllers(_goal!);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: Colors.black.withOpacity(0.08)),
                  ),
                  child: const Text('Cancelar',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.24),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveGoalEdits,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Salvar',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          TextButton.icon(
            onPressed: _deleteGoal,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: AppTheme.danger,
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Excluir Meta', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isStatus = false,
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
                color: valueColor?.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppTheme.textDark,
              ),
            ),
        ],
      ),
    );
  }
}
