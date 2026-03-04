import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/portfolio.dart';
import '../models/instrument.dart';
import '../models/position.dart';
import '../services/portfolio_service.dart';
import 'add_position_screen.dart';

/// Экран детального просмотра портфеля
class PortfolioDetailScreen extends StatefulWidget {
  final Portfolio portfolio;

  const PortfolioDetailScreen({
    super.key,
    required this.portfolio,
  });

  @override
  State<PortfolioDetailScreen> createState() => _PortfolioDetailScreenState();
}

class _PortfolioDetailScreenState extends State<PortfolioDetailScreen>
    with SingleTickerProviderStateMixin {
  late PortfolioService _portfolioService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _portfolioService = context.read<PortfolioService>();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = _portfolioService.getPortfolioById(widget.portfolio.id) ??
        widget.portfolio;

    return Scaffold(
      appBar: AppBar(
        title: Text(portfolio.name),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Позиции'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Анализ'),
            Tab(icon: Icon(Icons.info), text: 'Характеристики'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPositionsTab(context, portfolio),
          _buildAnalysisTab(context, portfolio),
          _buildPropertiesTab(context, portfolio),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPositionScreen(portfolio: portfolio),
            ),
          ).then((result) {
            if (result == true) {
              setState(() {});
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить позицию'),
      ),
    );
  }

  // ===== ВКЛАДКА ПОЗИЦИИ =====

  Widget _buildPositionsTab(BuildContext context, Portfolio portfolio) {
    if (portfolio.positions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Позиции не добавлены',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите кнопку ниже, чтобы добавить позицию',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: portfolio.positions.length,
      itemBuilder: (context, index) {
        return _buildPositionCard(context, portfolio.positions[index], portfolio);
      },
    );
  }

  Widget _buildPositionCard(BuildContext context, Position position, Portfolio portfolio) {
    final instrument = _portfolioService.getInstrumentById(position.instrumentId);
    if (instrument == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () {
          _showPositionDetails(context, position, instrument);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Названием и количество
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${instrument.ticker} - ${instrument.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Количество: ${position.quantity}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(_getInstrumentTypeLabel(instrument.type)),
                    backgroundColor: _getInstrumentTypeColor(instrument.type),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Цены и доход
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatInfo('Цена входа', '${position.purchasePrice}'),
                  _buildStatInfo('Текущая цена', '${position.currentPrice}'),
                  _buildStatInfo(
                    'Доход',
                    '${position.percentChange.toStringAsFixed(2)}%',
                    color: position.percentChange >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Стоимость
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatInfo('Базис', '${position.costBasis.toStringAsFixed(2)}'),
                  _buildStatInfo('Стоимость', '${position.marketValue.toStringAsFixed(2)}'),
                  _buildStatInfo(
                    'P&L',
                    '${position.profitLoss.toStringAsFixed(2)}',
                    color: position.profitLoss >= 0 ? Colors.green : Colors.red,
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
                      _deletePosition(context, portfolio.id, position.id);
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

  Widget _buildStatInfo(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  // ===== ВКЛАДКА АНАЛИЗ =====

  Widget _buildAnalysisTab(BuildContext context, Portfolio portfolio) {
    final allocation = _portfolioService.getPortfolioAllocation(portfolio);
    final exportersCount = _portfolioService.getExportersCount(portfolio);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisSection(
            'Общие показатели',
            [
              _buildMetricRow('Стоимость портфеля', '${portfolio.totalMarketValue.toStringAsFixed(2)} ₽'),
              _buildMetricRow('Базис', '${portfolio.totalCostBasis.toStringAsFixed(2)} ₽'),
              _buildMetricRow(
                'Прибыль/убыток',
                '${portfolio.totalProfitLoss.toStringAsFixed(2)} ₽',
                color: portfolio.totalProfitLoss >= 0 ? Colors.green : Colors.red,
              ),
              _buildMetricRow(
                'Доходность',
                '${portfolio.totalPercentChange.toStringAsFixed(2)}%',
                color: portfolio.totalPercentChange >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisSection(
            'Распределение по типам инструментов',
            [
              _buildAllocationBar('Облигации', allocation[InstrumentType.bond] ?? 0),
              _buildAllocationBar('Акции', allocation[InstrumentType.stock] ?? 0),
              _buildAllocationBar('Фьючерсы', allocation[InstrumentType.futures] ?? 0),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisSection(
            'Целевое распределение',
            [
              _buildAllocationBar('Облигации (цель)', portfolio.targetBonds, isTarget: true),
              _buildAllocationBar('Акции (цель)', portfolio.targetStocks, isTarget: true),
              _buildAllocationBar('Фьючерсы (цель)', portfolio.targetFutures, isTarget: true),
              _buildAllocationBar('Кэш (цель)', portfolio.targetCash, isTarget: true),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnalysisSection(
            'Стратегические характеристики',
            [
              _buildMetricRow('Экспортёров в портфеле', '$exportersCount'),
              _buildMetricRow('Дивидендная стратегия', exportersCount > 2 ? 'Активна' : 'Слабая'),
              _buildMetricRow('Валютный хедж', exportersCount > 0 ? 'Присутствует' : 'Отсутствует'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationBar(String label, double percent, {bool isTarget = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${percent.toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isTarget ? Colors.orange : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== ВКЛАДКА ХАРАКТЕРИСТИКИ =====

  Widget _buildPropertiesTab(BuildContext context, Portfolio portfolio) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPropertyCard(
            'Основная информация',
            [
              _buildPropertyRow('Название', portfolio.name),
              _buildPropertyRow('Описание', portfolio.description),
              _buildPropertyRow('Тип', _getPortfolioTypeLabel(portfolio.type)),
              _buildPropertyRow('Позиций', '${portfolio.positionCount}'),
            ],
          ),
          const SizedBox(height: 16),
          _buildPropertyCard(
            'Даты',
            [
              _buildPropertyRow(
                'Создан',
                portfolio.createdDate.toLocal().toString().split('.')[0],
              ),
              _buildPropertyRow(
                'Изменён',
                portfolio.lastModified.toLocal().toString().split('.')[0],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPropertyCard(
            'Целевые распределения',
            [
              _buildPropertyRow('Облигации', '${portfolio.targetBonds}%'),
              _buildPropertyRow('Акции', '${portfolio.targetStocks}%'),
              _buildPropertyRow('Фьючерсы', '${portfolio.targetFutures}%'),
              _buildPropertyRow('Кэш', '${portfolio.targetCash}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ===== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ =====

  String _getInstrumentTypeLabel(InstrumentType type) {
    switch (type) {
      case InstrumentType.bond:
        return 'Облигация';
      case InstrumentType.stock:
        return 'Акция';
      case InstrumentType.futures:
        return 'Фьючерс';
    }
  }

  Color _getInstrumentTypeColor(InstrumentType type) {
    switch (type) {
      case InstrumentType.bond:
        return Colors.blue;
      case InstrumentType.stock:
        return Colors.green;
      case InstrumentType.futures:
        return Colors.purple;
    }
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

  void _showPositionDetails(BuildContext context, Position position, Instrument instrument) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${instrument.ticker} - ${instrument.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Тип', _getInstrumentTypeLabel(instrument.type)),
              _buildDetailRow('Количество', '${position.quantity}'),
              _buildDetailRow('Цена входа', '${position.purchasePrice}'),
              _buildDetailRow('Текущая цена', '${position.currentPrice}'),
              _buildDetailRow('Дата покупки', position.purchaseDate.toLocal().toString().split(' ')[0]),
              _buildDetailRow('Базис', '${position.costBasis.toStringAsFixed(2)} ₽'),
              _buildDetailRow('Стоимость', '${position.marketValue.toStringAsFixed(2)} ₽'),
              _buildDetailRow('P&L', '${position.profitLoss.toStringAsFixed(2)} ₽'),
              _buildDetailRow('Доходность', '${position.percentChange.toStringAsFixed(2)}%'),
              _buildDetailRow('Дней в портфеле', '${position.daysSincePurchase}'),
              if (position.notes.isNotEmpty)
                _buildDetailRow('Примечания', position.notes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _deletePosition(BuildContext context, String portfolioId, String positionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить позицию?'),
        content: const Text('Это действие невозможно отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _portfolioService.removePositionFromPortfolio(portfolioId, positionId);
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

