import 'dart:math';

/// Возвращает помесячную таблицу роста вклада с капитализацией
/// principal - начальная сумма
/// annualRatePercent - годовая ставка в процентах
/// months - количество месяцев
/// monthlyContribution - ежемесячный взнос (по окончании месяца)
List<Map<String, dynamic>> depositSchedule({
  required double principal,
  required double annualRatePercent,
  required int months,
  double monthlyContribution = 0.0,
}) {
  final double monthlyRate = annualRatePercent / 100.0 / 12.0;
  double balance = principal;
  double cumulativeInterest = 0.0;
  List<Map<String, dynamic>> schedule = [];

  for (int m = 1; m <= months; m++) {
    double interest = balance * monthlyRate;
    cumulativeInterest += interest;
    balance += interest + monthlyContribution;
    schedule.add({
      'month': m,
      'interest': interest,
      'contribution': monthlyContribution,
      'balance': balance,
      'cumulativeInterest': cumulativeInterest,
    });
  }

  return schedule;
}

/// Будущая стоимость при ежемесячной капитализации и регулярных взносах
/// FV = principal*(1+r)^n + monthly*( (1+r)^n - 1 )/r
double futureValueWithMonthlyContributions({
  required double principal,
  required double annualRatePercent,
  required int months,
  double monthlyContribution = 0.0,
}) {
  final double r = annualRatePercent / 100.0 / 12.0;
  if (r == 0) {
    return principal + monthlyContribution * months;
  }
  final double factor = pow(1 + r, months);
  return principal * factor + monthlyContribution * ( (factor - 1) / r );
}

/// График аннуитетного погашения кредита с дополнительными досрочными платежами
/// principal - сумма кредита
/// annualRatePercent - годовая ставка
/// months - срок в месяцах
/// extraMonthly - дополнительный ежемесячный платеж (на уменьшение основного долга)
/// Возвращает список записей: month, payment, interest, principalPayment, extraPayment, balance
List<Map<String, dynamic>> loanAmortizationSchedule({
  required double principal,
  required double annualRatePercent,
  required int months,
  double extraMonthly = 0.0,
}) {
  final double monthlyRate = annualRatePercent / 100.0 / 12.0;
  double balance = principal;
  List<Map<String, dynamic>> schedule = [];

  double payment;
  if (monthlyRate == 0) {
    payment = principal / months;
  } else {
    payment = principal * (monthlyRate) / (1 - pow(1 + monthlyRate, -months));
  }

  int month = 0;
  double totalInterest = 0.0;

  while (balance > 0.0001 && month < 1000) {
    month += 1;
    double interest = balance * monthlyRate;
    double principalPayment = payment - interest;
    if (principalPayment < 0) principalPayment = 0; // защитное

    double extra = extraMonthly;
    double totalPrincipal = principalPayment + extra;
    if (totalPrincipal > balance) {
      totalPrincipal = balance;
      // скорректировать payment в последний месяц
      payment = interest + totalPrincipal - extra;
      if (payment < 0) payment = interest + totalPrincipal;
    }

    balance -= totalPrincipal;
    totalInterest += interest;

    schedule.add({
      'month': month,
      'payment': (payment + extra),
      'interest': interest,
      'principalPayment': totalPrincipal - extra,
      'extraPayment': extra,
      'balance': max(0.0, balance),
    });

    if (month > months && monthlyRate == 0) break;
    if (month > months + 600) break; // safety
  }

  return schedule;
}

