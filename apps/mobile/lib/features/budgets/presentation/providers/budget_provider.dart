import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/services/firestore_service.dart';
import 'package:mobile/features/budgets/domain/entities/budget.dart';

/// Provider pour la gestion des budgets
class BudgetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupérer tous les budgets
  Future<void> fetchBudgets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firestoreService.readAll('budgets');
      _budgets = querySnapshot.docs
          .map((doc) => _budgetFromFirestore(doc))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des budgets: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Créer un nouveau budget
  Future<Budget?> createBudget({
    required String eventId,
    required String name,
    String? description,
    required double totalAmount,
    required SplitType splitType,
    required List<String> participantIds,
  }) async {
    try {
      final budgetData = {
        'eventId': eventId,
        'name': name,
        'description': description,
        'totalAmount': totalAmount,
        'splitType': _splitTypeToString(splitType),
        'participantIds': participantIds,
        'expenses': [], // Array vide au départ
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final budgetId = await _firestoreService.create('budgets', budgetData);

      // Récupérer le document créé
      final docSnapshot = await _firestoreService.read('budgets', budgetId);
      final newBudget = _budgetFromFirestore(docSnapshot);

      _budgets.add(newBudget);
      notifyListeners();

      return newBudget;
    } catch (e) {
      _errorMessage = 'Erreur lors de la création du budget: $e';
      notifyListeners();
      debugPrint(_errorMessage);
      return null;
    }
  }

  /// Ajouter une dépense à un budget
  Future<Expense?> addExpense({
    required String budgetId,
    required String title,
    String? description,
    required double amount,
    required ExpenseCategory category,
    required String paidBy,
    required List<ExpenseShare> shares,
    DateTime? date,
    String? receiptUrl,
  }) async {
    try {
      final budgetIndex = _budgets.indexWhere((b) => b.id == budgetId);
      if (budgetIndex == -1) return null;

      final budget = _budgets[budgetIndex];

      // Créer la nouvelle dépense
      final expense = Expense(
        id: 'expense_${DateTime.now().millisecondsSinceEpoch}',
        budgetId: budgetId,
        title: title,
        description: description,
        amount: amount,
        category: category,
        paidBy: paidBy,
        shares: shares,
        date: date ?? DateTime.now(),
        receiptUrl: receiptUrl,
        createdAt: DateTime.now(),
      );

      final updatedExpenses = List<Expense>.from(budget.expenses)..add(expense);

      // Mettre à jour dans Firestore
      await _firestoreService.update('budgets', budgetId, {
        'expenses': updatedExpenses.map((e) => _expenseToMap(e)).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour localement
      _budgets[budgetIndex] = budget.copyWith(
        expenses: updatedExpenses,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      return expense;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout de la dépense: $e';
      notifyListeners();
      debugPrint(_errorMessage);
      return null;
    }
  }

  /// Marquer une part de dépense comme payée
  Future<void> markShareAsPaid({
    required String budgetId,
    required String expenseId,
    required String userId,
  }) async {
    try {
      final budgetIndex = _budgets.indexWhere((b) => b.id == budgetId);
      if (budgetIndex == -1) return;

      final budget = _budgets[budgetIndex];
      final expenseIndex = budget.expenses.indexWhere((e) => e.id == expenseId);
      if (expenseIndex == -1) return;

      final expense = budget.expenses[expenseIndex];
      final updatedShares = expense.shares.map((share) {
        if (share.userId == userId) {
          return share.copyWith(isPaid: true);
        }
        return share;
      }).toList();

      final updatedExpense = expense.copyWith(shares: updatedShares);
      final updatedExpenses = List<Expense>.from(budget.expenses);
      updatedExpenses[expenseIndex] = updatedExpense;

      // Mettre à jour dans Firestore
      await _firestoreService.update('budgets', budgetId, {
        'expenses': updatedExpenses.map((e) => _expenseToMap(e)).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour localement
      _budgets[budgetIndex] = budget.copyWith(
        expenses: updatedExpenses,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du paiement: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Supprimer une dépense
  Future<void> deleteExpense({
    required String budgetId,
    required String expenseId,
  }) async {
    try {
      final budgetIndex = _budgets.indexWhere((b) => b.id == budgetId);
      if (budgetIndex == -1) return;

      final budget = _budgets[budgetIndex];
      final updatedExpenses = budget.expenses
          .where((e) => e.id != expenseId)
          .toList();

      // Mettre à jour dans Firestore
      await _firestoreService.update('budgets', budgetId, {
        'expenses': updatedExpenses.map((e) => _expenseToMap(e)).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour localement
      _budgets[budgetIndex] = budget.copyWith(
        expenses: updatedExpenses,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de la dépense: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Supprimer un budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _firestoreService.delete('budgets', budgetId);
      _budgets.removeWhere((b) => b.id == budgetId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du budget: $e';
      notifyListeners();
      debugPrint(_errorMessage);
    }
  }

  /// Obtenir les budgets d'un événement
  List<Budget> getBudgetsByEvent(String eventId) {
    return _budgets.where((b) => b.eventId == eventId).toList();
  }

  /// Obtenir un budget par son ID
  Budget? getBudgetById(String budgetId) {
    try {
      return _budgets.firstWhere((b) => b.id == budgetId);
    } catch (e) {
      return null;
    }
  }

  /// Calculer les statistiques globales
  Map<String, dynamic> getGlobalStats() {
    final totalBudgets = _budgets.length;
    final totalSpent = _budgets.fold(0.0, (sum, b) => sum + b.totalSpent);
    final totalAmount = _budgets.fold(0.0, (sum, b) => sum + b.totalAmount);
    final overBudgetCount = _budgets.where((b) => b.isOverBudget).length;

    return {
      'totalBudgets': totalBudgets,
      'totalSpent': totalSpent,
      'totalAmount': totalAmount,
      'overBudgetCount': overBudgetCount,
      'averageSpent': totalBudgets > 0 ? totalSpent / totalBudgets : 0.0,
    };
  }

  // Méthodes de conversion Firestore

  Budget _budgetFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final expensesData = data['expenses'] as List<dynamic>? ?? [];
    final expenses = expensesData
        .map((expData) => _expenseFromMap(expData as Map<String, dynamic>))
        .toList();

    return Budget(
      id: doc.id,
      eventId: data['eventId'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      totalAmount: (data['totalAmount'] as num).toDouble(),
      splitType: _splitTypeFromString(data['splitType'] as String),
      participantIds: List<String>.from(data['participantIds'] as List? ?? []),
      expenses: expenses,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _expenseToMap(Expense expense) {
    return {
      'id': expense.id,
      'budgetId': expense.budgetId,
      'title': expense.title,
      'description': expense.description,
      'amount': expense.amount,
      'category': _categoryToString(expense.category),
      'paidBy': expense.paidBy,
      'shares': expense.shares.map((s) => _shareToMap(s)).toList(),
      'date': Timestamp.fromDate(expense.date),
      'receiptUrl': expense.receiptUrl,
      'createdAt': Timestamp.fromDate(expense.createdAt),
    };
  }

  Expense _expenseFromMap(Map<String, dynamic> map) {
    final sharesData = map['shares'] as List<dynamic>? ?? [];
    final shares = sharesData
        .map((shareData) => _shareFromMap(shareData as Map<String, dynamic>))
        .toList();

    return Expense(
      id: map['id'] as String,
      budgetId: map['budgetId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      amount: (map['amount'] as num).toDouble(),
      category: _categoryFromString(map['category'] as String),
      paidBy: map['paidBy'] as String,
      shares: shares,
      date: (map['date'] as Timestamp).toDate(),
      receiptUrl: map['receiptUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _shareToMap(ExpenseShare share) {
    return {
      'userId': share.userId,
      'amount': share.amount,
      'isPaid': share.isPaid,
    };
  }

  ExpenseShare _shareFromMap(Map<String, dynamic> map) {
    return ExpenseShare(
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      isPaid: map['isPaid'] as bool? ?? false,
    );
  }

  String _splitTypeToString(SplitType type) {
    return type.toString().split('.').last;
  }

  SplitType _splitTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'equal':
        return SplitType.equal;
      case 'percentage':
        return SplitType.percentage;
      case 'custom':
        return SplitType.custom;
      default:
        return SplitType.equal;
    }
  }

  String _categoryToString(ExpenseCategory category) {
    return category.toString().split('.').last;
  }

  ExpenseCategory _categoryFromString(String categoryStr) {
    switch (categoryStr) {
      case 'food':
        return ExpenseCategory.food;
      case 'transport':
        return ExpenseCategory.transport;
      case 'accommodation':
        return ExpenseCategory.accommodation;
      case 'activities':
        return ExpenseCategory.activities;
      case 'shopping':
        return ExpenseCategory.shopping;
      case 'other':
      default:
        return ExpenseCategory.other;
    }
  }
}
