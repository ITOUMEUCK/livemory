import 'package:equatable/equatable.dart';

/// Types de répartition du budget
enum SplitType {
  equal,
  percentage,
  custom;

  String get displayName {
    switch (this) {
      case SplitType.equal:
        return 'Équitable';
      case SplitType.percentage:
        return 'Pourcentage';
      case SplitType.custom:
        return 'Personnalisé';
    }
  }

  String get icon {
    switch (this) {
      case SplitType.equal:
        return '⚖️';
      case SplitType.percentage:
        return '📊';
      case SplitType.custom:
        return '✏️';
    }
  }
}

/// Catégories de dépenses
enum ExpenseCategory {
  transport,
  accommodation,
  food,
  activities,
  shopping,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.accommodation:
        return 'Hébergement';
      case ExpenseCategory.food:
        return 'Nourriture';
      case ExpenseCategory.activities:
        return 'Activités';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Autre';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.transport:
        return '🚗';
      case ExpenseCategory.accommodation:
        return '🏠';
      case ExpenseCategory.food:
        return '🍽️';
      case ExpenseCategory.activities:
        return '🎯';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.other:
        return '📦';
    }
  }
}

/// Part d'un participant dans une dépense
class ExpenseShare extends Equatable {
  final String userId;
  final double amount;
  final bool isPaid;

  const ExpenseShare({
    required this.userId,
    required this.amount,
    this.isPaid = false,
  });

  ExpenseShare copyWith({String? userId, double? amount, bool? isPaid}) {
    return ExpenseShare(
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'amount': amount, 'isPaid': isPaid};
  }

  factory ExpenseShare.fromJson(Map<String, dynamic> json) {
    return ExpenseShare(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      isPaid: json['isPaid'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [userId, amount, isPaid];
}

/// Dépense individuelle dans un budget
class Expense extends Equatable {
  final String id;
  final String budgetId;
  final String title;
  final String? description;
  final double amount;
  final ExpenseCategory category;
  final String paidBy;
  final List<ExpenseShare> shares;
  final DateTime date;
  final String? receiptUrl;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.budgetId,
    required this.title,
    this.description,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.shares,
    required this.date,
    this.receiptUrl,
    required this.createdAt,
  });

  /// Montant total payé
  double get totalPaid {
    return shares.where((s) => s.isPaid).fold(0.0, (sum, s) => sum + s.amount);
  }

  /// Montant restant à payer
  double get remaining => amount - totalPaid;

  /// Est-ce que la dépense est complètement payée
  bool get isFullyPaid => remaining <= 0.01; // Tolérance pour erreurs d'arrondi

  /// Obtenir la part d'un utilisateur
  double getUserShare(String userId) {
    return shares
        .where((s) => s.userId == userId)
        .fold(0.0, (sum, s) => sum + s.amount);
  }

  /// Est-ce qu'un utilisateur a payé sa part
  bool hasUserPaid(String userId) {
    final userShares = shares.where((s) => s.userId == userId);
    if (userShares.isEmpty) return true;
    return userShares.every((s) => s.isPaid);
  }

  Expense copyWith({
    String? id,
    String? budgetId,
    String? title,
    String? description,
    double? amount,
    ExpenseCategory? category,
    String? paidBy,
    List<ExpenseShare>? shares,
    DateTime? date,
    String? receiptUrl,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paidBy: paidBy ?? this.paidBy,
      shares: shares ?? this.shares,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'budgetId': budgetId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category.name,
      'paidBy': paidBy,
      'shares': shares.map((s) => s.toJson()).toList(),
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      budgetId: json['budgetId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      paidBy: json['paidBy'] as String,
      shares: (json['shares'] as List)
          .map((s) => ExpenseShare.fromJson(s as Map<String, dynamic>))
          .toList(),
      date: DateTime.parse(json['date'] as String),
      receiptUrl: json['receiptUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    budgetId,
    title,
    description,
    amount,
    category,
    paidBy,
    shares,
    date,
    receiptUrl,
    createdAt,
  ];
}

/// Budget d'un événement
class Budget extends Equatable {
  final String id;
  final String eventId;
  final String name;
  final String? description;
  final double totalAmount;
  final SplitType splitType;
  final List<String> participantIds;
  final List<Expense> expenses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.eventId,
    required this.name,
    this.description,
    required this.totalAmount,
    required this.splitType,
    required this.participantIds,
    required this.expenses,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Montant total dépensé
  double get totalSpent {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Montant restant
  double get remaining => totalAmount - totalSpent;

  /// Pourcentage dépensé
  double get percentageSpent {
    if (totalAmount == 0) return 0;
    return (totalSpent / totalAmount * 100).clamp(0, 100);
  }

  /// Est-ce que le budget est dépassé
  bool get isOverBudget => totalSpent > totalAmount;

  /// Dépenses par catégorie
  Map<ExpenseCategory, double> get expensesByCategory {
    final map = <ExpenseCategory, double>{};
    for (var expense in expenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    return map;
  }

  /// Calculer ce que chaque participant doit payer
  Map<String, double> calculateShares() {
    final shares = <String, double>{};

    switch (splitType) {
      case SplitType.equal:
        final perPerson = totalSpent / participantIds.length;
        for (var userId in participantIds) {
          shares[userId] = perPerson;
        }
        break;

      case SplitType.percentage:
      case SplitType.custom:
        // Pour percentage et custom, on utilise les shares des dépenses
        for (var expense in expenses) {
          for (var share in expense.shares) {
            shares[share.userId] = (shares[share.userId] ?? 0) + share.amount;
          }
        }
        break;
    }

    return shares;
  }

  /// Calculer combien chaque participant a payé
  Map<String, double> calculatePaidAmounts() {
    final paid = <String, double>{};
    for (var expense in expenses) {
      paid[expense.paidBy] = (paid[expense.paidBy] ?? 0) + expense.amount;
    }
    return paid;
  }

  /// Calculer les remboursements nécessaires
  List<Settlement> calculateSettlements() {
    final shares = calculateShares();
    final paid = calculatePaidAmounts();
    final balances = <String, double>{};

    // Calculer le solde de chaque participant (ce qu'il a payé - ce qu'il doit)
    for (var userId in participantIds) {
      final userPaid = paid[userId] ?? 0;
      final userOwes = shares[userId] ?? 0;
      balances[userId] = userPaid - userOwes;
    }

    // Créer les règlements
    final settlements = <Settlement>[];
    final debtors = balances.entries
        .where((e) => e.value < -0.01)
        .toList(); // Qui doit
    final creditors = balances.entries
        .where((e) => e.value > 0.01)
        .toList(); // Qui reçoit

    for (var debtor in debtors) {
      var remaining = -debtor.value;
      for (var creditor in creditors) {
        if (remaining <= 0.01) break;
        if (creditor.value <= 0.01) continue;

        final amount = remaining < creditor.value ? remaining : creditor.value;
        settlements.add(
          Settlement(from: debtor.key, to: creditor.key, amount: amount),
        );

        remaining -= amount;
        creditor = MapEntry(creditor.key, creditor.value - amount);
      }
    }

    return settlements;
  }

  /// Obtenir les dépenses d'un utilisateur
  List<Expense> getUserExpenses(String userId) {
    return expenses.where((e) => e.paidBy == userId).toList();
  }

  /// Obtenir le solde d'un utilisateur (positif = à recevoir, négatif = à payer)
  double getUserBalance(String userId) {
    final shares = calculateShares();
    final paid = calculatePaidAmounts();
    return (paid[userId] ?? 0) - (shares[userId] ?? 0);
  }

  Budget copyWith({
    String? id,
    String? eventId,
    String? name,
    String? description,
    double? totalAmount,
    SplitType? splitType,
    List<String>? participantIds,
    List<Expense>? expenses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      splitType: splitType ?? this.splitType,
      participantIds: participantIds ?? this.participantIds,
      expenses: expenses ?? this.expenses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventId,
    name,
    description,
    totalAmount,
    splitType,
    participantIds,
    expenses,
    createdAt,
    updatedAt,
  ];
}

/// Règlement entre deux utilisateurs
class Settlement extends Equatable {
  final String from;
  final String to;
  final double amount;

  const Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });

  @override
  List<Object?> get props => [from, to, amount];
}
