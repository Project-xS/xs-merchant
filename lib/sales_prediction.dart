import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

class SalesPredictionPage extends StatefulWidget {
  const SalesPredictionPage({super.key});

  @override
  State<SalesPredictionPage> createState() => _SalesPredictionPageState();
}

class _SalesPredictionPageState extends State<SalesPredictionPage> {
  bool _isEventDay = false;
  late DecisionTreeClassifier _classifier;
  List<BarChartGroupData> _chartData = [];
  double _maxY = 1000;

  final _itemData = [
    {
      'id': 1,
      'name': 'Chicken Fried Rice',
      'is_bestseller': true,
      'previous_sales': 4500,
    },
    {
      'id': 2,
      'name': 'Chicken Noodles',
      'is_bestseller': true,
      'previous_sales': 3000,
    },
    {
      'id': 3,
      'name': 'Veg Fried Rice',
      'is_bestseller': true,
      'previous_sales': 4000,
    },
    {'id': 4, 'name': 'Biryani', 'is_bestseller': true, 'previous_sales': 3000},
    {
      'id': 5,
      'name': 'Parotta',
      'is_bestseller': false,
      'previous_sales': 2000,
    },
    {'id': 6, 'name': 'Dosa', 'is_bestseller': false, 'previous_sales': 800},
    {'id': 7, 'name': 'Idly', 'is_bestseller': false, 'previous_sales': 600},
    {'id': 8, 'name': 'Pongal', 'is_bestseller': false, 'previous_sales': 500},
  ];

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _trainModel();
      _predictSales();
      _isInitialized = true;
    }
  }

  void _trainModel() {
    final List<List<dynamic>> trainingData = [
      ['previous_sales', 'is_bestseller', 'day_type', 'predicted_sales'],
    ];

    for (int i = 500; i <= 10000; i += 250) {
      final bestsellerMultiplier = 1.25;
      final eventMultiplier = 1.35;

      trainingData.add([i, 0, 0, i]);
      trainingData.add([i, 1, 0, (i * bestsellerMultiplier).round()]);
      trainingData.add([i, 0, 1, (i * eventMultiplier).round()]);
      trainingData.add([
        i,
        1,
        1,
        (i * bestsellerMultiplier * eventMultiplier).round(),
      ]);
    }

    final samples = DataFrame(trainingData, headerExists: true);

    _classifier = DecisionTreeClassifier(
      samples,
      'predicted_sales',
      minSamplesCount: 2,
    );
  }

  void _predictSales() {
    final dayTypeValue = _isEventDay ? 1 : 0;
    final eventColor = const Color.fromARGB(255, 255, 167, 38);

    final predictionItems = _itemData
        .map(
          (item) => [
            item['previous_sales'],
            item['is_bestseller'] == true ? 1 : 0,
            dayTypeValue,
          ],
        )
        .toList();

    final predictionHeader = ['previous_sales', 'is_bestseller', 'day_type'];
    final predictionDf = DataFrame([predictionHeader, ...predictionItems]);

    final prediction = _classifier.predict(predictionDf);

    final predictedSales = prediction['predicted_sales'].data
        .map((value) => (value as num).toDouble())
        .toList();

    double maxSale = 0;
    for (var sale in predictedSales) {
      if (sale > maxSale) {
        maxSale = sale;
      }
    }

    if (!mounted) return;
    final theme = Theme.of(context);
    setState(() {
      _maxY = maxSale > 0 ? maxSale * 1.2 : 10000;
      _chartData = _itemData.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final sales = predictedSales[index];
        return BarChartGroupData(
          x: item['id'] as int,
          barRods: [
            BarChartRodData(
              toY: sales,
              color: _isEventDay ? eventColor : theme.colorScheme.primary,
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemNames = _itemData.map((e) => e['name'] as String).toList();
    final eventColor = const Color.fromARGB(255, 255, 167, 38);
    final screenWidth = MediaQuery.of(context).size.width;
    const mobileBreakpoint = 650;
    final isMobile = screenWidth < mobileBreakpoint;

    final barChart = BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final itemName = itemNames[group.x.toInt() - 1];
              return BarTooltipItem(
                '$itemName\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.toY).round().toString(),
                    style: TextStyle(
                      color: _isEventDay ? eventColor : Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() > itemNames.length) return const Text('');
                final text = itemNames[value.toInt() - 1];
                return SideTitleWidget(
                  meta: meta,
                  space: 4.0,
                  angle: isMobile ? -0.785 : 0,
                  child: Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
                  ),
                );
              },
              reservedSize: isMobile ? 42 : 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: _maxY > 0 ? _maxY / 4 : 2500,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > _maxY) return const Text('');
                return Text(
                  '${(value / 1000).round()}k',
                  style: theme.textTheme.bodyMedium,
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _chartData,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Colors.white24, strokeWidth: 0.5);
          },
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: Text('Sales Prediction', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF161B22),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Event Day Prediction',
                      style: theme.textTheme.titleMedium,
                    ),
                    Switch(
                      value: _isEventDay,
                      onChanged: (value) {
                        setState(() {
                          _isEventDay = value;
                          _predictSales();
                        });
                      },
                      activeTrackColor: eventColor.withAlpha(100),
                      activeColor: eventColor,
                      inactiveThumbColor: theme.colorScheme.onSurface
                          .withOpacity(0.6),
                      inactiveTrackColor: theme.colorScheme.surface,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isEventDay
                  ? 'Event Day Sales Forecast'
                  : 'Normal Day Sales Forecast',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                color: const Color(0xFF161B22),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: isMobile
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: _itemData.length * 70.0,
                            child: barChart,
                          ),
                        )
                      : barChart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
