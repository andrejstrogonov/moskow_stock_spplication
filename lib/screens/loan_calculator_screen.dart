import 'package:flutter/material.dart';
import '../utils/financial_calculators.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _principalController = TextEditingController(text: '1000000');
  final TextEditingController _annualController = TextEditingController(text: '12');
  final TextEditingController _monthsController = TextEditingController(text: '60');
  final TextEditingController _extraController = TextEditingController(text: '0');
  final TextEditingController _expectedInvestmentReturnController = TextEditingController(text: '14');

  List<Map<String, dynamic>>? _schedule;
  double? _investFV;
  String? _loanCompareRec;

  @override
  void dispose() {
    _principalController.dispose();
    _annualController.dispose();
    _monthsController.dispose();
    _extraController.dispose();
    _expectedInvestmentReturnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кредитный калькулятор')),
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
                    decoration: const InputDecoration(labelText: 'Сумма кредита (₽)'),
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
                    decoration: const InputDecoration(labelText: 'Срок, месяцев'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty) ? 'Введите срок' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _extraController,
                    decoration: const InputDecoration(labelText: 'Досрочный ежемесячный платёж (₽)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final principal = double.parse(_principalController.text.replaceAll(',', '.'));
                        final annual = double.parse(_annualController.text.replaceAll(',', '.'));
                        final months = int.parse(_monthsController.text);
                        final extra = double.parse(_extraController.text.replaceAll(',', '.'));

                        final schedule = loanAmortizationSchedule(principal: principal, annualRatePercent: annual, months: months, extraMonthly: extra);
                        setState(() {
                          _schedule = schedule;
                          _investFV = null;
                          _loanCompareRec = null;
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
                    onPressed: _schedule == null
                        ? null
                        : () {
                            final extra = double.parse(_extraController.text.replaceAll(',', '.'));
                            final expected = double.parse(_expectedInvestmentReturnController.text.replaceAll(',', '.'));
                            // посчитаем FV если ежемесячно инвестировать сумму extra на тот же срок, используя months from schedule last
                            final months = _schedule!.length;
                            final principal = 0.0;
                            final fvInvest = futureValueWithMonthlyContributions(principal: principal, annualRatePercent: expected, months: months, monthlyContribution: extra);
                            String rec;
                            // сравниваем экономию по процентам при досрочном погашении: суммарные проценты кредита
                            double totalInterest = 0;
                            for (var row in _schedule!) totalInterest += (row['interest'] as double);
                            // если инвестирование принесёт больше, чем экономия на процентах → инвестировать
                            if (fvInvest > totalInterest) {
                              rec = 'Инвестирование ежемесячной суммы ${extra.toStringAsFixed(0)} ₽ с ожидаемой доходностью ${expected.toStringAsFixed(1)}% может дать ${fvInvest.toStringAsFixed(0)} ₽, что больше экономии на процентах по кредиту (~${totalInterest.toStringAsFixed(0)} ₽). Рассмотрите инвестирование вместо досрочных платежей.';
                            } else {
                              rec = 'Досрочное погашение даёт большую экономию на процентах (~${totalInterest.toStringAsFixed(0)} ₽), чем потенциальный доход от инвестиций. Рекомендуется досрочное погашение.';
                            }
                            setState(() {
                              _investFV = fvInvest;
                              _loanCompareRec = rec;
                            });
                          },
                    child: const Text('Сравнить досрочное погашение vs инвестирование'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_schedule != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('График платежей:'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: ListView(
                          children: _schedule!.map((row) => ListTile(
                            title: Text('Месяц ${row['month']}'),
                            subtitle: Text('Платёж: ${row['payment'].toStringAsFixed(2)} (проценты: ${row['interest'].toStringAsFixed(2)}, основная: ${row['principalPayment'].toStringAsFixed(2)}), Остаток: ${row['balance'].toStringAsFixed(2)}'),
                          )).toList(),
                        ),
                      ),
                      if (_investFV != null) ...[
                        const SizedBox(height: 12),
                        Text('Инвестированная сумма даст примерно: ${_investFV!.toStringAsFixed(2)} ₽', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(_loanCompareRec ?? ''),
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

