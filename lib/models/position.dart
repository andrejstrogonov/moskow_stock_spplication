import 'package:json_annotation/json_annotation.dart';

part 'position.g.dart';

/// Позиция в портфеле
@JsonSerializable()
class Position {
  final String id;
  final String instrumentId;
  final double quantity;           // Количество ценных бумаг/контрактов
  final double purchasePrice;      // Цена покупки
  final DateTime purchaseDate;
  final double currentPrice;       // Текущая рыночная цена
  final String notes;

  Position({
    required this.id,
    required this.instrumentId,
    required this.quantity,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.currentPrice,
    this.notes = '',
  });

  /// Текущая стоимость позиции
  double get marketValue => quantity * currentPrice;

  /// Начальная стоимость позиции
  double get costBasis => quantity * purchasePrice;

  /// Прибыль/убыток (в деньгах)
  double get profitLoss => marketValue - costBasis;

  /// Процент изменения
  double get percentChange => (profitLoss / costBasis) * 100;

  /// Дней с покупки
  int get daysSincePurchase =>
      DateTime.now().difference(purchaseDate).inDays;

  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);

  Map<String, dynamic> toJson() => _$PositionToJson(this);
}

