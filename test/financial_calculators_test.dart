import 'package:flutter_test/flutter_test.dart';
import 'package:moskow_stock_spplication/utils/financial_calculators.dart';

void main() {
  group('Deposit calculator', () {
    test('futureValueWithMonthlyContributions simple', () {
      final fv = futureValueWithMonthlyContributions(principal: 100000, annualRatePercent: 12, months: 12, monthlyContribution: 0);
      // Approx 100000 * (1+0.01)^12 = 100000 * 1.126825 = 112682.5
      expect(fv, greaterThan(112000));
      expect(fv, lessThan(113000));
    });

    test('depositSchedule length', () {
      final schedule = depositSchedule(principal: 1000, annualRatePercent: 6, months: 6, monthlyContribution: 10);
      expect(schedule.length, 6);
      expect(schedule.first['month'], 1);
      expect(schedule.last['month'], 6);
    });
  });

  group('Loan amortization', () {
    test('loan amortization decreases balance', () {
      final schedule = loanAmortizationSchedule(principal: 1200, annualRatePercent: 12, months: 12, extraMonthly: 0);
      expect(schedule.isNotEmpty, true);
      expect(schedule.first['balance'] as double, lessThan(1200));
      expect(schedule.last['balance'], 0);
    });
  });
}

