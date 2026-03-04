// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instrument.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Instrument _$InstrumentFromJson(Map<String, dynamic> json) => Instrument(
      id: json['id'] as String,
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$InstrumentTypeEnumMap, json['type']),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$InstrumentToJson(Instrument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticker': instance.ticker,
      'name': instance.name,
      'type': _$InstrumentTypeEnumMap[instance.type]!,
      'currentPrice': instance.currentPrice,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
    };

const _$InstrumentTypeEnumMap = {
  InstrumentType.bond: 'bond',
  InstrumentType.stock: 'stock',
  InstrumentType.futures: 'futures',
};

Bond _$BondFromJson(Map<String, dynamic> json) => Bond(
      id: json['id'] as String,
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      faceValue: (json['faceValue'] as num).toDouble(),
      couponRate: (json['couponRate'] as num).toDouble(),
      couponFrequency: (json['couponFrequency'] as num).toInt(),
      maturityDate: DateTime.parse(json['maturityDate'] as String),
      accrualInterest: (json['accrualInterest'] as num).toDouble(),
      isOFZ: json['isOFZ'] as bool,
      rating: (json['rating'] as num?)?.toDouble(),
      issuer: json['issuer'] as String?,
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$BondToJson(Bond instance) => <String, dynamic>{
      'id': instance.id,
      'ticker': instance.ticker,
      'name': instance.name,
      'currentPrice': instance.currentPrice,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'faceValue': instance.faceValue,
      'couponRate': instance.couponRate,
      'couponFrequency': instance.couponFrequency,
      'maturityDate': instance.maturityDate.toIso8601String(),
      'accrualInterest': instance.accrualInterest,
      'isOFZ': instance.isOFZ,
      'rating': instance.rating,
      'issuer': instance.issuer,
    };

Stock _$StockFromJson(Map<String, dynamic> json) => Stock(
      id: json['id'] as String,
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      dividendYield: (json['dividendYield'] as num).toDouble(),
      eps: (json['eps'] as num).toDouble(),
      pe: (json['pe'] as num).toDouble(),
      roe: (json['roe'] as num).toDouble(),
      dividendPayout: (json['dividendPayout'] as num).toDouble(),
      sector: $enumDecode(_$SectorEnumMap, json['sector']),
      isExporter: json['isExporter'] as bool,
      marketCap: (json['marketCap'] as num).toDouble(),
      companyName: json['companyName'] as String?,
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$StockToJson(Stock instance) => <String, dynamic>{
      'id': instance.id,
      'ticker': instance.ticker,
      'name': instance.name,
      'currentPrice': instance.currentPrice,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'dividendYield': instance.dividendYield,
      'eps': instance.eps,
      'pe': instance.pe,
      'roe': instance.roe,
      'dividendPayout': instance.dividendPayout,
      'sector': _$SectorEnumMap[instance.sector]!,
      'isExporter': instance.isExporter,
      'marketCap': instance.marketCap,
      'companyName': instance.companyName,
    };

const _$SectorEnumMap = {
  Sector.energy: 'energy',
  Sector.metals: 'metals',
  Sector.chemicals: 'chemicals',
  Sector.transport: 'transport',
  Sector.finance: 'finance',
  Sector.utilities: 'utilities',
  Sector.it: 'it',
  Sector.retail: 'retail',
  Sector.infrastructure: 'infrastructure',
  Sector.other: 'other',
};

Futures _$FuturesFromJson(Map<String, dynamic> json) => Futures(
      id: json['id'] as String,
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      currentPrice: (json['currentPrice'] as num).toDouble(),
      underlyingAsset: json['underlyingAsset'] as String,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      multiplier: (json['multiplier'] as num).toDouble(),
      volatility: (json['volatility'] as num).toDouble(),
      riskFreeRate: (json['riskFreeRate'] as num).toDouble(),
      role: $enumDecode(_$FuturesRoleEnumMap, json['role']),
      spotPrice: (json['spotPrice'] as num?)?.toDouble(),
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$FuturesToJson(Futures instance) => <String, dynamic>{
      'id': instance.id,
      'ticker': instance.ticker,
      'name': instance.name,
      'currentPrice': instance.currentPrice,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'underlyingAsset': instance.underlyingAsset,
      'expirationDate': instance.expirationDate.toIso8601String(),
      'multiplier': instance.multiplier,
      'volatility': instance.volatility,
      'riskFreeRate': instance.riskFreeRate,
      'spotPrice': instance.spotPrice,
      'role': _$FuturesRoleEnumMap[instance.role]!,
    };

const _$FuturesRoleEnumMap = {
  FuturesRole.hedger: 'hedger',
  FuturesRole.speculator: 'speculator',
  FuturesRole.arbitrageur: 'arbitrageur',
};
