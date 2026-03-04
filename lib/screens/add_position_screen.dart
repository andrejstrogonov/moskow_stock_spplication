import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/instrument.dart';
import '../models/portfolio.dart';
import '../services/portfolio_service.dart';
import 'instrument_details_screen.dart';

/// Экран добавления позиции в портфель
class AddPositionScreen extends StatefulWidget {
  final Portfolio portfolio;

  const AddPositionScreen({
    super.key,
    required this.portfolio,
  });

  @override
  State<AddPositionScreen> createState() => _AddPositionScreenState();
}

class _AddPositionScreenState extends State<AddPositionScreen>
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить позицию'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.savings), text: 'Облигации'),
            Tab(icon: Icon(Icons.trending_up), text: 'Акции'),
            Tab(icon: Icon(Icons.show_chart), text: 'Фьючерсы'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInstrumentList(InstrumentType.bond),
          _buildInstrumentList(InstrumentType.stock),
          _buildInstrumentList(InstrumentType.futures),
        ],
      ),
    );
  }

  Widget _buildInstrumentList(InstrumentType type) {
    final instruments = _portfolioService.getInstruments(type: type);

    if (instruments.isEmpty) {
      return Center(
        child: Text('Инструментов типа ${_getTypeLabel(type)} не найдено'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: instruments.length,
      itemBuilder: (context, index) {
        return _buildInstrumentCard(context, instruments[index]);
      },
    );
  }

  Widget _buildInstrumentCard(BuildContext context, Instrument instrument) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstrumentDetailsScreen(
                instrument: instrument,
                portfolio: widget.portfolio,
                onPositionAdded: () {
                  Navigator.pop(context, true);
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название и цена
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
                          instrument.type == InstrumentType.bond && instrument is Bond
                              ? 'Купон: ${(instrument).couponRate}% | Дюрация: ${(instrument).yearsToMaturity.toStringAsFixed(2)} лет'
                              : instrument.type == InstrumentType.stock && instrument is Stock
                                  ? 'Дивиденд: ${(instrument).dividendYield}% | P/E: ${(instrument).pe.toStringAsFixed(1)}'
                                  : 'Volatility: ${(instrument as Futures).volatility}% | Role: ${_getRoleLabel((instrument).role)}',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${instrument.currentPrice} ₽',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InstrumentDetailsScreen(
                                instrument: instrument,
                                portfolio: widget.portfolio,
                                onPositionAdded: () {
                                  Navigator.pop(context, true);
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Выбрать'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(InstrumentType type) {
    switch (type) {
      case InstrumentType.bond:
        return 'Облигаций';
      case InstrumentType.stock:
        return 'Акций';
      case InstrumentType.futures:
        return 'Фьючерсов';
    }
  }

  String _getRoleLabel(FuturesRole role) {
    switch (role) {
      case FuturesRole.hedger:
        return 'Хеджер';
      case FuturesRole.speculator:
        return 'Спекулянт';
      case FuturesRole.arbitrageur:
        return 'Арбитражер';
    }
  }
}

