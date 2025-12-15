import 'package:json_annotation/json_annotation.dart';

part 'budget.g.dart';

@JsonSerializable()
class Budget {
  final String id;
  final String eventId;
  final double totalBudget;
  final double spentAmount;
  final List<Expense> expenses;
  final List<Payment> payments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.eventId,
    required this.totalBudget,
    this.spentAmount = 0.0,
    this.expenses = const [],
    this.payments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingBudget => totalBudget - spentAmount;
  double get percentageSpent =>
      totalBudget > 0 ? (spentAmount / totalBudget) * 100 : 0;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}

@JsonSerializable()
class Expense {
  final String id;
  final String budgetId;
  final String title;
  final String description;
  final double amount;
  final String category; // transport, food, accommodation, activity, other
  final String paidById;
  final String paidByName;
  final List<Split> splits;
  final String? receiptUrl;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.budgetId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.paidById,
    required this.paidByName,
    this.splits = const [],
    this.receiptUrl,
    required this.date,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}

@JsonSerializable()
class Split {
  final String participantId;
  final String participantName;
  final double amount;
  final bool isPaid;

  Split({
    required this.participantId,
    required this.participantName,
    required this.amount,
    this.isPaid = false,
  });

  factory Split.fromJson(Map<String, dynamic> json) => _$SplitFromJson(json);
  Map<String, dynamic> toJson() => _$SplitToJson(this);
}

@JsonSerializable()
class Payment {
  final String id;
  final String budgetId;
  final String fromParticipantId;
  final String fromParticipantName;
  final String toParticipantId;
  final String toParticipantName;
  final double amount;
  final PaymentStatus status;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? completedAt;

  Payment({
    required this.id,
    required this.budgetId,
    required this.fromParticipantId,
    required this.fromParticipantName,
    required this.toParticipantId,
    required this.toParticipantName,
    required this.amount,
    this.status = PaymentStatus.pending,
    this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    this.completedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}
