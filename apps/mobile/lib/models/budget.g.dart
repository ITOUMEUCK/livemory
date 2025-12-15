// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  totalBudget: (json['totalBudget'] as num).toDouble(),
  spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
  expenses:
      (json['expenses'] as List<dynamic>?)
          ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  payments:
      (json['payments'] as List<dynamic>?)
          ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
  'id': instance.id,
  'eventId': instance.eventId,
  'totalBudget': instance.totalBudget,
  'spentAmount': instance.spentAmount,
  'expenses': instance.expenses,
  'payments': instance.payments,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String,
  budgetId: json['budgetId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  paidById: json['paidById'] as String,
  paidByName: json['paidByName'] as String,
  splits:
      (json['splits'] as List<dynamic>?)
          ?.map((e) => Split.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  receiptUrl: json['receiptUrl'] as String?,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'budgetId': instance.budgetId,
  'title': instance.title,
  'description': instance.description,
  'amount': instance.amount,
  'category': instance.category,
  'paidById': instance.paidById,
  'paidByName': instance.paidByName,
  'splits': instance.splits,
  'receiptUrl': instance.receiptUrl,
  'date': instance.date.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

Split _$SplitFromJson(Map<String, dynamic> json) => Split(
  participantId: json['participantId'] as String,
  participantName: json['participantName'] as String,
  amount: (json['amount'] as num).toDouble(),
  isPaid: json['isPaid'] as bool? ?? false,
);

Map<String, dynamic> _$SplitToJson(Split instance) => <String, dynamic>{
  'participantId': instance.participantId,
  'participantName': instance.participantName,
  'amount': instance.amount,
  'isPaid': instance.isPaid,
};

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  budgetId: json['budgetId'] as String,
  fromParticipantId: json['fromParticipantId'] as String,
  fromParticipantName: json['fromParticipantName'] as String,
  toParticipantId: json['toParticipantId'] as String,
  toParticipantName: json['toParticipantName'] as String,
  amount: (json['amount'] as num).toDouble(),
  status:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
      PaymentStatus.pending,
  paymentMethod: json['paymentMethod'] as String?,
  transactionId: json['transactionId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'budgetId': instance.budgetId,
  'fromParticipantId': instance.fromParticipantId,
  'fromParticipantName': instance.fromParticipantName,
  'toParticipantId': instance.toParticipantId,
  'toParticipantName': instance.toParticipantName,
  'amount': instance.amount,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'paymentMethod': instance.paymentMethod,
  'transactionId': instance.transactionId,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.completed: 'completed',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};
