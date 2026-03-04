import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/portfolio.dart';
import '../services/portfolio_service.dart';

/// Экран создания нового портфеля
class CreatePortfolioScreen extends StatefulWidget {
  const CreatePortfolioScreen({super.key});

  @override
  State<CreatePortfolioScreen> createState() => _CreatePortfolioScreenState();
}

class _CreatePortfolioScreenState extends State<CreatePortfolioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  PortfolioType _selectedType = PortfolioType.balanced;
  double _bondTarget = 35;
  double _stockTarget = 50;
  double _futuresTarget = 5;
  double _cashTarget = 10;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый портфель'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название портфеля
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Название портфеля',
                  hintText: 'Например: Мой дивидендный портфель',
                  prefixIcon: const Icon(Icons.folder),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Укажите название';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Описание
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  hintText: 'Опишите цель и стратегию портфеля',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Тип портфеля
              Text(
                'Тип портфеля',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _buildPortfolioTypeButton(
                    PortfolioType.conservative,
                    'Консервативный',
                    'Доход 10-14%',
                  ),
                  _buildPortfolioTypeButton(
                    PortfolioType.balanced,
                    'Сбалансированный',
                    'Доход 15-25%',
                  ),
                  _buildPortfolioTypeButton(
                    PortfolioType.aggressive,
                    'Агрессивный',
                    'Доход 25-40%+',
                  ),
                  _buildPortfolioTypeButton(
                    PortfolioType.custom,
                    'Кастомный',
                    'Задать вручную',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Распределение активов (только для кастомного)
              if (_selectedType == PortfolioType.custom)
                _buildCustomAllocationPanel(),

              const SizedBox(height: 24),

              // Кнопки действий
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _createPortfolio,
                    icon: const Icon(Icons.add),
                    label: const Text('Создать портфель'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioTypeButton(
    PortfolioType type,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedType == type;
    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
            // Установить целевые значения в зависимости от типа
            _setDefaultAllocations(type);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAllocationPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Распределение активов (%)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            _buildSlider('Облигации', _bondTarget, (value) {
              setState(() => _bondTarget = value);
            }),
            _buildSlider('Акции', _stockTarget, (value) {
              setState(() => _stockTarget = value);
            }),
            _buildSlider('Фьючерсы', _futuresTarget, (value) {
              setState(() => _futuresTarget = value);
            }),
            _buildSlider('Кэш', _cashTarget, (value) {
              setState(() => _cashTarget = value);
            }),
            const SizedBox(height: 8),
            Text(
              'Сумма: ${(_bondTarget + _stockTarget + _futuresTarget + _cashTarget).toStringAsFixed(1)}%',
              style: TextStyle(
                color: (_bondTarget + _stockTarget + _futuresTarget + _cashTarget)
                        .toStringAsFixed(1) ==
                    '100.0'
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${value.toStringAsFixed(1)}%'),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _setDefaultAllocations(PortfolioType type) {
    switch (type) {
      case PortfolioType.conservative:
        _bondTarget = 55;
        _stockTarget = 30;
        _futuresTarget = 5;
        _cashTarget = 10;
        break;
      case PortfolioType.balanced:
        _bondTarget = 35;
        _stockTarget = 50;
        _futuresTarget = 5;
        _cashTarget = 10;
        break;
      case PortfolioType.aggressive:
        _bondTarget = 15;
        _stockTarget = 65;
        _futuresTarget = 15;
        _cashTarget = 5;
        break;
      case PortfolioType.custom:
        // Оставить как есть
        break;
    }
  }

  void _createPortfolio() {
    if (_formKey.currentState!.validate()) {
      final portfolio = Portfolio(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType,
        positions: [],
        targetBonds: _bondTarget,
        targetStocks: _stockTarget,
        targetFutures: _futuresTarget,
        targetCash: _cashTarget,
      );

      final portfolioService = context.read<PortfolioService>();
      portfolioService.addPortfolio(portfolio);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Портфель "${portfolio.name}" создан'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

