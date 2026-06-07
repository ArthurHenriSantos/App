import 'dart:convert';
import 'dart:io';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/bank_account/domain/entities/bank_account.dart';
import 'package:app/features/goal/domain/entities/goal.dart';
import 'package:app/features/transaction/domain/entities/transaction.dart';
import 'package:app/models/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  
  String? _accessToken;
  User? _currentUser;

  ApiService._internal();

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    return Platform.isAndroid
        ? 'http://10.0.2.2:8000/api'
        : 'http://localhost:8000/api';
  }

  bool get isAuthenticated => _accessToken != null;
  User? get currentUser => _currentUser;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  

  
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _accessToken = data['token'] as String;
      _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
      return _currentUser!;
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['detail'] ?? 'Falha na autenticação');
    }
  }

  
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String gender,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'gender': gender,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _accessToken = data['token'] as String;
      _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
      return _currentUser!;
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['detail'] ?? 'Falha no cadastro');
    }
  }

  
  void logout() {
    _accessToken = null;
    _currentUser = null;
  }

  

  Future<User> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao carregar perfil do usuário');
    }
  }

  

  Future<BankAccount> getPrimaryAccount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/accounts/primary'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return BankAccount.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao carregar conta principal');
    }
  }

  Future<List<BankAccount>> getAccounts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/accounts'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((item) => BankAccount.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Falha ao carregar contas bancárias');
    }
  }

  Future<BankAccount> createAccount({
    required String name,
    required double balance,
    required BankAccountType type,
    required Currency currency,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'balance': balance,
        'type': type.name,
        'currency': currency.name,
      }),
    );

    if (response.statusCode == 201) {
      return BankAccount.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao criar conta bancária');
    }
  }

  Future<void> deleteAccount(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/accounts/$id'),
      headers: _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao excluir conta bancária');
    }
  }

  Future<BankAccount> updateAccount({
    required String id,
    String? name,
    BankAccountType? type,
    Currency? currency,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (type != null) body['type'] = type.name;
    if (currency != null) body['currency'] = currency.name;

    final response = await http.patch(
      Uri.parse('$baseUrl/accounts/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return BankAccount.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao atualizar conta bancária');
    }
  }

  

  Future<List<Transaction>> getTransactions(
      {String? search, TransactionType? type, String? bankAccountId}) async {
    final params = <String>[];
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search)}');
    }
    if (type != null) {
      params.add('type=${type.name}');
    }
    if (bankAccountId != null && bankAccountId.isNotEmpty) {
      params.add('bankAccountId=$bankAccountId');
    }
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';

    final response = await http.get(
      Uri.parse('$baseUrl/transactions$query'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Falha ao carregar transações');
    }
  }

  Future<Transaction> getTransactionById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Transação não encontrada');
    }
  }

  Future<Transaction> createTransaction({
    required String bankAccountId,
    required TransactionType type,
    required double amount,
    required String description,
    String? destinationBankAccountId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers,
      body: jsonEncode({
        'bankAccountId': bankAccountId,
        'type': type.name,
        'amount': amount,
        'description': description,
        if (destinationBankAccountId != null) 'destinationBankAccountId': destinationBankAccountId,
      }),
    );

    if (response.statusCode == 201) {
      return Transaction.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao criar transação');
    }
  }

  

  Future<List<Goal>> getGoals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/goals'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((item) => Goal.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Falha ao carregar metas');
    }
  }

  Future<Goal> getGoalById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/goals/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Goal.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Meta não encontrada');
    }
  }

  Future<Goal> createGoal({
    required String name,
    required double targetAmount,
    required DateTime deadlineDate,
    String? bankAccountId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'targetAmount': targetAmount,
        'deadlineDate': deadlineDate.toIso8601String(),
        if (bankAccountId != null) 'bankAccountId': bankAccountId,
      }),
    );

    if (response.statusCode == 201) {
      return Goal.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao criar meta');
    }
  }

  Future<Goal> updateGoal({
    required String id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadlineDate,
    GoalStatus? status,
    String? bankAccountId,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (targetAmount != null) body['targetAmount'] = targetAmount;
    if (currentAmount != null) body['currentAmount'] = currentAmount;
    if (deadlineDate != null) body['deadlineDate'] = deadlineDate.toIso8601String();
    if (status != null) body['status'] = status.name;
    if (bankAccountId != null) body['bankAccountId'] = bankAccountId;

    final response = await http.patch(
      Uri.parse('$baseUrl/goals/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Goal.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao atualizar meta');
    }
  }

  Future<void> deleteGoal(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/goals/$id'),
      headers: _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao excluir meta');
    }
  }
}
