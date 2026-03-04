import 'package:json_annotation/json_annotation.dart';

part 'instrument.g.dart';

/// Тип финансового инструмента
enum InstrumentType { bond, stock, futures }

/// Сектор акции
enum Sector {
  energy,           // Энергетика (нефтегаз, электроэнергетика)
  metals,           // Металлы и добыча
  chemicals,        // Химия и удобрения
  transport,        // Логистика и транспорт
  finance,          // Финансовый сектор
  utilities,        // Коммунальные услуги
  it,               // IT и технологии
  retail,           // Ритейл
  infrastructure,   // Инфраструктура
  other,            // Другое
}

/// Роль для фьючерсов
enum FuturesRole { hedger, speculator, arbitrageur }

/// Базовый класс для финансовых инструментов
@JsonSerializable()
class Instrument {
  final String id;
  final String ticker;
  final String name;
  final InstrumentType type;
  final double currentPrice;
  final DateTime lastUpdate;

  Instrument({
    required this.id,
    required this.ticker,
    required this.name,
    required this.type,
    required this.currentPrice,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();

  factory Instrument.fromJson(Map<String, dynamic> json) =>
      _$InstrumentFromJson(json);

  Map<String, dynamic> toJson() => _$InstrumentToJson(this);
}

/// Облигация
@JsonSerializable()
class Bond extends Instrument {
  final double faceValue;          // Номинальная стоимость
  final double couponRate;         // Годовой купон (%)
  final int couponFrequency;       // Частота выплаты купонов (раз в год)
  final DateTime maturityDate;     // Дата погашения
  final double accrualInterest;    // Накопленный процент
  final bool isOFZ;                // ОФЗ или корпоративная облигация
  final double? rating;            // Кредитный рейтинг (если есть)
  final String? issuer;            // Эмитент

  Bond({
    required String id,
    required String ticker,
    required String name,
    required double currentPrice,
    required this.faceValue,
    required this.couponRate,
    required this.couponFrequency,
    required this.maturityDate,
    required this.accrualInterest,
    required this.isOFZ,
    this.rating,
    this.issuer,
    DateTime? lastUpdate,
  }) : super(
    id: id,
    ticker: ticker,
    name: name,
    type: InstrumentType.bond,
    currentPrice: currentPrice,
    lastUpdate: lastUpdate,
  );

  /// Дней до погашения
  int get daysToMaturity =>
      maturityDate.difference(DateTime.now()).inDays;

  /// Лет до погашения
  double get yearsToMaturity => daysToMaturity / 365.25;

  factory Bond.fromJson(Map<String, dynamic> json) => _$BondFromJson(json);

  Map<String, dynamic> toJson() => _$BondToJson(this);
}

/// Акция
@JsonSerializable()
class Stock extends Instrument {
  final double dividendYield;      // Дивидендная доходность (%)
  final double eps;                // Прибыль на акцию (EPS)
  final double pe;                 // P/E коэффициент
  final double roe;                // ROE (Return on Equity)
  final double dividendPayout;     // Процент дивидендов от прибыли
  final Sector sector;
  final bool isExporter;           // Экспортёр (для валютного хеджа)
  final double marketCap;          // Рыночная капитализация (млрд руб)
  final String? companyName;

  Stock({
    required String id,
    required String ticker,
    required String name,
    required double currentPrice,
    required this.dividendYield,
    required this.eps,
    required this.pe,
    required this.roe,
    required this.dividendPayout,
    required this.sector,
    required this.isExporter,
    required this.marketCap,
    this.companyName,
    DateTime? lastUpdate,
  }) : super(
    id: id,
    ticker: ticker,
    name: name,
    type: InstrumentType.stock,
    currentPrice: currentPrice,
    lastUpdate: lastUpdate,
  );

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);

  Map<String, dynamic> toJson() => _$StockToJson(this);
}

/// Фьючерс
@JsonSerializable()
class Futures extends Instrument {
  final String underlyingAsset;    // Базовый актив
  final DateTime expirationDate;   // Дата экспирации
  final double multiplier;         // Множитель контракта
  final double volatility;         // Волатильность (%)
  final double riskFreeRate;       // Безрисковая ставка (%)
  final double? spotPrice;         // Спот-цена базового актива
  final FuturesRole role;          // Роль трейдера

  Futures({
    required String id,
    required String ticker,
    required String name,
    required double currentPrice,
    required this.underlyingAsset,
    required this.expirationDate,
    required this.multiplier,
    required this.volatility,
    required this.riskFreeRate,
    required this.role,
    this.spotPrice,
    DateTime? lastUpdate,
  }) : super(
    id: id,
    ticker: ticker,
    name: name,
    type: InstrumentType.futures,
    currentPrice: currentPrice,
    lastUpdate: lastUpdate,
  );

  /// Дней до экспирации
  int get daysToExpiration =>
      expirationDate.difference(DateTime.now()).inDays;

  /// Лет до экспирации
  double get yearsToExpiration => daysToExpiration / 365.25;

  factory Futures.fromJson(Map<String, dynamic> json) =>
      _$FuturesFromJson(json);

  Map<String, dynamic> toJson() => _$FuturesToJson(this);
}

