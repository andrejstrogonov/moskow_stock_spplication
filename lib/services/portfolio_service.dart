import '../models/instrument.dart';
import '../models/portfolio.dart';
import '../models/position.dart';

/// Сервис управления портфелями и инструментами
class PortfolioService {
  static final PortfolioService _instance = PortfolioService._internal();

  factory PortfolioService() {
    return _instance;
  }

  PortfolioService._internal();

  // Хранилище портфелей
  final List<Portfolio> _portfolios = [];

  // Хранилище инструментов
  final List<Instrument> _instruments = [];

  // Инициализация примеров
  void initialize() {
    _instruments.clear();
    _portfolios.clear();
    _loadSampleInstruments();
    _loadSamplePortfolios();
  }

  /// Загрузка примеров инструментов с Московской биржи
  void _loadSampleInstruments() {
    // ===== ОБЛИГАЦИИ =====

    // ОФЗ (государственные облигации)
    _instruments.add(Bond(
      id: 'ofz_1',
      ticker: 'OFZ26',
      name: 'ОФЗ-26',
      faceValue: 1000,
      couponRate: 7.5,
      couponFrequency: 2,
      maturityDate: DateTime(2026, 6, 10),
      currentPrice: 1005,
      accrualInterest: 25,
      isOFZ: true,
    ));

    _instruments.add(Bond(
      id: 'ofz_2',
      ticker: 'OFZ27',
      name: 'ОФЗ-27',
      faceValue: 1000,
      couponRate: 8.0,
      couponFrequency: 2,
      maturityDate: DateTime(2027, 9, 15),
      currentPrice: 998,
      accrualInterest: 30,
      isOFZ: true,
    ));

    // Корпоративные облигации
    _instruments.add(Bond(
      id: 'bond_sber',
      ticker: 'SiSi',
      name: 'Облигации Сбербанка',
      faceValue: 1000,
      couponRate: 9.0,
      couponFrequency: 2,
      maturityDate: DateTime(2025, 12, 15),
      currentPrice: 1020,
      accrualInterest: 20,
      isOFZ: false,
      issuer: 'Сбербанк',
      rating: 8.5,
    ));

    _instruments.add(Bond(
      id: 'bond_gazprom',
      ticker: 'GZNi',
      name: 'Облигации Газпрома',
      faceValue: 1000,
      couponRate: 8.5,
      couponFrequency: 2,
      maturityDate: DateTime(2026, 3, 15),
      currentPrice: 1010,
      accrualInterest: 28,
      isOFZ: false,
      issuer: 'Газпром',
      rating: 9.0,
    ));

    // ===== АКЦИИ =====

    // Нефтегаз (экспортёры)
    _instruments.add(Stock(
      id: 'stock_lukoil',
      ticker: 'LKOH',
      name: 'ЛУКОЙЛ',
      currentPrice: 5850,
      dividendYield: 10.5,
      eps: 485.2,
      pe: 12.1,
      roe: 23.5,
      dividendPayout: 45,
      sector: Sector.energy,
      isExporter: true,
      marketCap: 2850,
      companyName: 'ПАО ЛУКОЙЛ',
    ));

    _instruments.add(Stock(
      id: 'stock_gazprom',
      ticker: 'GAZP',
      name: 'Газпром',
      currentPrice: 145.80,
      dividendYield: 9.2,
      eps: 15.4,
      pe: 9.5,
      roe: 18.2,
      dividendPayout: 50,
      sector: Sector.energy,
      isExporter: true,
      marketCap: 7200,
      companyName: 'ОАО Газпром',
    ));

    // Металлы и добыча
    _instruments.add(Stock(
      id: 'stock_nornickel',
      ticker: 'GMKN',
      name: 'Норильский никель',
      currentPrice: 12500,
      dividendYield: 8.8,
      eps: 1250,
      pe: 10.0,
      roe: 22.5,
      dividendPayout: 55,
      sector: Sector.metals,
      isExporter: true,
      marketCap: 1250,
      companyName: 'ПАО Норильский никель',
    ));

    _instruments.add(Stock(
      id: 'stock_magnitogorsk',
      ticker: 'MAGN',
      name: 'Магнитогорский меткомбинат',
      currentPrice: 28.5,
      dividendYield: 11.2,
      eps: 3.2,
      pe: 8.9,
      roe: 25.0,
      dividendPayout: 60,
      sector: Sector.metals,
      isExporter: true,
      marketCap: 320,
      companyName: 'ПАО ММК',
    ));

    // Финансовый сектор
    _instruments.add(Stock(
      id: 'stock_sber',
      ticker: 'SBER',
      name: 'Сбербанк',
      currentPrice: 275.50,
      dividendYield: 7.5,
      eps: 24.8,
      pe: 11.1,
      roe: 16.5,
      dividendPayout: 50,
      sector: Sector.finance,
      isExporter: false,
      marketCap: 4500,
      companyName: 'ПАО Сбербанк',
    ));

    _instruments.add(Stock(
      id: 'stock_vtb',
      ticker: 'VTBR',
      name: 'ВТБ',
      currentPrice: 0.62,
      dividendYield: 12.0,
      eps: 0.065,
      pe: 9.5,
      roe: 14.0,
      dividendPayout: 55,
      sector: Sector.finance,
      isExporter: false,
      marketCap: 2800,
      companyName: 'ПАО Банк ВТБ',
    ));

    // Инфраструктура
    _instruments.add(Stock(
      id: 'stock_railway',
      ticker: 'RSTI',
      name: 'РЖД',
      currentPrice: 78.5,
      dividendYield: 6.5,
      eps: 5.2,
      pe: 15.1,
      roe: 12.0,
      dividendPayout: 40,
      sector: Sector.infrastructure,
      isExporter: false,
      marketCap: 850,
      companyName: 'ОАО РЖД',
    ));

    // IT и технологии
    _instruments.add(Stock(
      id: 'stock_yandex',
      ticker: 'YNDX',
      name: 'Яндекс',
      currentPrice: 2650,
      dividendYield: 0.5,
      eps: 180,
      pe: 14.7,
      roe: 18.5,
      dividendPayout: 10,
      sector: Sector.it,
      isExporter: false,
      marketCap: 950,
      companyName: 'N.V. Яндекс',
    ));

    // ===== ФЬЮЧЕРСЫ =====

    _instruments.add(Futures(
      id: 'futures_si',
      ticker: 'Si',
      name: 'Фьючерс на доллар-рубль',
      currentPrice: 95.50,
      underlyingAsset: 'USD/RUB',
      expirationDate: DateTime(2026, 6, 15),
      multiplier: 1.0,
      volatility: 18.5,
      riskFreeRate: 16.0,
      role: FuturesRole.hedger,
      spotPrice: 95.20,
    ));

    _instruments.add(Futures(
      id: 'futures_gazprom',
      ticker: 'GZ',
      name: 'Фьючерс на Газпром',
      currentPrice: 146.50,
      underlyingAsset: 'GAZP',
      expirationDate: DateTime(2026, 6, 30),
      multiplier: 100,
      volatility: 22.0,
      riskFreeRate: 16.0,
      role: FuturesRole.speculator,
      spotPrice: 145.80,
    ));

    _instruments.add(Futures(
      id: 'futures_oil',
      ticker: 'BRF',
      name: 'Фьючерс на Brent нефть',
      currentPrice: 82.30,
      underlyingAsset: 'BRENT',
      expirationDate: DateTime(2026, 5, 20),
      multiplier: 100,
      volatility: 25.0,
      riskFreeRate: 16.0,
      role: FuturesRole.arbitrageur,
      spotPrice: 81.50,
    ));
  }

  /// Загрузка примеров портфелей
  void _loadSamplePortfolios() {
    // Консервативный портфель
    _portfolios.add(Portfolio(
      id: 'portfolio_conservative',
      name: 'Консервативный портфель',
      description: 'Ориентирован на сохранение капитала и стабильный доход 10-14% годовых',
      type: PortfolioType.conservative,
      positions: [
        Position(
          id: 'pos_1',
          instrumentId: 'ofz_1',
          quantity: 10,
          purchasePrice: 1000,
          purchaseDate: DateTime(2025, 3, 1),
          currentPrice: 1005,
          notes: 'ОФЗ базовый инструмент',
        ),
        Position(
          id: 'pos_2',
          instrumentId: 'bond_sber',
          quantity: 5,
          purchasePrice: 1010,
          purchaseDate: DateTime(2025, 3, 1),
          currentPrice: 1020,
          notes: 'Корпоративные облигации',
        ),
        Position(
          id: 'pos_3',
          instrumentId: 'stock_gazprom',
          quantity: 50,
          purchasePrice: 140,
          purchaseDate: DateTime(2025, 3, 1),
          currentPrice: 145.80,
          notes: 'Дивидендный экспортёр',
        ),
      ],
      targetBonds: 55,
      targetStocks: 35,
      targetFutures: 0,
      targetCash: 10,
    ));

    // Сбалансированный портфель
    _portfolios.add(Portfolio(
      id: 'portfolio_balanced',
      name: 'Сбалансированный портфель',
      description: 'Комбинация роста и дохода, потенциал 15-25% годовых',
      type: PortfolioType.balanced,
      positions: [
        Position(
          id: 'pos_4',
          instrumentId: 'ofz_2',
          quantity: 8,
          purchasePrice: 995,
          purchaseDate: DateTime(2025, 3, 1),
          currentPrice: 998,
          notes: 'ОФЗ длинные',
        ),
        Position(
          id: 'pos_5',
          instrumentId: 'stock_lukoil',
          quantity: 20,
          purchasePrice: 5600,
          purchaseDate: DateTime(2025, 3, 1),
          currentPrice: 5850,
          notes: 'Основной экспортёр',
        ),
        Position(
          id: 'pos_6',
          instrumentId: 'stock_sber',
          quantity: 30,
          purchasePrice: 270,
          purchaseDate: DateTime(2025, 3, 1),
          currentPrice: 275.50,
          notes: 'Дивидендный якорь',
        ),
      ],
      targetBonds: 35,
      targetStocks: 50,
      targetFutures: 5,
      targetCash: 10,
    ));

    // Агрессивный портфель
    _portfolios.add(Portfolio(
      id: 'portfolio_aggressive',
      name: 'Агрессивный портфель',
      description: 'Максимизация роста, потенциал 25-40%+ годовых с высокой волатильностью',
      type: PortfolioType.aggressive,
      positions: [
        Position(
          id: 'pos_7',
          instrumentId: 'stock_nornickel',
          quantity: 5,
          purchasePrice: 12000,
          purchaseDate: DateTime(2025, 3, 1),
          currentPrice: 12500,
          notes: 'Высокодивидендный экспортёр',
        ),
        Position(
          id: 'pos_8',
          instrumentId: 'stock_yandex',
          quantity: 8,
          purchasePrice: 2500,
          purchaseDate: DateTime(2025, 3, 1),
          currentPrice: 2650,
          notes: 'Ростовая история',
        ),
        Position(
          id: 'pos_9',
          instrumentId: 'futures_si',
          quantity: 10,
          purchasePrice: 94.50,
          purchaseDate: DateTime(2025, 3, 1),
          currentPrice: 95.50,
          notes: 'Спекулятивный блок - фьючерс валютной пары',
        ),
      ],
      targetBonds: 15,
      targetStocks: 65,
      targetFutures: 15,
      targetCash: 5,
    ));
  }

  // ===== МЕТОДЫ УПРАВЛЕНИЯ ПОРТФЕЛЯМИ =====

  List<Portfolio> getPortfolios() => _portfolios;

  Portfolio? getPortfolioById(String id) {
    try {
      return _portfolios.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void addPortfolio(Portfolio portfolio) {
    _portfolios.add(portfolio);
  }

  void updatePortfolio(Portfolio portfolio) {
    int index = _portfolios.indexWhere((p) => p.id == portfolio.id);
    if (index >= 0) {
      _portfolios[index] = portfolio;
    }
  }

  void deletePortfolio(String portfolioId) {
    _portfolios.removeWhere((p) => p.id == portfolioId);
  }

  // ===== МЕТОДЫ УПРАВЛЕНИЯ ИНСТРУМЕНТАМИ =====

  List<Instrument> getInstruments({InstrumentType? type}) {
    if (type == null) {
      return _instruments;
    }
    return _instruments.where((i) => i.type == type).toList();
  }

  Instrument? getInstrumentById(String id) {
    try {
      return _instruments.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  void addInstrument(Instrument instrument) {
    _instruments.add(instrument);
  }

  void updateInstrument(Instrument instrument) {
    int index = _instruments.indexWhere((i) => i.id == instrument.id);
    if (index >= 0) {
      _instruments[index] = instrument;
    }
  }

  void deleteInstrument(String instrumentId) {
    _instruments.removeWhere((i) => i.id == instrumentId);
  }

  // ===== МЕТОДЫ РАБОТЫ С ПОЗИЦИЯМИ =====

  void addPositionToPortfolio(String portfolioId, Position position) {
    Portfolio? portfolio = getPortfolioById(portfolioId);
    if (portfolio != null) {
      List<Position> updatedPositions = [...portfolio.positions, position];
      Portfolio updatedPortfolio = Portfolio(
        id: portfolio.id,
        name: portfolio.name,
        description: portfolio.description,
        type: portfolio.type,
        positions: updatedPositions,
        createdDate: portfolio.createdDate,
        lastModified: DateTime.now(),
        targetBonds: portfolio.targetBonds,
        targetStocks: portfolio.targetStocks,
        targetFutures: portfolio.targetFutures,
        targetCash: portfolio.targetCash,
      );
      updatePortfolio(updatedPortfolio);
    }
  }

  void updatePositionInPortfolio(String portfolioId, Position position) {
    Portfolio? portfolio = getPortfolioById(portfolioId);
    if (portfolio != null) {
      List<Position> updatedPositions = portfolio.positions
          .map((p) => p.id == position.id ? position : p)
          .toList();
      Portfolio updatedPortfolio = Portfolio(
        id: portfolio.id,
        name: portfolio.name,
        description: portfolio.description,
        type: portfolio.type,
        positions: updatedPositions,
        createdDate: portfolio.createdDate,
        lastModified: DateTime.now(),
        targetBonds: portfolio.targetBonds,
        targetStocks: portfolio.targetStocks,
        targetFutures: portfolio.targetFutures,
        targetCash: portfolio.targetCash,
      );
      updatePortfolio(updatedPortfolio);
    }
  }

  void removePositionFromPortfolio(String portfolioId, String positionId) {
    Portfolio? portfolio = getPortfolioById(portfolioId);
    if (portfolio != null) {
      List<Position> updatedPositions =
          portfolio.positions.where((p) => p.id != positionId).toList();
      Portfolio updatedPortfolio = Portfolio(
        id: portfolio.id,
        name: portfolio.name,
        description: portfolio.description,
        type: portfolio.type,
        positions: updatedPositions,
        createdDate: portfolio.createdDate,
        lastModified: DateTime.now(),
        targetBonds: portfolio.targetBonds,
        targetStocks: portfolio.targetStocks,
        targetFutures: portfolio.targetFutures,
        targetCash: portfolio.targetCash,
      );
      updatePortfolio(updatedPortfolio);
    }
  }

  // ===== АНАЛИЗ ПОРТФЕЛЯ =====

  /// Получить распределение портфеля по типам инструментов
  Map<InstrumentType, double> getPortfolioAllocation(Portfolio portfolio) {
    double totalValue = portfolio.totalMarketValue;
    if (totalValue == 0) {
      return {
        InstrumentType.bond: 0,
        InstrumentType.stock: 0,
        InstrumentType.futures: 0,
      };
    }

    double bondsValue = 0;
    double stocksValue = 0;
    double futuresValue = 0;

    for (var position in portfolio.positions) {
      Instrument? instrument = getInstrumentById(position.instrumentId);
      if (instrument != null) {
        double positionValue = position.marketValue;
        if (instrument.type == InstrumentType.bond) {
          bondsValue += positionValue;
        } else if (instrument.type == InstrumentType.stock) {
          stocksValue += positionValue;
        } else if (instrument.type == InstrumentType.futures) {
          futuresValue += positionValue;
        }
      }
    }

    return {
      InstrumentType.bond: (bondsValue / totalValue) * 100,
      InstrumentType.stock: (stocksValue / totalValue) * 100,
      InstrumentType.futures: (futuresValue / totalValue) * 100,
    };
  }

  /// Получить количество экспортёров в портфеле
  int getExportersCount(Portfolio portfolio) {
    int count = 0;
    for (var position in portfolio.positions) {
      Instrument? instrument = getInstrumentById(position.instrumentId);
      if (instrument is Stock && instrument.isExporter) {
        count++;
      }
    }
    return count;
  }
}

