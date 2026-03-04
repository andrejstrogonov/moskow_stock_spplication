import '../models/instrument.dart';

/// Класс для анализа параметров акций
class StockAnalyzer {
  /// Справедливая стоимость по модели дисконтирования дивидендов (DDM - Gordon Growth Model)
  /// fairValue = D1 / (r - g)
  /// где D1 - ожидаемый дивиденд на акцию в следующем году
  /// r - требуемая доходность (%)
  /// g - темп роста дивидендов (%)
  static double fairValueDDM(Stock stock, {
    required double requiredReturn,
    required double growthRate,
  }) {
    if (requiredReturn <= growthRate) {
      return double.infinity;
    }

    double annualDividend = stock.currentPrice * (stock.dividendYield / 100);
    double expectedDividend = annualDividend * (1 + growthRate / 100);
    double fairValue = expectedDividend / ((requiredReturn - growthRate) / 100);

    return fairValue;
  }

  /// Справедливая стоимость по P/E коэффициенту
  /// fairValue = EPS * targetPE
  static double fairValuePE(Stock stock, {required double targetPE}) {
    return stock.eps * targetPE;
  }

  /// Анализ оценки акции
  static StockValuation analyzeValuation(Stock stock) {
    // Использование средних исторических P/E для российского рынка
    // Консервативная оценка: P/E < 8
    // Справедливая: P/E 8-12
    // Дорогая: P/E > 12

    StockValuationStatus status;
    if (stock.pe < 8) {
      status = StockValuationStatus.undervalued;
    } else if (stock.pe <= 12) {
      status = StockValuationStatus.fair;
    } else {
      status = StockValuationStatus.overvalued;
    }

    return StockValuation(
      pe: stock.pe,
      dividendYield: stock.dividendYield,
      roe: stock.roe,
      status: status,
      riskLevel: calculateRiskLevel(stock),
    );
  }

  /// Расчёт уровня риска на основе показателей
  static RiskLevel calculateRiskLevel(Stock stock) {
    int riskScore = 0;

    // Анализ P/E (высокий P/E - выше риск)
    if (stock.pe > 15) {
      riskScore += 2;
    } else if (stock.pe > 12) {
      riskScore += 1;
    }

    // Анализ ROE (низкий ROE - выше риск)
    if (stock.roe < 5) {
      riskScore += 2;
    } else if (stock.roe < 10) {
      riskScore += 1;
    }

    // Анализ дивидендной политики (низкий пayout - риск снижения дивидендов)
    if (stock.dividendPayout < 20) {
      riskScore += 1;
    } else if (stock.dividendPayout > 80) {
      riskScore += 1; // Слишком высокий
    }

    // Анализ волатильности через дивидендный доход и P/E (приблизительно)
    if (stock.dividendYield < 1) {
      riskScore += 1;
    }

    if (riskScore >= 5) return RiskLevel.high;
    if (riskScore >= 3) return RiskLevel.medium;
    return RiskLevel.low;
  }

  /// Потенциал роста (%)
  static double growthPotential(Stock stock, {
    required double targetPE,
    required double expectedDividendGrowth,
  }) {
    double fairValue = fairValuePE(stock, targetPE: targetPE);
    double priceGrowthPercent = ((fairValue - stock.currentPrice) / stock.currentPrice) * 100;
    double totalReturnPercent = priceGrowthPercent + expectedDividendGrowth;

    return totalReturnPercent;
  }

  /// Анализ дивидендной истории и надёжности
  static DividendAnalysis analyzeDividend(Stock stock) {
    // Оценка устойчивости дивидендов
    DividendSustainability sustainability;

    // ROE должен быть достаточным для выплат
    if (stock.roe < 8) {
      sustainability = DividendSustainability.low;
    }
    // Payout ratio должен быть разумным (30-60% - оптимально)
    else if (stock.dividendPayout > 70 || stock.dividendPayout < 10) {
      sustainability = DividendSustainability.moderate;
    } else {
      sustainability = DividendSustainability.high;
    }

    double annualDividend = stock.currentPrice * (stock.dividendYield / 100);

    return DividendAnalysis(
      dividendPerShare: annualDividend / stock.currentPrice,
      dividendYield: stock.dividendYield,
      payoutRatio: stock.dividendPayout,
      sustainability: sustainability,
      recommendation: generateDividendRecommendation(stock),
    );
  }

  static String generateDividendRecommendation(Stock stock) {
    if (stock.dividendYield > 10 && stock.roe > 15) {
      return 'Высоко дивидендная история, надёжная компания';
    } else if (stock.dividendYield > 7 && stock.roe > 10) {
      return 'Хорошая дивидендная доходность';
    } else if (stock.dividendYield > 4) {
      return 'Умеренная дивидендная доходность';
    } else if (stock.dividendYield > 0) {
      return 'Низкая дивидендная доходность, ставка на рост';
    } else {
      return 'Дивиденды не выплачиваются';
    }
  }
}

/// Статус оценки акции
enum StockValuationStatus {
  undervalued,  // Недооценена
  fair,         // Справедливая оценка
  overvalued,   // Переоценена
}

/// Уровень риска
enum RiskLevel {
  low,    // Низкий
  medium, // Средний
  high,   // Высокий
}

/// Устойчивость дивидендов
enum DividendSustainability {
  low,      // Низкая
  moderate, // Средняя
  high,     // Высокая
}

/// Результаты анализа оценки акции
class StockValuation {
  final double pe;
  final double dividendYield;
  final double roe;
  final StockValuationStatus status;
  final RiskLevel riskLevel;

  StockValuation({
    required this.pe,
    required this.dividendYield,
    required this.roe,
    required this.status,
    required this.riskLevel,
  });
}

/// Результаты анализа дивидендов
class DividendAnalysis {
  final double dividendPerShare;
  final double dividendYield;
  final double payoutRatio;
  final DividendSustainability sustainability;
  final String recommendation;

  DividendAnalysis({
    required this.dividendPerShare,
    required this.dividendYield,
    required this.payoutRatio,
    required this.sustainability,
    required this.recommendation,
  });
}

