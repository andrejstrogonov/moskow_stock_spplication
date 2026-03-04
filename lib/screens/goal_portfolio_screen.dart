import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/portfolio_service.dart';
import '../models/portfolio.dart';

class GoalPortfolioScreen extends StatefulWidget {
  const GoalPortfolioScreen({super.key});

  @override
  State<GoalPortfolioScreen> createState() => _GoalPortfolioScreenState();
}

class _GoalPortfolioScreenState extends State<GoalPortfolioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _capitalController = TextEditingController(text: '100000');
  final TextEditingController _targetController = TextEditingController(text: '18');
  final TextEditingController _yearsController = TextEditingController(text: '3');
  String _risk = 'medium';

  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _capitalController.dispose();
    _targetController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.read<PortfolioService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Построить портфель по цели'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _capitalController,
                    decoration: const InputDecoration(labelText: 'Сумма, ₽'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Укажите сумму';
                      final val = double.tryParse(v.replaceAll(',', '.'));
                      if (val == null || val <= 0) return 'Некорректная сумма';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _targetController,
                    decoration: const InputDecoration(labelText: 'Целевая годовая доходность, %'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Укажите целевой процент';
                      final val = double.tryParse(v.replaceAll(',', '.'));
                      if (val == null || val <= 0) return 'Некорректный процент';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _yearsController,
                    decoration: const InputDecoration(labelText: 'Горизонт, лет'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Укажите горизонт';
                      final val = int.tryParse(v);
                      if (val == null || val <= 0) return 'Некорректный горизонт';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _risk,
                    decoration: const InputDecoration(labelText: 'Профиль риска'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Низкий')),
                      DropdownMenuItem(value: 'medium', child: Text('Средний')),
                      DropdownMenuItem(value: 'high', child: Text('Высокий')),
                    ],
                    onChanged: (v) => setState(() => _risk = v ?? 'medium'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final capital = double.parse(_capitalController.text.replaceAll(',', '.'));
                            final target = double.parse(_targetController.text.replaceAll(',', '.'));
                            final years = int.parse(_yearsController.text);
                            final res = svc.generatePortfolioForGoal(
                              capital: capital,
                              targetAnnualReturnPercent: target,
                              years: years,
                              riskLevel: _risk,
                            );
                            setState(() {
                              _result = res;
                            });
                          }
                        },
                        child: const Text('Сгенерировать'),
                      ),
                      const SizedBox(width: 12),
                      if (_result != null)
                        ElevatedButton(
                          onPressed: () {
                            final Portfolio p = _result!['portfolio'];
                            svc.addPortfolio(p);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Портфель добавлен')));
                            Navigator.pop(context);
                          },
                          child: const Text('Добавить в портфели'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_result != null) _buildResultCard(_result!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> res) {
    final port = res['portfolio'] as Portfolio;
    final expected = res['expectedReturn'] as double;
    final achievable = res['achievable'] as bool;
    final rec = res['recommendation'] as String;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(port.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Ожидаемая доходность: ${expected.toStringAsFixed(2)}%'),
            const SizedBox(height: 6),
            Text('Достижимо: ${achievable ? 'Да' : 'Нет'}'),
            const SizedBox(height: 6),
            Text('Рекомендация:'),
            Text(rec),
            const SizedBox(height: 10),
            const Text('Состав портфеля:'),
            const SizedBox(height: 6),
            ...port.positions.map((p) => ListTile(
                  title: Text(p.instrumentId),
                  subtitle: Text('Количество: ${p.quantity} × ${p.purchasePrice} ₽'),
                )),
          ],
        ),
      ),
    );
  }
}

