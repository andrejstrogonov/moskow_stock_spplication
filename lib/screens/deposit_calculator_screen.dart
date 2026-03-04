import 'package:flutter/material.dart';
import '../utils/financial_calculators.dart';

class DepositCalculatorScreen extends StatefulWidget {
  const DepositCalculatorScreen({super.key});

  @override
  State<DepositCalculatorScreen> createState() => _DepositCalculatorScreenState();
}

class _DepositCalculatorScreenState extends State<DepositCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _principalController = TextEditingController(text: '100000');
  final TextEditingController _annualController = TextEditingController(text: '6');
  final TextEditingController _monthsController = TextEditingController(text: '12');
  final TextEditingController _monthlyContributionController = TextEditingController(text: '0');
  final TextEditingController _expectedInvestmentReturnController = TextEditingController(text: '14');

  List<Map<String, dynamic>>? _schedule;
  double? _fv;
  double? _fvInvest;
  String? _compareRecommendation;

  @override
  void dispose() {
    _principalController.dispose();
    _annualController.dispose();
    _monthsController.dispose();
    _monthlyContributionController.dispose();
    _expectedInvestmentReturnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Калькулятор вкладов')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _principalController,
                    decoration: const InputDecoration(labelText: 'Начальная сумма (₽)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Введите сумму' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _annualController,
                    decoration: const InputDecoration(labelText: 'Годовая ставка, %'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Введите ставку' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _monthsController,
                    decoration: const InputDecoration(labelText: 'Срок (месяцев)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Введите срок' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _monthlyContributionController,
                    decoration: const InputDecoration(labelText: 'Ежемесячный взнос (₽)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final principal = double.parse(_principalController.text.replaceAll(',', '.'));
                        final annual = double.parse(_annualController.text.replaceAll(',', '.'));
                        final months = int.parse(_monthsController.text);
                        final monthly = double.parse(_monthlyContributionController.text.replaceAll(',', '.'));

                        final schedule = depositSchedule(principal: principal, annualRatePercent: annual, months: months, monthlyContribution: monthly);
                        final fv = futureValueWithMonthlyContributions(principal: principal, annualRatePercent: annual, months: months, monthlyContribution: monthly);

                        setState(() {
                          _schedule = schedule;
                          _fv = fv;
                          _fvInvest = null;
                          _compareRecommendation = null;
                        });
                      }
                    },
                    child: const Text('Рассчитать'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _expectedInvestmentReturnController,
                    decoration: const InputDecoration(labelText: 'Ожидаемая доходность инвестиций, %'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _fv == null
                        ? null
                        : () {
                            final expected = double.parse(_expectedInvestmentReturnController.text.replaceAll(',', '.'));
                            final months = int.parse(_monthsController.text);
                            final monthly = double.parse(_monthlyContributionController.text.replaceAll(',', '.'));
                            final principal = double.parse(_principalController.text.replaceAll(',', '.'));
                            final fvInvest = futureValueWithMonthlyContributions(principal: principal, annualRatePercent: expected, months: months, monthlyContribution: monthly);
                            String rec;
                            if (fvInvest > _fv!) {
                              rec = 'Ожидаемая инвестиционная стратегия даёт большую сумму (${fvInvest.toStringAsFixed(0)} ₽) по сравнению с вкладом (${_fv!.toStringAsFixed(0)} ₽). Рассмотрите инвестиции при приемлемом уровне риска.';
                            } else {
                              rec = 'Вклад даёт большую или равную сумму. Для инвестиций нужна более высокая ожидаемая доходность или больший горизонт.';
                            }
                            setState(() {
                              _fvInvest = fvInvest;
                              _compareRecommendation = rec;
                            });
                          },
                    child: const Text('Сравнить с инвестицией'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_fv != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Будущая стоимость: ${_fv!.toStringAsFixed(2)} ₽', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('График по месяцам:'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: ListView(
                          children: _schedule!.map((row) => ListTile(
                            title: Text('Месяц ${row['month']}'),
                            subtitle: Text('Платёж: ${row['contribution']}, Проценты: ${row['interest'].toStringAsFixed(2)}, Баланс: ${row['balance'].toStringAsFixed(2)}'),
                          )).toList(),
                        ),
                      ),
                      if (_fvInvest != null) ...[
                        const SizedBox(height: 12),
                        Text('Инвестиционная FV: ${_fvInvest!.toStringAsFixed(2)} ₽', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(_compareRecommendation ?? ''),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

