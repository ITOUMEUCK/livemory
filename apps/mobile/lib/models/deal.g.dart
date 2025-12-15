// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Deal _$DealFromJson(Map<String, dynamic> json) => Deal(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: $enumDecode(_$DealCategoryEnumMap, json['category']),
  provider: json['provider'] as String,
  logoUrl: json['logoUrl'] as String?,
  imageUrl: json['imageUrl'] as String?,
  discountPercentage: (json['discountPercentage'] as num).toDouble(),
  discountCode: json['discountCode'] as String?,
  minGroupSize: (json['minGroupSize'] as num).toInt(),
  location: json['location'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  validUntil: json['validUntil'] == null
      ? null
      : DateTime.parse(json['validUntil'] as String),
  termsAndConditions: json['termsAndConditions'] as String?,
  websiteUrl: json['websiteUrl'] as String?,
  bookingUrl: json['bookingUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DealToJson(Deal instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': _$DealCategoryEnumMap[instance.category]!,
  'provider': instance.provider,
  'logoUrl': instance.logoUrl,
  'imageUrl': instance.imageUrl,
  'discountPercentage': instance.discountPercentage,
  'discountCode': instance.discountCode,
  'minGroupSize': instance.minGroupSize,
  'location': instance.location,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'validUntil': instance.validUntil?.toIso8601String(),
  'termsAndConditions': instance.termsAndConditions,
  'websiteUrl': instance.websiteUrl,
  'bookingUrl': instance.bookingUrl,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$DealCategoryEnumMap = {
  DealCategory.restaurant: 'restaurant',
  DealCategory.hotel: 'hotel',
  DealCategory.activity: 'activity',
  DealCategory.transport: 'transport',
  DealCategory.entertainment: 'entertainment',
  DealCategory.other: 'other',
};
