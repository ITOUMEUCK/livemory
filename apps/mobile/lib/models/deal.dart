import 'package:json_annotation/json_annotation.dart';

part 'deal.g.dart';

@JsonSerializable()
class Deal {
  final String id;
  final String title;
  final String description;
  final DealCategory category;
  final String provider;
  final String? logoUrl;
  final String? imageUrl;
  final double discountPercentage;
  final String? discountCode;
  final int minGroupSize;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? validUntil;
  final String? termsAndConditions;
  final String? websiteUrl;
  final String? bookingUrl;
  final bool isActive;
  final DateTime createdAt;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.provider,
    this.logoUrl,
    this.imageUrl,
    required this.discountPercentage,
    this.discountCode,
    required this.minGroupSize,
    this.location,
    this.latitude,
    this.longitude,
    this.validUntil,
    this.termsAndConditions,
    this.websiteUrl,
    this.bookingUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);
  Map<String, dynamic> toJson() => _$DealToJson(this);

  bool get isExpired =>
      validUntil != null && validUntil!.isBefore(DateTime.now());
}

enum DealCategory {
  @JsonValue('restaurant')
  restaurant,
  @JsonValue('hotel')
  hotel,
  @JsonValue('activity')
  activity,
  @JsonValue('transport')
  transport,
  @JsonValue('entertainment')
  entertainment,
  @JsonValue('other')
  other,
}
