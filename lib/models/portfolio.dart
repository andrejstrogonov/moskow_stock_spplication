import 'package:json_annotation/json_annotation.dart';
import 'position.dart';

part 'portfolio.g.dart';

/// Тип портфеля
enum PortfolioType { conservative, balanced, aggressive, custom }

/// Портфель ценных бумаг
@JsonSerializable()
class Portfolio {
  final String id;
  final String name;
  final String description;
  final PortfolioType type;
  final List<Position> positions;
  final DateTime createdDate;
  final DateTime lastModified;

  // Целевые распределения (%)
  final double targetBonds;         // Облигации
  final double targetStocks;        // Акции
  final double targetFutures;       // Фьючерсы
  final double targetCash;          // Кэш

  Portfolio({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.positions = const [],
    DateTime? createdDate,
    DateTime? lastModified,
    required this.targetBonds,
    required this.targetStocks,
    required this.targetFutures,
    required this.targetCash,
  })  : createdDate = createdDate ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  /// Общая рыночная стоимость портфеля
  double get totalMarketValue =>
      positions.fold(0, (sum, pos) => sum + pos.marketValue);

  /// Общая стоимость по цене покупки
  double get totalCostBasis =>
      positions.fold(0, (sum, pos) => sum + pos.costBasis);

  /// Общий прибыль/убыток
  double get totalProfitLoss => totalMarketValue - totalCostBasis;

  /// Процент общего изменения
  double get totalPercentChange =>
      totalCostBasis > 0 ? (totalProfitLoss / totalCostBasis) * 100 : 0;

  /// Количество позиций
  int get positionCount => positions.length;

  factory Portfolio.fromJson(Map<String, dynamic> json) =>
      _$PortfolioFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioToJson(this);
}

