import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/portfolio.dart';
import '../services/portfolio_service.dart';
import 'portfolio_detail_screen.dart';
import 'create_portfolio_screen.dart';
import 'goal_portfolio_screen.dart';
import 'deposit_calculator_screen.dart';
import 'loan_calculator_screen.dart';

/// Главный экран приложения со списком портфелей
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PortfolioService _portfolioService;

  @override
  void initState() {
    super.initState();
    _portfolioService = context.read<PortfolioService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Портфельный конструктор Мосбиржи'),
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Портфелей: ${_portfolioService.getPortfolios().length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreatePortfolioScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Новый портфель'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            backgroundColor: Colors.teal,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GoalPortfolioScreen(),
                ),
              );
            },
            icon: const Icon(Icons.track_changes),
            label: const Text('По цели'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DepositCalculatorScreen(),
                ),
              );
            },
            icon: const Icon(Icons.savings),
            label: const Text('Вклад'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            backgroundColor: Colors.brown,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoanCalculatorScreen(),
                ),
              );
            },
            icon: const Icon(Icons.account_balance),
            label: const Text('Кредит'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final portfolios = _portfolioService.getPortfolios();

    if (portfolios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Портфелей не найдено',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите кнопку внизу, чтобы создать портфель',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: portfolios.length,
      itemBuilder: (context, index) {
        return _buildPortfolioCard(context, portfolios[index]);
      },
    );
  }

  Widget _buildPortfolioCard(BuildContext context, Portfolio portfolio) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PortfolioDetailScreen(portfolio: portfolio),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и тип портфеля
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          portfolio.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          portfolio.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(_getPortfolioTypeLabel(portfolio.type)),
                    backgroundColor: _getPortfolioTypeColor(portfolio.type),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Статистика портфеля
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatColumn(
                    'Стоимость',
                    '${portfolio.totalMarketValue.toStringAsFixed(2)} ₽',
                    context,
                  ),
                  _buildStatColumn(
                    'Позиций',
                    '${portfolio.positionCount}',
                    context,
                  ),
                  _buildStatColumn(
                    'Доход',
                    '${portfolio.totalPercentChange.toStringAsFixed(2)}%',
                    context,
                    textColor: portfolio.totalPercentChange >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                  _buildStatColumn(
                    'Сумма',
                    '${portfolio.totalProfitLoss.toStringAsFixed(2)} ₽',
                    context,
                    textColor: portfolio.totalProfitLoss >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Кнопки действий
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _deletePortfolio(context, portfolio.id);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Удалить'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, BuildContext context,
      {Color? textColor}) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _getPortfolioTypeLabel(PortfolioType type) {
    switch (type) {
      case PortfolioType.conservative:
        return 'Консервативный';
      case PortfolioType.balanced:
        return 'Сбалансированный';
      case PortfolioType.aggressive:
        return 'Агрессивный';
      case PortfolioType.custom:
        return 'Кастомный';
    }
  }

  Color _getPortfolioTypeColor(PortfolioType type) {
    switch (type) {
      case PortfolioType.conservative:
        return Colors.blue;
      case PortfolioType.balanced:
        return Colors.orange;
      case PortfolioType.aggressive:
        return Colors.red;
      case PortfolioType.custom:
        return Colors.purple;
    }
  }

  void _deletePortfolio(BuildContext context, String portfolioId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить портфель?'),
        content: const Text('Это действие невозможно отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _portfolioService.deletePortfolio(portfolioId);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

