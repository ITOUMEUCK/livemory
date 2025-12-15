import 'package:flutter/material.dart';
import '../../domain/entities/budget.dart';

/// Provider pour la gestion des budgets
class BudgetProvider with ChangeNotifier {
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
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _budgets = _generateMockBudgets();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
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
      await Future.delayed(const Duration(milliseconds: 500));

      final budget = Budget(
        id: 'budget_${_budgets.length + 1}',
        eventId: eventId,
        name: name,
        description: description,
        totalAmount: totalAmount,
        splitType: splitType,
        participantIds: participantIds,
        expenses: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _budgets.add(budget);
      notifyListeners();

      return budget;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
      await Future.delayed(const Duration(milliseconds: 500));

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

      final budgetIndex = _budgets.indexWhere((b) => b.id == budgetId);
      if (budgetIndex != -1) {
        final budget = _budgets[budgetIndex];
        final updatedExpenses = List<Expense>.from(budget.expenses)
          ..add(expense);
        _budgets[budgetIndex] = budget.copyWith(
          expenses: updatedExpenses,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return expense;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
      await Future.delayed(const Duration(milliseconds: 300));

      final budgetIndex = _budgets.indexWhere((b) => b.id == budgetId);
      if (budgetIndex != -1) {
        final budget = _budgets[budgetIndex];
        final expenseIndex = budget.expenses.indexWhere(
          (e) => e.id == expenseId,
        );

        if (expenseIndex != -1) {
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

          _budgets[budgetIndex] = budget.copyWith(
            expenses: updatedExpenses,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Supprimer une dépense
  Future<void> deleteExpense({
    required String budgetId,
    required String expenseId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final budgetIndex = _budgets.indexWhere((b) => b.id == budgetId);
      if (budgetIndex != -1) {
        final budget = _budgets[budgetIndex];
        final updatedExpenses = budget.expenses
            .where((e) => e.id != expenseId)
            .toList();

        _budgets[budgetIndex] = budget.copyWith(
          expenses: updatedExpenses,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Supprimer un budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _budgets.removeWhere((b) => b.id == budgetId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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

  /// Générer des données de test
  List<Budget> _generateMockBudgets() {
    final now = DateTime.now();

    // Budget 1: Week-end ski (avec dépenses)
    final budget1 = Budget(
      id: 'budget_1',
      eventId: 'event_1',
      name: 'Budget Week-end Ski',
      description: 'Budget pour le week-end du 20-21 décembre',
      totalAmount: 2500.0,
      splitType: SplitType.equal,
      participantIds: ['user_1', 'user_2', 'user_3', 'user_4'],
      expenses: [
        Expense(
          id: 'exp_1',
          budgetId: 'budget_1',
          title: 'Location chalet',
          description: 'Chalet 4 personnes pour 2 nuits',
          amount: 800.0,
          category: ExpenseCategory.accommodation,
          paidBy: 'user_1',
          shares: [
            const ExpenseShare(userId: 'user_1', amount: 200.0, isPaid: true),
            const ExpenseShare(userId: 'user_2', amount: 200.0, isPaid: true),
            const ExpenseShare(userId: 'user_3', amount: 200.0, isPaid: false),
            const ExpenseShare(userId: 'user_4', amount: 200.0, isPaid: false),
          ],
          date: now.subtract(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        Expense(
          id: 'exp_2',
          budgetId: 'budget_1',
          title: 'Forfaits ski',
          description: '4 forfaits journée',
          amount: 240.0,
          category: ExpenseCategory.activities,
          paidBy: 'user_2',
          shares: [
            const ExpenseShare(userId: 'user_1', amount: 60.0, isPaid: true),
            const ExpenseShare(userId: 'user_2', amount: 60.0, isPaid: true),
            const ExpenseShare(userId: 'user_3', amount: 60.0, isPaid: true),
            const ExpenseShare(userId: 'user_4', amount: 60.0, isPaid: false),
          ],
          date: now.subtract(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        Expense(
          id: 'exp_3',
          budgetId: 'budget_1',
          title: 'Courses alimentaires',
          description: 'Supermarché pour le week-end',
          amount: 150.0,
          category: ExpenseCategory.food,
          paidBy: 'user_3',
          shares: [
            const ExpenseShare(userId: 'user_1', amount: 37.5, isPaid: false),
            const ExpenseShare(userId: 'user_2', amount: 37.5, isPaid: false),
            const ExpenseShare(userId: 'user_3', amount: 37.5, isPaid: true),
            const ExpenseShare(userId: 'user_4', amount: 37.5, isPaid: false),
          ],
          date: now,
          createdAt: now,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now,
    );

    // Budget 2: Soirée jeux (peu de dépenses)
    final budget2 = Budget(
      id: 'budget_2',
      eventId: 'event_2',
      name: 'Budget Soirée Jeux',
      description: 'Pizza et boissons',
      totalAmount: 150.0,
      splitType: SplitType.equal,
      participantIds: ['user_1', 'user_2', 'user_3'],
      expenses: [
        Expense(
          id: 'exp_4',
          budgetId: 'budget_2',
          title: 'Pizzas',
          description: '3 pizzas familiales',
          amount: 45.0,
          category: ExpenseCategory.food,
          paidBy: 'user_1',
          shares: [
            const ExpenseShare(userId: 'user_1', amount: 15.0, isPaid: true),
            const ExpenseShare(userId: 'user_2', amount: 15.0, isPaid: true),
            const ExpenseShare(userId: 'user_3', amount: 15.0, isPaid: true),
          ],
          date: now.subtract(const Duration(hours: 3)),
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        Expense(
          id: 'exp_5',
          budgetId: 'budget_2',
          title: 'Boissons',
          description: 'Sodas et bières',
          amount: 25.0,
          category: ExpenseCategory.food,
          paidBy: 'user_2',
          shares: [
            const ExpenseShare(userId: 'user_1', amount: 8.33, isPaid: true),
            const ExpenseShare(userId: 'user_2', amount: 8.33, isPaid: true),
            const ExpenseShare(userId: 'user_3', amount: 8.34, isPaid: false),
          ],
          date: now.subtract(const Duration(hours: 2)),
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ],
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    );

    // Budget 3: Voyage été (budget vide pour l'instant)
    final budget3 = Budget(
      id: 'budget_3',
      eventId: 'event_3',
      name: 'Budget Voyage Été',
      description: 'Voyage en Italie - 7 jours',
      totalAmount: 5000.0,
      splitType: SplitType.percentage,
      participantIds: ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'],
      expenses: [],
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 30)),
    );

    return [budget1, budget2, budget3];
  }
}
