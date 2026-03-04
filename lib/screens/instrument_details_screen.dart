import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/instrument.dart';
import '../models/portfolio.dart';
import '../models/position.dart';
import '../services/portfolio_service.dart';
import '../utils/bond_calculator.dart';
import '../utils/stock_analyzer.dart';
import '../utils/black_scholes_calculator.dart';

/// Экран деталей инструмента с расчётами
class InstrumentDetailsScreen extends StatefulWidget {
  final Instrument instrument;
  final Portfolio portfolio;
  final VoidCallback onPositionAdded;

  const InstrumentDetailsScreen({
    super.key,
    required this.instrument,
    required this.portfolio,
    required this.onPositionAdded,
  });

  @override
  State<InstrumentDetailsScreen> createState() =>
      _InstrumentDetailsScreenState();
}

class _InstrumentDetailsScreenState extends State<InstrumentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  late PortfolioService _portfolioService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _portfolioService = context.read<PortfolioService>();
    _priceController.text = widget.instrument.currentPrice.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.instrument.ticker} - ${widget.instrument.name}'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Характеристики'),
            Tab(text: 'Добавить позицию'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCharacteristicsTab(),
          _buildAddPositionTab(),
        ],
      ),
    );
  }

  // ===== ВКЛАДКА ХАРАКТЕРИСТИКИ =====

  Widget _buildCharacteristicsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.instrument is Bond)
            _buildBondCharacteristics(widget.instrument as Bond)
          else if (widget.instrument is Stock)
            _buildStockCharacteristics(widget.instrument as Stock)
          else if (widget.instrument is Futures)
            _buildFuturesCharacteristics(widget.instrument as Futures),
        ],
      ),
    );
  }

  Widget _buildBondCharacteristics(Bond bond) {
    final ytm = BondCalculator.yieldToMaturity(bond);
    final currentYield = BondCalculator.currentYield(bond);
    final duration = BondCalculator.modifiedDuration(bond);
    final convexity = BondCalculator.convexity(bond);

    return Column(
      children: [
        _buildInfoCard(
          'Основная информация',
          [
            _buildInfoRow('Номинал', '${bond.faceValue} ₽'),
            _buildInfoRow('Текущая цена', '${bond.currentPrice} ₽'),
            _buildInfoRow('Купон', '${bond.couponRate}%'),
            _buildInfoRow('Частота купонов', '${bond.couponFrequency} раз/год'),
            _buildInfoRow('Тип', bond.isOFZ ? 'ОФЗ (государственная)' : 'Корпоративная'),
            if (bond.issuer != null) _buildInfoRow('Эмитент', bond.issuer!),
            if (bond.rating != null) _buildInfoRow('Рейтинг', '${bond.rating}'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Сроки и доходности',
          [
            _buildInfoRow('До погашения', '${bond.yearsToMaturity.toStringAsFixed(2)} лет (${bond.daysToMaturity} дней)'),
            _buildInfoRow('YTM (доходность)', '${ytm.toStringAsFixed(2)}%', highlight: true),
            _buildInfoRow('Текущая доходность', '${currentYield.toStringAsFixed(2)}%'),
            _buildInfoRow('Накопленный процент', '${bond.accrualInterest.toStringAsFixed(2)} ₽'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Риск и дюрация',
          [
            _buildInfoRow('Модифицированная дюрация', '${duration.toStringAsFixed(2)} лет'),
            _buildInfoRow('Выпуклость', '${convexity.toStringAsFixed(4)}'),
            _buildInfoRow('Влияние ставок', 'Высокое - долгосрочный инструмент'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Справедливая стоимость при разных доходностях',
          [
            _buildFairPriceScenario(bond, 5.0, 'Бычий сценарий (ставка 5%)'),
            _buildFairPriceScenario(bond, 8.0, 'Базовый сценарий (ставка 8%)'),
            _buildFairPriceScenario(bond, 10.0, 'Медвежий сценарий (ставка 10%)'),
          ],
        ),
      ],
    );
  }

  Widget _buildFairPriceScenario(Bond bond, double ytm, String label) {
    final fairPrice = BondCalculator.fairPrice(bond, ytm);
    final change = ((fairPrice - bond.currentPrice) / bond.currentPrice) * 100;
    return _buildInfoRow(
      label,
      '${fairPrice.toStringAsFixed(2)} ₽ (${change > 0 ? '+' : ''}${change.toStringAsFixed(2)}%)',
      color: change > 0 ? Colors.green : change < 0 ? Colors.red : Colors.grey,
    );
  }

  Widget _buildStockCharacteristics(Stock stock) {
    final valuation = StockAnalyzer.analyzeValuation(stock);
    final dividend = StockAnalyzer.analyzeDividend(stock);

    return Column(
      children: [
        _buildInfoCard(
          'Основная информация',
          [
            _buildInfoRow('Компания', stock.companyName ?? 'N/A'),
            _buildInfoRow('Текущая цена', '${stock.currentPrice} ₽'),
            _buildInfoRow('Сектор', _getSectorLabel(stock.sector)),
            _buildInfoRow('Тип', stock.isExporter ? 'Экспортёр (валютный хедж)' : 'Локальный'),
            _buildInfoRow('Капитализация', '${stock.marketCap.toStringAsFixed(1)} млрд ₽'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Показатели компании',
          [
            _buildInfoRow('Прибыль на акцию (EPS)', '${stock.eps.toStringAsFixed(2)} ₽'),
            _buildInfoRow('P/E коэффициент', '${stock.pe.toStringAsFixed(2)}',
              highlight: true,
              color: _getValuationColor(valuation.status),
            ),
            _buildInfoRow('ROE (рентабельность)', '${stock.roe.toStringAsFixed(2)}%'),
            _buildInfoRow('Статус оценки', _getValuationStatusLabel(valuation.status),
              color: _getValuationColor(valuation.status),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Дивидендные показатели',
          [
            _buildInfoRow('Дивидендная доходность', '${dividend.dividendYield.toStringAsFixed(2)}%', highlight: true),
            _buildInfoRow('Payout ratio', '${dividend.payoutRatio.toStringAsFixed(1)}%'),
            _buildInfoRow('Устойчивость', _getSustainabilityLabel(dividend.sustainability),
              color: _getSustainabilityColor(dividend.sustainability),
            ),
            _buildInfoRow('Рекомендация', dividend.recommendation),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Анализ риска',
          [
            _buildInfoRow('Уровень риска', _getRiskLevelLabel(valuation.riskLevel),
              color: _getRiskLevelColor(valuation.riskLevel),
            ),
            _buildInfoRow('Потенциал роста', '${StockAnalyzer.growthPotential(stock, targetPE: 15, expectedDividendGrowth: 5).toStringAsFixed(2)}% (при P/E=15, рост дивидендов 5%)',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFuturesCharacteristics(Futures futures) {
    final fairPrice = BlackScholesCalculator.fairFuturesPrice(futures);
    final fairness = ((futures.currentPrice - fairPrice) / fairPrice) * 100;

    return Column(
      children: [
        _buildInfoCard(
          'Основная информация',
          [
            _buildInfoRow('Базовый актив', futures.underlyingAsset),
            _buildInfoRow('Текущая цена', '${futures.currentPrice} ₽'),
            _buildInfoRow('Спот-цена', '${futures.spotPrice} ₽'),
            _buildInfoRow('Множитель контракта', '${futures.multiplier}'),
            _buildInfoRow('До экспирации', '${futures.yearsToExpiration.toStringAsFixed(3)} лет (${futures.daysToExpiration} дней)'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Параметры модели Блека-Шоулза',
          [
            _buildInfoRow('Справедливая цена', '${fairPrice.toStringAsFixed(2)} ₽', highlight: true),
            _buildInfoRow('Справедливость', fairness > 2 ? 'Переоценен' : fairness < -2 ? 'Недооценен' : 'Справедливо',
              color: fairness > 2 ? Colors.red : fairness < -2 ? Colors.green : Colors.grey,
            ),
            _buildInfoRow('Разница (%)', '${fairness.toStringAsFixed(2)}%'),
            _buildInfoRow('Волатильность', '${futures.volatility.toStringAsFixed(2)}%'),
            _buildInfoRow('Безрисковая ставка', '${futures.riskFreeRate.toStringAsFixed(2)}%'),
          ],
        ),
        const SizedBox(height: 16),
        _buildRoleAnalysis(futures),
      ],
    );
  }

  Widget _buildRoleAnalysis(Futures futures) {
    if (futures.role == FuturesRole.hedger) {
      final hedgerAnalysis = BlackScholesCalculator.analyzeForHedger(
        futures,
        spotPrice: futures.spotPrice ?? futures.currentPrice,
        targetPrice: futures.currentPrice,
        contractsToHedge: 1,
      );
      return _buildInfoCard(
        'Анализ для Хеджера',
        [
          _buildInfoRow('Рекомендация', hedgerAnalysis.recommendation,
            color: Colors.blue,
          ),
          _buildInfoRow('Хедж рацион', '${hedgerAnalysis.hedgeRatio} контрактов'),
          _buildInfoRow('Стоимость хеджирования', '${hedgerAnalysis.hedgeCost.toStringAsFixed(2)} ₽'),
          _buildInfoRow('Защита на 1%', '${hedgerAnalysis.protectionPer1Percent.toStringAsFixed(2)} ₽'),
        ],
      );
    } else if (futures.role == FuturesRole.speculator) {
      final speculatorAnalysis = BlackScholesCalculator.analyzeForSpeculator(
        futures,
        initialCapital: 100000,
        leverage: 2,
        volatility: futures.volatility,
      );
      return _buildInfoCard(
        'Анализ для Спекулянта',
        [
          _buildInfoRow('Рекомендация', speculatorAnalysis.recommendation),
          _buildInfoRow('Контрактов с рычагом', '${speculatorAnalysis.contractsWithLeverage}'),
          _buildInfoRow('Маржа', '${speculatorAnalysis.marginRequired.toStringAsFixed(2)} ₽'),
          _buildInfoRow('Макс убыток', '${speculatorAnalysis.maxLoss.toStringAsFixed(2)} ₽'),
          _buildInfoRow('Риск/Награда', '${speculatorAnalysis.riskReward.toStringAsFixed(2)}'),
        ],
      );
    } else {
      final arbitrageAnalysis = BlackScholesCalculator.analyzeForArbitrageur(
        futures,
        spotPrice: futures.spotPrice ?? futures.currentPrice,
      );
      return _buildInfoCard(
        'Анализ для Арбитражера',
        [
          _buildInfoRow('Стратегия', arbitrageAnalysis.arbitrageType),
          _buildInfoRow('Basis (%)', '${arbitrageAnalysis.basisPercent.toStringAsFixed(3)}%'),
          _buildInfoRow('Справедливый Basis (%)', '${arbitrageAnalysis.fairBasisPercent.toStringAsFixed(3)}%'),
          _buildInfoRow('Арбитраж (%)', '${arbitrageAnalysis.arbitrageMispricingPercent.toStringAsFixed(3)}%'),
          _buildInfoRow('Прибыльно?', arbitrageAnalysis.isProfitable ? 'Да ✓' : 'Нет',
            color: arbitrageAnalysis.isProfitable ? Colors.green : Colors.red,
          ),
        ],
      );
    }
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
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

  Widget _buildInfoRow(String label, String value, {
    bool highlight = false,
    Color? color,
  }) {
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
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                color: color,
                fontSize: highlight ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ===== ВКЛАДКА ДОБАВИТЬ ПОЗИЦИЮ =====

  Widget _buildAddPositionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Форма добавления позиции
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Параметры позиции',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Количество',
                      hintText: '10',
                      prefixIcon: const Icon(Icons.production_quantity_limits),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Цена покупки (₽)',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Предпросмотр позиции
                  _buildPositionPreview(),
                  const SizedBox(height: 16),
                  // Кнопки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addPosition,
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionPreview() {
    double quantity = double.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text) ?? 0;
    double value = quantity * price;

    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Предпросмотр позиции',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Количество: $quantity'),
                Text('Цена: ${price.toStringAsFixed(2)} ₽'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Стоимость позиции:'),
                Text(
                  '${value.toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addPosition() {
    double quantity = double.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text) ?? 0;

    if (quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Укажите корректные значения'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final position = Position(
      id: const Uuid().v4(),
      instrumentId: widget.instrument.id,
      quantity: quantity,
      purchasePrice: price,
      purchaseDate: DateTime.now(),
      currentPrice: widget.instrument.currentPrice,
    );

    _portfolioService.addPositionToPortfolio(widget.portfolio.id, position);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Позиция добавлена: ${position.quantity} × ${widget.instrument.ticker}'),
        backgroundColor: Colors.green,
      ),
    );

    widget.onPositionAdded();
    Navigator.pop(context, true);
  }

  // ===== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ =====

  String _getSectorLabel(Sector sector) {
    switch (sector) {
      case Sector.energy:
        return 'Энергетика';
      case Sector.metals:
        return 'Металлы';
      case Sector.chemicals:
        return 'Химия';
      case Sector.transport:
        return 'Транспорт';
      case Sector.finance:
        return 'Финансы';
      case Sector.utilities:
        return 'ЖКХ';
      case Sector.it:
        return 'IT';
      case Sector.retail:
        return 'Ритейл';
      case Sector.infrastructure:
        return 'Инфраструктура';
      case Sector.other:
        return 'Другое';
    }
  }

  Color _getValuationColor(StockValuationStatus status) {
    switch (status) {
      case StockValuationStatus.undervalued:
        return Colors.green;
      case StockValuationStatus.fair:
        return Colors.grey;
      case StockValuationStatus.overvalued:
        return Colors.red;
    }
  }

  String _getValuationStatusLabel(StockValuationStatus status) {
    switch (status) {
      case StockValuationStatus.undervalued:
        return 'Недооценена';
      case StockValuationStatus.fair:
        return 'Справедливая';
      case StockValuationStatus.overvalued:
        return 'Переоценена';
    }
  }

  Color _getSustainabilityColor(DividendSustainability sustainability) {
    switch (sustainability) {
      case DividendSustainability.low:
        return Colors.red;
      case DividendSustainability.moderate:
        return Colors.orange;
      case DividendSustainability.high:
        return Colors.green;
    }
  }

  String _getSustainabilityLabel(DividendSustainability sustainability) {
    switch (sustainability) {
      case DividendSustainability.low:
        return 'Низкая';
      case DividendSustainability.moderate:
        return 'Средняя';
      case DividendSustainability.high:
        return 'Высокая';
    }
  }

  Color _getRiskLevelColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  String _getRiskLevelLabel(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Низкий';
      case RiskLevel.medium:
        return 'Средний';
      case RiskLevel.high:
        return 'Высокий';
    }
  }
}

