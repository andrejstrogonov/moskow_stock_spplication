// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Portfolio _$PortfolioFromJson(Map<String, dynamic> json) => Portfolio(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$PortfolioTypeEnumMap, json['type']),
      positions: (json['positions'] as List<dynamic>?)
              ?.map((e) => Position.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      lastModified: json['lastModified'] == null
          ? null
          : DateTime.parse(json['lastModified'] as String),
      targetBonds: (json['targetBonds'] as num).toDouble(),
      targetStocks: (json['targetStocks'] as num).toDouble(),
      targetFutures: (json['targetFutures'] as num).toDouble(),
      targetCash: (json['targetCash'] as num).toDouble(),
    );

Map<String, dynamic> _$PortfolioToJson(Portfolio instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$PortfolioTypeEnumMap[instance.type]!,
      'positions': instance.positions,
      'createdDate': instance.createdDate.toIso8601String(),
      'lastModified': instance.lastModified.toIso8601String(),
      'targetBonds': instance.targetBonds,
      'targetStocks': instance.targetStocks,
      'targetFutures': instance.targetFutures,
      'targetCash': instance.targetCash,
    };

const _$PortfolioTypeEnumMap = {
  PortfolioType.conservative: 'conservative',
  PortfolioType.balanced: 'balanced',
  PortfolioType.aggressive: 'aggressive',
  PortfolioType.custom: 'custom',
};
