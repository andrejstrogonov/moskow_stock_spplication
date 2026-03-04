import 'dart:math';
import '../models/instrument.dart';

/// Класс для расчётов параметров облигаций
class BondCalculator {
  /// Текущая доходность = годовой купон / текущая цена
  static double currentYield(Bond bond) {
    if (bond.currentPrice == 0) return 0;
    double annualCoupon = bond.faceValue * (bond.couponRate / 100);
    return (annualCoupon / bond.currentPrice) * 100;
  }

  /// Простая доходность (Simple Yield to Maturity приближение)
  /// Используется метод Ньютона-Рафсона для поиска YTM
  static double yieldToMaturity(Bond bond) {
    if (bond.yearsToMaturity <= 0) {
      return 0;
    }

    double faceValue = bond.faceValue;
    double couponPayment = faceValue * (bond.couponRate / 100) / bond.couponFrequency;
    double price = bond.currentPrice;
    double yearsToMaturity = bond.yearsToMaturity;
    int couponPayments = (yearsToMaturity * bond.couponFrequency).round();

    // Метод Ньютона-Рафсона
    double ytm = bond.couponRate / 100 / bond.couponFrequency;
    double tolerance = 0.0001;
    int maxIterations = 100;

    for (int i = 0; i < maxIterations; i++) {
      double pv = 0;
      double dpv = 0;

      for (int t = 1; t <= couponPayments; t++) {
        pv += couponPayment / pow(1 + ytm, t);
        dpv += -t * couponPayment / pow(1 + ytm, t + 1);
      }

      pv += faceValue / pow(1 + ytm, couponPayments);
      dpv += -couponPayments * faceValue / pow(1 + ytm, couponPayments + 1);

      double f = pv - price;
      double df = dpv;

      if (df == 0) break;

      double ytmNew = ytm - f / df;

      if ((ytmNew - ytm).abs() < tolerance) {
        return ytmNew * 100 * bond.couponFrequency;
      }

      ytm = ytmNew;
    }

    return ytm * 100 * bond.couponFrequency;
  }

  /// Модифицированная дюрация (годы)
  static double modifiedDuration(Bond bond) {
    double ytm = yieldToMaturity(bond) / 100;
    double macaulayDuration = macaulayDurationCalc(bond, ytm);
    return macaulayDuration / (1 + ytm);
  }

  /// Дюрация Маколея (годы)
  static double macaulayDurationCalc(Bond bond, double ytm) {
    if (bond.yearsToMaturity <= 0 || ytm < -0.99) {
      return bond.yearsToMaturity;
    }

    double faceValue = bond.faceValue;
    double couponPayment = faceValue * (bond.couponRate / 100) / bond.couponFrequency;
    double yearsToMaturity = bond.yearsToMaturity;
    int couponPayments = (yearsToMaturity * bond.couponFrequency).round();
    double ytmPeriodic = ytm / bond.couponFrequency;

    double pv = 0;
    double weightedPv = 0;

    for (int t = 1; t <= couponPayments; t++) {
      double pvPayment = couponPayment / pow(1 + ytmPeriodic, t);
      pv += pvPayment;
      weightedPv += t * pvPayment;
    }

    double pvFace = faceValue / pow(1 + ytmPeriodic, couponPayments);
    pv += pvFace;
    weightedPv += couponPayments * pvFace;

    return (weightedPv / pv) / bond.couponFrequency;
  }

  /// Выпуклость (convexity)
  static double convexity(Bond bond) {
    double ytm = yieldToMaturity(bond) / 100;
    if (bond.yearsToMaturity <= 0 || ytm < -0.99) {
      return 0;
    }

    double faceValue = bond.faceValue;
    double couponPayment = faceValue * (bond.couponRate / 100) / bond.couponFrequency;
    double price = bond.currentPrice;
    double yearsToMaturity = bond.yearsToMaturity;
    int couponPayments = (yearsToMaturity * bond.couponFrequency).round();
    double ytmPeriodic = ytm / bond.couponFrequency;

    double convex = 0;

    for (int t = 1; t <= couponPayments; t++) {
      double pvPayment = couponPayment / pow(1 + ytmPeriodic, t);
      convex += t * (t + 1) * pvPayment;
    }

    double pvFace = faceValue / pow(1 + ytmPeriodic, couponPayments);
    convex += couponPayments * (couponPayments + 1) * pvFace;

    convex /= (price * pow(1 + ytmPeriodic, 2) * pow(bond.couponFrequency, 2));

    return convex;
  }

  /// Справедливая цена облигации при заданной доходности
  static double fairPrice(Bond bond, double desiredYtm) {
    if (bond.yearsToMaturity <= 0) {
      return bond.faceValue;
    }

    double faceValue = bond.faceValue;
    double couponPayment = faceValue * (bond.couponRate / 100) / bond.couponFrequency;
    double yearsToMaturity = bond.yearsToMaturity;
    int couponPayments = (yearsToMaturity * bond.couponFrequency).round();
    double ytmPeriodic = (desiredYtm / 100) / bond.couponFrequency;

    double pv = 0;

    for (int t = 1; t <= couponPayments; t++) {
      pv += couponPayment / pow(1 + ytmPeriodic, t);
    }

    pv += faceValue / pow(1 + ytmPeriodic, couponPayments);

    return pv;
  }

  /// Прибыль/убыток на облигации
  static BondProfitLoss calculateProfitLoss(Bond bond, double sellingPrice) {
    double costBasis = bond.currentPrice;
    double capitalGain = sellingPrice - costBasis;
    double accumulatedCoupon = bond.accrualInterest;
    double totalGain = capitalGain + accumulatedCoupon;
    double percentReturn = (totalGain / costBasis) * 100;

    return BondProfitLoss(
      capitalGain: capitalGain,
      accumulatedCoupon: accumulatedCoupon,
      totalGain: totalGain,
      percentReturn: percentReturn,
    );
  }
}

/// Результаты расчёта прибыли/убытка по облигации
class BondProfitLoss {
  final double capitalGain;        // Прибыль на росте цены
  final double accumulatedCoupon;  // Накопленные купоны
  final double totalGain;          // Общий доход
  final double percentReturn;      // Процент доходности

  BondProfitLoss({
    required this.capitalGain,
    required this.accumulatedCoupon,
    required this.totalGain,
    required this.percentReturn,
  });
}

