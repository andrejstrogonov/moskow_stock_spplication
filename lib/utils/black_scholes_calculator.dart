import 'dart:math';
import '../models/instrument.dart';

/// Калькулятор Блека-Шоулза для оценки фьючерсов
/// с поддержкой трёх сценариев: хеджер, спекулянт, арбитражер
class BlackScholesCalculator {
  /// Расчёт справедливой стоимости фьючерса по модели Блека-Шоулза
  /// F = S * e^(r*T)
  /// где S - текущая спот-цена
  /// r - безрисковая ставка
  /// T - время до экспирации (лет)
  static double fairFuturesPrice(Futures futures) {
    double spotPrice = futures.spotPrice ?? futures.currentPrice;
    double r = futures.riskFreeRate / 100;
    double T = futures.yearsToExpiration;

    return spotPrice * exp(r * T);
  }

  /// Дельта фьючерса (изменение цены при изменении спот-цены на 1)
  static double delta(Futures futures) {
    // Для фьючерса дельта = 1 (по определению)
    return 1.0;
  }

  /// Гамма фьючерса (производная дельты)
  static double gamma(Futures futures) {
    // Для фьючерса гамма = 0
    return 0.0;
  }

  /// Тета фьючерса (греча - влияние времени)
  /// Teta = -r * F * T (упрощённо)
  static double theta(Futures futures) {
    double F = fairFuturesPrice(futures);
    double r = futures.riskFreeRate / 100;
    double T = futures.yearsToExpiration;

    if (T == 0) return 0;
    return -(r * F);
  }

  /// Рхо фьючерса (чувствительность к процентным ставкам)
  static double rho(Futures futures) {
    double spotPrice = futures.spotPrice ?? futures.currentPrice;
    double T = futures.yearsToExpiration;

    return spotPrice * T;
  }

  /// Вега фьючерса (чувствительность к волатильности)
  static double vega(Futures futures) {
    double spotPrice = futures.spotPrice ?? futures.currentPrice;
    double sigma = futures.volatility / 100;
    double T = futures.yearsToExpiration;
    double r = futures.riskFreeRate / 100;

    if (T == 0 || sigma == 0) return 0;

    double d1 = (log(futures.currentPrice / fairFuturesPrice(futures)) +
            (r + (sigma * sigma) / 2) * T) /
        (sigma * sqrt(T));

    return spotPrice * sqrt(T) * (1 / sqrt(2 * pi)) * exp(-(d1 * d1) / 2);
  }

  /// Анализ для ХЕДЖЕРА
  /// Хеджер использует фьючерсы для защиты от неблагоприятного движения цены
  static HedgerAnalysis analyzeForHedger(Futures futures, {
    required double spotPrice,
    required double targetPrice,
    required int contractsToHedge,
  }) {
    double fairPrice = fairFuturesPrice(futures);
    double fairness = ((futures.currentPrice - fairPrice) / fairPrice) * 100;

    // Хедж рацион = количество фьючерсов для полной страховки
    int hedgeRatio = contractsToHedge;

    // Стоимость хеджирования
    double hedgeCost = hedgeRatio * (fairPrice - futures.currentPrice).abs();

    // Защита от движения на 1%
    double protectionPer1Percent = hedgeRatio * futures.currentPrice * 0.01;

    // Сценарии по цене
    List<HedgeScenario> scenarios = [];
    for (int i = -10; i <= 10; i += 2) {
      double newPrice = spotPrice * (1 + i / 100);
      double unhedgedPnL = (newPrice - spotPrice) * contractsToHedge;
      double hedgedPnL = unhedgedPnL -
          (newPrice - futures.currentPrice) * hedgeRatio; // Противоположное движение

      scenarios.add(HedgeScenario(
        priceChange: i,
        newPrice: newPrice,
        unhedgedPnL: unhedgedPnL,
        hedgedPnL: hedgedPnL,
      ));
    }

    return HedgerAnalysis(
      fairPrice: fairPrice,
      fairnessPercent: fairness,
      currentPrice: futures.currentPrice,
      hedgeRatio: hedgeRatio,
      hedgeCost: hedgeCost,
      protectionPer1Percent: protectionPer1Percent,
      scenarios: scenarios,
      recommendation: fairness > 2
          ? 'Фьючерс переоценен, хеджирование дорого'
          : fairness < -2
              ? 'Фьючерс недооценен, хеджирование дешево'
              : 'Справедливая оценка, хеджирование в норме',
    );
  }

  /// Анализ для СПЕКУЛЯНТА
  /// Спекулянт использует рычаг и ставит на движение цены в определённом направлении
  static SpeculatorAnalysis analyzeForSpeculator(Futures futures, {
    required double initialCapital,
    required double leverage,
    required double volatility,
  }) {
    double multiplier = futures.multiplier;
    double currentPrice = futures.currentPrice;
    double spotPrice = futures.spotPrice ?? currentPrice;

    // Количество контрактов с рычагом
    int contractsWithLeverage = ((initialCapital * leverage) / currentPrice).round();

    // Максимальный убыток (маржа)
    double marginRequired = contractsWithLeverage * currentPrice;
    double maxLoss = min(marginRequired, initialCapital);

    // Волатильность в абсолютных единицах за период до экспирации
    double volatilityInPrice = currentPrice * (volatility / 100) * sqrt(futures.yearsToExpiration);

    // Три сценария
    List<SpeculationScenario> scenarios = [];

    // Bull сценарий (+)
    double bullPrice = spotPrice * (1 + volatilityInPrice / spotPrice);
    double bullPnL = (bullPrice - currentPrice) * contractsWithLeverage * multiplier;
    scenarios.add(SpeculationScenario(
      name: 'Бычий сценарий (рост)',
      priceTarget: bullPrice,
      pnL: bullPnL,
      returnPercent: (bullPnL / initialCapital) * 100,
    ));

    // Base сценарий (без движения)
    scenarios.add(SpeculationScenario(
      name: 'Базовый сценарий (стагнация)',
      priceTarget: spotPrice,
      pnL: (spotPrice - currentPrice) * contractsWithLeverage * multiplier,
      returnPercent: ((spotPrice - currentPrice) * contractsWithLeverage * multiplier / initialCapital) * 100,
    ));

    // Bear сценарий (-)
    double bearPrice = spotPrice * (1 - volatilityInPrice / spotPrice);
    double bearPnL = (bearPrice - currentPrice) * contractsWithLeverage * multiplier;
    scenarios.add(SpeculationScenario(
      name: 'Медвежий сценарий (падение)',
      priceTarget: bearPrice,
      pnL: bearPnL,
      returnPercent: (bearPnL / initialCapital) * 100,
    ));

    return SpeculatorAnalysis(
      initialCapital: initialCapital,
      leverage: leverage,
      contractsWithLeverage: contractsWithLeverage,
      marginRequired: marginRequired,
      maxLoss: maxLoss,
      scenarios: scenarios,
      riskReward: (scenarios[0].pnL / maxLoss.abs()),
      recommendation: leverage > 5
          ? 'ВЫСОКИЙ РИСК! Рычаг слишком большой'
          : leverage > 3
              ? 'Умеренный риск, требует опыта'
              : 'Приемлемый риск для спекуляции',
    );
  }

  /// Анализ для АРБИТРАЖЕРА
  /// Арбитражер ищет разницу между спот и фьючерс ценами (basis)
  static ArbitrageAnalysis analyzeForArbitrageur(Futures futures, {
    required double spotPrice,
    double transactionCostPercent = 0.1,
  }) {
    double fairPrice = fairFuturesPrice(futures);
    double currentPrice = futures.currentPrice;

    // Basis = текущая цена фьючерса - спот цена
    double basis = currentPrice - spotPrice;
    double basisPercent = (basis / spotPrice) * 100;

    // Справедливый basis
    double fairBasis = fairPrice - spotPrice;
    double fairBasisPercent = (fairBasis / spotPrice) * 100;

    // Возможность арбитража
    double arbitrageMispricing = basis - fairBasis;
    double arbitrageMispricingPercent = (arbitrageMispricing / spotPrice) * 100;

    // Стоимость операции (комиссия + спреды)
    double transactionCost = spotPrice * (transactionCostPercent / 100) * 2; // Туда и обратно

    // Прибыльность арбитража
    bool isProfitable = arbitrageMispricing.abs() > transactionCost;
    double netArbitrage = arbitrageMispricing - transactionCost;
    double netArbitragePercent = (netArbitrage / spotPrice) * 100;

    // Рекомендация
    String arbitrageType = '';
    if (basis > fairBasis + transactionCost) {
      arbitrageType = 'Cash-and-Carry: Купить спот, продать фьючерс';
    } else if (basis < fairBasis - transactionCost) {
      arbitrageType = 'Reverse Cash-and-Carry: Короткая продажа спота, покупка фьючерса';
    } else {
      arbitrageType = 'Арбитража нет (цены справедливы)';
    }

    return ArbitrageAnalysis(
      spotPrice: spotPrice,
      futuresPrice: currentPrice,
      fairFuturesPrice: fairPrice,
      basis: basis,
      basisPercent: basisPercent,
      fairBasis: fairBasis,
      fairBasisPercent: fairBasisPercent,
      arbitrageMispricing: arbitrageMispricing,
      arbitrageMispricingPercent: arbitrageMispricingPercent,
      transactionCost: transactionCost,
      netArbitrage: netArbitrage,
      netArbitragePercent: netArbitragePercent,
      isProfitable: isProfitable,
      arbitrageType: arbitrageType,
    );
  }
}

// ============ МОДЕЛИ РЕЗУЛЬТАТОВ ============

/// Результаты анализа для хеджера
class HedgerAnalysis {
  final double fairPrice;
  final double fairnessPercent;
  final double currentPrice;
  final int hedgeRatio;
  final double hedgeCost;
  final double protectionPer1Percent;
  final List<HedgeScenario> scenarios;
  final String recommendation;

  HedgerAnalysis({
    required this.fairPrice,
    required this.fairnessPercent,
    required this.currentPrice,
    required this.hedgeRatio,
    required this.hedgeCost,
    required this.protectionPer1Percent,
    required this.scenarios,
    required this.recommendation,
  });
}

/// Сценарий для хеджера
class HedgeScenario {
  final int priceChange;
  final double newPrice;
  final double unhedgedPnL;
  final double hedgedPnL;

  HedgeScenario({
    required this.priceChange,
    required this.newPrice,
    required this.unhedgedPnL,
    required this.hedgedPnL,
  });
}

/// Результаты анализа для спекулянта
class SpeculatorAnalysis {
  final double initialCapital;
  final double leverage;
  final int contractsWithLeverage;
  final double marginRequired;
  final double maxLoss;
  final List<SpeculationScenario> scenarios;
  final double riskReward;
  final String recommendation;

  SpeculatorAnalysis({
    required this.initialCapital,
    required this.leverage,
    required this.contractsWithLeverage,
    required this.marginRequired,
    required this.maxLoss,
    required this.scenarios,
    required this.riskReward,
    required this.recommendation,
  });
}

/// Сценарий для спекулянта
class SpeculationScenario {
  final String name;
  final double priceTarget;
  final double pnL;
  final double returnPercent;

  SpeculationScenario({
    required this.name,
    required this.priceTarget,
    required this.pnL,
    required this.returnPercent,
  });
}

/// Результаты анализа для арбитражера
class ArbitrageAnalysis {
  final double spotPrice;
  final double futuresPrice;
  final double fairFuturesPrice;
  final double basis;
  final double basisPercent;
  final double fairBasis;
  final double fairBasisPercent;
  final double arbitrageMispricing;
  final double arbitrageMispricingPercent;
  final double transactionCost;
  final double netArbitrage;
  final double netArbitragePercent;
  final bool isProfitable;
  final String arbitrageType;

  ArbitrageAnalysis({
    required this.spotPrice,
    required this.futuresPrice,
    required this.fairFuturesPrice,
    required this.basis,
    required this.basisPercent,
    required this.fairBasis,
    required this.fairBasisPercent,
    required this.arbitrageMispricing,
    required this.arbitrageMispricingPercent,
    required this.transactionCost,
    required this.netArbitrage,
    required this.netArbitragePercent,
    required this.isProfitable,
    required this.arbitrageType,
  });
}

