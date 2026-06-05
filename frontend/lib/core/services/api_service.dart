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
  ApiService._internal();

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    // Para emulador Android, o localhost da máquina hospedeira é acessado em 10.0.2.2.
    // Para outros (iOS, desktop), usa-se localhost.
    return Platform.isAndroid ? 'http://10.0.2.2:8000/api' : 'http://localhost:8000/api';
  }

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth: Login
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String;
      setToken(token);
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      final errorData = jsonDecode(response.body);
      final detail = errorData['detail'] ?? 'Falha na autenticação';
      throw Exception(detail);
    }
  }

  // User: Me
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

  // Account: Get primary account
  Future<BankAccount> getPrimaryAccount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/accounts/primary'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return BankAccount.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao carregar conta principal');
    }
  }

  // Transactions: Get all (optionally filter by search and type)
  Future<List<Transaction>> getTransactions({String? search, TransactionType? type}) async {
    var query = '';
    final params = <String>[];
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search)}');
    }
    if (type != null) {
      params.add('type=${type.name}');
    }
    if (params.isNotEmpty) {
      query = '?${params.join('&')}';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/transactions$query'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body) as List;
      return list.map((item) => Transaction.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Falha ao carregar transações');
    }
  }

  // Transaction: Get by ID
  Future<Transaction> getTransactionById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Transação não encontrada');
    }
  }

  // Transaction: Create
  Future<Transaction> createTransaction({
    required String bankAccountId,
    required TransactionType type,
    required double amount,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers,
      body: jsonEncode({
        'bankAccountId': bankAccountId,
        'type': type.name,
        'amount': amount,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      return Transaction.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao criar transação');
    }
  }

  // Goals: Get all
  Future<List<Goal>> getGoals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/goals'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body) as List;
      return list.map((item) => Goal.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Falha ao carregar metas');
    }
  }

  // Goal: Create
  Future<Goal> createGoal({
    required String name,
    required double targetAmount,
    required DateTime deadlineDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'targetAmount': targetAmount,
        'deadlineDate': deadlineDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return Goal.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao criar meta');
    }
  }

  // Goal: Update progress
  Future<Goal> updateGoal({
    required String id,
    double? currentAmount,
    GoalStatus? status,
  }) async {
    final body = <String, dynamic>{};
    if (currentAmount != null) body['currentAmount'] = currentAmount;
    if (status != null) body['status'] = status.name;

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
}
