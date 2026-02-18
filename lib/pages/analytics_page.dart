import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String? _selectedTimeRange = 'Today'; // Default selected time range

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // p-6
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Analytics Dashboard",
                    style: theme.textTheme.titleLarge, // font 24 px
                  ),
                  _buildTimeRangeDropdown(theme),
                ],
              ),
              const SizedBox(height: 24), // gap-6
              // KPIs (four-card grid)
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  if (constraints.maxWidth < 640) {
                    crossAxisCount = 1; // Small
                  } else if (constraints.maxWidth < 1024) {
                    crossAxisCount = 2; // Medium
                  } else {
                    crossAxisCount = 4; // Wide
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16, // p-4
                      mainAxisSpacing: 16, // p-4
                      childAspectRatio: 1.8, // Adjust as needed
                    ),
                    itemCount:
                        4, // Total Revenue, Total Orders, Avg. Order Value, New Customers
                    itemBuilder: (context, index) {
                      return _buildKpiCard(context, index);
                    },
                  );
                },
              ),
              const SizedBox(height: 24), // gap-6
              // Order status breakdown
              Text(
                "Order Status Breakdown",
                style: theme.textTheme.titleMedium, // 16 px w600
              ),
              const SizedBox(height: 16), // p-4
              _buildOrderStatusBreakdownCard(context),
              const SizedBox(height: 24), // gap-6
              // Revenue by order type
              Text("Revenue by Order Type", style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildRevenueByOrderTypeCard(context),
              const SizedBox(height: 24), // gap-6
              // Top selling items list
              Text("Top Selling Items", style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildTopSellingItemsList(context),
              const SizedBox(height: 24), // gap-6
              // Peak hours
              Text("Peak Hours", style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildPeakHoursList(context),
              const SizedBox(height: 24), // gap-6
              // Category performance
              Text("Category Performance", style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildCategoryPerformanceGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeDropdown(ThemeData theme) {
    final List<String> timeRanges = ["Today", "This Week", "This Month"];

    return SizedBox(
      height: 44, // Height 40-44 px
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: theme.inputDecorationTheme.border,
          enabledBorder: theme.inputDecorationTheme.enabledBorder,
          focusedBorder: theme.inputDecorationTheme.focusedBorder,
          contentPadding: theme.inputDecorationTheme.contentPadding,
        ),
        value: _selectedTimeRange,
        items: timeRanges.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedTimeRange = newValue;
            // TODO: Filter analytics data based on time range
          });
        },
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, int index) {
    final theme = Theme.of(context);
    // Placeholder data for demonstration
    final List<Map<String, dynamic>> kpis = [
      {
        'label': 'Total Revenue',
        'value': '\$25,000',
        'icon': Icons.monetization_on,
        'change': '+15%',
        'changeColor': Colors.green,
      },
      {
        'label': 'Total Orders',
        'value': '2,500',
        'icon': Icons.shopping_cart,
        'change': '+10%',
        'changeColor': Colors.green,
      },
      {
        'label': 'Avg. Order Value',
        'value': '\$10.00',
        'icon': Icons.receipt,
        'change': '+2%',
        'changeColor': Colors.green,
      },
      {
        'label': 'New Customers',
        'value': '50',
        'icon': Icons.person_add,
        'change': '-5%',
        'changeColor': Colors.red,
      },
    ];

    final kpi = kpis[index];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // rounded-lg
      ),
      child: Container(
        padding: const EdgeInsets.all(16), // p-4
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  kpi['label'],
                  style: theme.textTheme.bodySmall, // 12-14 px, color #6B7280
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // blue-50
                    borderRadius: BorderRadius.circular(20), // circular
                  ),
                  child: Icon(
                    kpi['icon'],
                    color: const Color(0xFF2563EB), // blue-600
                    size: 20, // 20-24 px
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              kpi['value'],
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28, // 24-28 px
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827), // gray-900
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  kpi['changeColor'] == Colors.green
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: kpi['changeColor'],
                  size: 16, // tiny
                ),
                const SizedBox(width: 4),
                Text(
                  kpi['change'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kpi['changeColor'],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "vs last period", // Helper text
                  style: theme.textTheme.bodySmall, // 12 px gray
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusBreakdownCard(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder data
    final List<Map<String, dynamic>> statuses = [
      {
        'label': 'Pending',
        'count': 15,
        'color': const Color(0xFFD97706), // yellow-600
        'bgColor': const Color(0xFFFEF3C7), // yellow-100
      },
      {
        'label': 'Approved',
        'count': 80,
        'color': const Color(0xFF16A34A), // green-600
        'bgColor': const Color(0xFFD1FAE5), // green-100
      },
      {
        'label': 'Rejected',
        'count': 5,
        'color': const Color(0xFFDC2626), // red-600
        'bgColor': const Color(0xFFFEE2E2), // red-100
      },
      {
        'label': 'Completed',
        'count': 100,
        'color': const Color(0xFF2563EB), // blue-600
        'bgColor': const Color(0xFFEFF6FF), // blue-50
      },
    ];

    final totalOrders = statuses.fold(
      0,
      (sum, item) => sum + (item['count'] as int),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // rounded-lg
      ),
      child: Container(
        padding: const EdgeInsets.all(16), // p-4
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: statuses.map((status) {
            final double percentage = totalOrders > 0
                ? (status['count'] / totalOrders)
                : 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: status['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status['label'],
                        style: theme.textTheme.bodyLarge, // 14 px
                      ),
                      const Spacer(),
                      Text(
                        status['count'].toString(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3), // rounded corners
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: status['bgColor'],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        status['color'],
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRevenueByOrderTypeCard(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder data
    final List<Map<String, dynamic>> orderTypes = [
      {
        'label': 'Instant Orders',
        'revenue': '\$18,000',
        'color': const Color(0xFF2563EB), // blue-600
      },
      {
        'label': 'Pre-Orders',
        'revenue': '\$7,000',
        'color': Colors.orange.shade700, // orange
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // rounded-lg
      ),
      child: Container(
        padding: const EdgeInsets.all(16), // p-4
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          children: orderTypes.map((type) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: type['color'],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    type['label'],
                    style: theme.textTheme.bodyLarge, // 14 px
                  ),
                  const Spacer(),
                  Text(
                    type['revenue'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 22,
                    ), // 18-22 px big
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopSellingItemsList(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder data
    final List<Map<String, dynamic>> topItems = [
      {
        'rank': 1,
        'name': 'Chicken Biryani',
        'category': 'Non-Veg',
        'unitsSold': 300,
        'revenue': '\$3000',
      },
      {
        'rank': 2,
        'name': 'Veg Fried Rice',
        'category': 'Veg',
        'unitsSold': 250,
        'revenue': '\$2000',
      },
      {
        'rank': 3,
        'name': 'Coffee',
        'category': 'Beverages',
        'unitsSold': 400,
        'revenue': '\$800',
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // rounded-lg
      ),
      child: Container(
        padding: const EdgeInsets.all(16), // p-4
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topItems.length,
          itemBuilder: (context, index) {
            final item = topItems[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        item['rank'].toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ), // 14-16 px
                        ),
                        Text(
                          item['category'],
                          style: theme.textTheme.bodySmall, // 12 px
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${item['unitsSold']} units",
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(item['revenue'], style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPeakHoursList(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder data
    final List<Map<String, dynamic>> peakHours = [
      {'hour': '12:00 PM', 'isPeak': true},
      {'hour': '1:00 PM', 'isPeak': false},
      {'hour': '7:00 PM', 'isPeak': false},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // rounded-lg
      ),
      child: Container(
        padding: const EdgeInsets.all(16), // p-4
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: peakHours.length,
          itemBuilder: (context, index) {
            final hour = peakHours[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.black,
                    ), // Clock icon
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hour['hour'],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ), // 16 px bold
                  ),
                  if (hour['isPeak'])
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade700,
                      ), // Star icon for peak
                    ),
                  const Spacer(),
                  Text(
                    "Peak", // Small subtitle
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryPerformanceGrid(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder data
    final List<Map<String, dynamic>> categories = [
      {'title': 'Beverages', 'orders': 150, 'revenue': '\$500'},
      {'title': 'Snacks', 'orders': 200, 'revenue': '\$700'},
      {'title': 'Main Course', 'orders': 100, 'revenue': '\$1200'},
      {'title': 'Desserts', 'orders': 50, 'revenue': '\$300'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 640) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1024) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 3; // Example: 3 columns for wide screens
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12, // Spacing
            mainAxisSpacing: 12, // Spacing
            childAspectRatio: 2.5, // Adjust as needed
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // 8-12 px
              ),
              child: Container(
                padding: const EdgeInsets.all(12), // p-3
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.06),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['title'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${category['orders']} orders",
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(category['revenue'], style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
