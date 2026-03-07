import 'package:flutter/material.dart';
import '../utils/financial_calculators.dart';

class FamilyBudgetPlanningScreen extends StatefulWidget {
  const FamilyBudgetPlanningScreen({super.key});

  @override
  State<FamilyBudgetPlanningScreen> createState() => _FamilyBudgetPlanningScreenState();
}

class _FamilyBudgetPlanningScreenState extends State<FamilyBudgetPlanningScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _familyMembersController = TextEditingController(text: '4');
  final TextEditingController _monthlyIncomeController = TextEditingController(text: '150000');
  final TextEditingController _monthlyExpensesController = TextEditingController(text: '120000');
  final TextEditingController _savingsGoalController = TextEditingController(text: '5000000');
  final TextEditingController _timeHorizonController = TextEditingController(text: '60'); // months
  final TextEditingController _currentSavingsController = TextEditingController(text: '100000');
  final TextEditingController _expectedInvestmentReturnController = TextEditingController(text: '14');
  final TextEditingController _loanInterestController = TextEditingController(text: '12');

  String? _recommendation;

  @override
  void dispose() {
    _familyMembersController.dispose();
    _monthlyIncomeController.dispose();
    _monthlyExpensesController.dispose();
    _savingsGoalController.dispose();
    _timeHorizonController.dispose();
    _currentSavingsController.dispose();
    _expectedInvestmentReturnController.dispose();
    _loanInterestController.dispose();
    super.dispose();
  }

  void _calculateRecommendation() {
    if (!_formKey.currentState!.validate()) return;

    final monthlyIncome = double.parse(_monthlyIncomeController.text);
    final monthlyExpenses = double.parse(_monthlyExpensesController.text);
    final savingsGoal = double.parse(_savingsGoalController.text);
    final timeHorizon = int.parse(_timeHorizonController.text);
    final currentSavings = double.parse(_currentSavingsController.text);
    final expectedReturn = double.parse(_expectedInvestmentReturnController.text);
    final loanInterest = double.parse(_loanInterestController.text);

    final monthlySurplus = monthlyIncome - monthlyExpenses;
    final totalNeeded = savingsGoal - currentSavings;

    // Рассчитать FV вклада (предположим ставка 6%)
    final depositFV = futureValueWithMonthlyContributions(
      principal: currentSavings,
      annualRatePercent: 6.0,
      months: timeHorizon,
      monthlyContribution: monthlySurplus,
    );

    // Рассчитать FV инвестиций
    final investFV = futureValueWithMonthlyContributions(
      principal: currentSavings,
      annualRatePercent: expectedReturn,
      months: timeHorizon,
      monthlyContribution: monthlySurplus,
    );

    // Для кредита: сколько нужно занять
    final shortfall = totalNeeded - investFV;
    if (shortfall > 0) {
      // Рассчитать платеж по кредиту
      final loanSchedule = loanAmortizationSchedule(
        principal: shortfall,
        annualRatePercent: loanInterest,
        months: timeHorizon,
      );
      final monthlyLoanPayment = loanSchedule.isNotEmpty ? loanSchedule.first['payment'] as double : 0;

      if (monthlyLoanPayment < monthlySurplus) {
        _recommendation = 'Рекомендуется взять кредит на ${shortfall.toStringAsFixed(0)} ₽ для достижения цели. Ежемесячный платеж: ${monthlyLoanPayment.toStringAsFixed(0)} ₽. Инвестиции дадут ${investFV.toStringAsFixed(0)} ₽, вклад - ${depositFV.toStringAsFixed(0)} ₽.';
      } else {
        _recommendation = 'Кредит не рекомендуется, так как платеж (${monthlyLoanPayment.toStringAsFixed(0)} ₽) превышает месячный излишек (${monthlySurplus.toStringAsFixed(0)} ₽). Рассмотрите инвестиции для роста капитала.';
      }
    } else {
      if (investFV >= savingsGoal) {
        _recommendation = 'Инвестиции позволят достичь цели (${investFV.toStringAsFixed(0)} ₽ > ${savingsGoal.toStringAsFixed(0)} ₽). Вклад даст ${depositFV.toStringAsFixed(0)} ₽.';
      } else {
        _recommendation = 'Вклад безопаснее для сохранения средств. Инвестиции могут не достичь цели (${investFV.toStringAsFixed(0)} ₽ < ${savingsGoal.toStringAsFixed(0)} ₽).';
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Планирование семейного бюджета')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _familyMembersController,
                decoration: const InputDecoration(labelText: 'Количество членов семьи'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Введите количество' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _monthlyIncomeController,
                decoration: const InputDecoration(labelText: 'Месячный доход семьи (₽)'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Введите доход' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _monthlyExpensesController,
                decoration: const InputDecoration(labelText: 'Месячные расходы семьи (₽)'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Введите расходы' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentSavingsController,
                decoration: const InputDecoration(labelText: 'Текущие сбережения (₽)'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Введите сбережения' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _savingsGoalController,
                decoration: const InputDecoration(labelText: 'Целевая сумма сбережений (₽)'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Введите цель' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _timeHorizonController,
                decoration: const InputDecoration(labelText: 'Срок достижения цели (месяцев)'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Введите срок' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expectedInvestmentReturnController,
                decoration: const InputDecoration(labelText: 'Ожидаемая доходность инвестиций (%)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _loanInterestController,
                decoration: const InputDecoration(labelText: 'Ставка по кредиту (%)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateRecommendation,
                child: const Text('Рассчитать и рекомендовать'),
              ),
              const SizedBox(height: 20),
              if (_recommendation != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_recommendation!, style: const TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
