import 'package:flutter/material.dart';
import 'package:merchant/l10n/app_localizations.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0), // p-6
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Top Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dashboard",
                style: theme.textTheme.titleLarge, // font 24 px, weight w700
              ),
              // Optional small subtitle or action area
            ],
          ),
          const SizedBox(height: 8), // Spacing between title and subtitle if present
          Text(
            "Welcome to your Canteen Dashboard!", // Placeholder subtitle
            style: theme.textTheme.bodyMedium, // font 14 px, color #6B7280
          ),
          const SizedBox(height: 24), // gap-6

          // Stats Area
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth < 640) {
                crossAxisCount = 1; // Narrow
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
                  childAspectRatio: 1.8, // Adjust as needed for card content
                ),
                itemCount: 4, // Example: Total Orders, Total Revenue, etc.
                itemBuilder: (context, index) {
                  return _buildStatCard(context, index);
                },
              );
            },
          ),
          const SizedBox(height: 24), // gap-6

          // Two-column content below stats
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 640) {
                // Stacked on narrow screens
                return Column(
                  children: [
                    _buildTopSellingItemsCard(context),
                    const SizedBox(height: 16), // p-4
                    _buildLowStockAlertsCard(context),
                  ],
                );
              } else {
                // Two columns on wider screens
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTopSellingItemsCard(context),
                    ),
                    const SizedBox(width: 16), // p-4
                    Expanded(
                      child: _buildLowStockAlertsCard(context),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24), // gap-6

          // Recent Orders Table
          Text(
            "Recent Orders",
            style: theme.textTheme.titleMedium, // font 16 px, weight w600
          ),
          const SizedBox(height: 16), // p-4
          _buildRecentOrdersTable(context),
        ],
      ),
    ));
  }

  Widget _buildStatCard(BuildContext context, int index) {
    final theme = Theme.of(context);
    // Placeholder data for demonstration
    final List<Map<String, dynamic>> stats = [
      {
        'label': 'Total Orders',
        'value': '1,234',
        'icon': Icons.shopping_cart,
        'trend': '+5%',
        'trendColor': Colors.green,
      },
      {
        'label': 'Total Revenue',
        'value': '\$12,345',
        'icon': Icons.attach_money,
        'trend': '+12%',
        'trendColor': Colors.green,
      },
      {
        'label': 'New Customers',
        'value': '123',
        'icon': Icons.person_add,
        'trend': '-2%',
        'trendColor': Colors.red,
      },
      {
        'label': 'Avg. Order Value',
        'value': '\$10.00',
        'icon': Icons.receipt,
        'trend': '+1%',
        'trendColor': Colors.green,
      },
    ];

    final stat = stats[index];

    return Card(
      elevation: 0, // Custom shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // rounded-lg
      ),
      child: Container(
        padding: const EdgeInsets.all(16), // p-4
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 3)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stat['label'],
                  style: theme.textTheme.bodyMedium, // 14 px, color #6B7280
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // blue-50
                    borderRadius: BorderRadius.circular(20), // circular
                  ),
                  child: Icon(
                    stat['icon'],
                    color: const Color(0xFF2563EB), // blue-600
                    size: 20, // 20-24 px
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              stat['value'],
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
                  stat['trendColor'] == Colors.green
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: stat['trendColor'],
                  size: 16, // tiny
                ),
                const SizedBox(width: 4),
                Text(
                  stat['trend'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: stat['trendColor'],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "vs last month", // Helper text
                  style: theme.textTheme.bodySmall, // 12 px gray
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingItemsCard(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder data
    final List<Map<String, dynamic>> topItems = [
      {
        'name': 'Chicken Biryani',
        'category': 'Non-Veg',
        'quantity': 150,
        'revenue': '\$1500',
        'image': 'assets/images/friedrice.png', // Placeholder image
      },
      {
        'name': 'Veg Fried Rice',
        'category': 'Veg',
        'quantity': 120,
        'revenue': '\$960',
        'image': 'assets/images/veg.png', // Placeholder image
      },
      {
        'name': 'Coffee',
        'category': 'Beverages',
        'quantity': 200,
        'revenue': '\$400',
        'image': 'assets/images/logo.png', // Placeholder image
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
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 3)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Top Selling Items",
              style: theme.textTheme.titleMedium, // 16 px, w600
            ),
            const SizedBox(height: 16), // p-4
            ListView.builder(
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(item['image']),
                            fit: BoxFit.cover,
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
                              ),
                            ),
                            Text(
                              item['category'],
                              style: theme.textTheme.bodySmall, // 12 px, gray-500
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${item['quantity']} sold",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            item['revenue'],
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlertsCard(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder data
    final List<Map<String, dynamic>> lowStockItems = [
      {'name': 'Milk', 'stock': 5},
      {'name': 'Bread', 'stock': 8},
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
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 3)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Low Stock Alerts",
              style: theme.textTheme.titleMedium, // 16 px, w600
            ),
            const SizedBox(height: 16), // p-4
            if (lowStockItems.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lowStockItems.length,
                itemBuilder: (context, index) {
                  final item = lowStockItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          "${item['stock']} left",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFFDC2626), // red-600
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              Column(
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: const Color(0xFF16A34A), // green-600
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "All items well stocked!",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF16A34A), // green-600
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersTable(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder data
    final List<Map<String, dynamic>> orders = [
      {
        'id': 'ORD001',
        'student': 'Alice Smith',
        'items': '2x Coffee, 1x Sandwich',
        'amount': '\$12.50',
        'status': 'Completed',
        'time': '10:30 AM',
      },
      {
        'id': 'ORD002',
        'student': 'Bob Johnson',
        'items': '1x Biryani',
        'amount': '\$8.00',
        'status': 'Pending',
        'time': '11:00 AM',
      },
      {
        'id': 'ORD003',
        'student': 'Charlie Brown',
        'items': '3x Juice',
        'amount': '\$7.50',
        'status': 'Approved',
        'time': '11:15 AM',
      },
      {
        'id': 'ORD004',
        'student': 'Diana Prince',
        'items': '1x Salad, 1x Water',
        'amount': '\$9.25',
        'status': 'Rejected',
        'time': '11:45 AM',
      },
    ];

    Color getStatusColor(String status) {
      switch (status) {
        case 'Pending':
          return const Color(0xFFD97706); // yellow-600
        case 'Approved':
          return const Color(0xFF16A34A); // green-600
        case 'Completed':
          return const Color(0xFF2563EB); // blue-600
        case 'Rejected':
          return const Color(0xFFDC2626); // red-600
        default:
          return Colors.grey;
      }
    }

    Color getStatusBackgroundColor(String status) {
      switch (status) {
        case 'Pending':
          return const Color(0xFFFEF3C7); // yellow-100
        case 'Approved':
          return const Color(0xFFD1FAE5); // green-100
        case 'Completed':
          return const Color(0xFFEFF6FF); // blue-50
        case 'Rejected':
          return const Color(0xFFFEE2E2); // red-100
        default:
          return Colors.grey.shade200;
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24, // Adjust spacing as needed
        dataRowMinHeight: 56,
        dataRowMaxHeight: 56,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columns: [
          DataColumn(
              label: Text('Order ID',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827)))),
          DataColumn(
              label: Text('Student',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827)))),
          DataColumn(
              label: Text('Items',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827)))),
          DataColumn(
              label: Text('Amount',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827)))),
          DataColumn(
              label: Text('Status',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827)))),
          DataColumn(
              label: Text('Time',
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827)))),
        ],
        rows: orders.map((order) {
          return DataRow(
            cells: [
              DataCell(Text(
                order['id'],
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'monospace', // Monospace font
                  fontSize: 13,
                ),
              )),
              DataCell(Text(
                order['student'],
                style: theme.textTheme.bodyLarge,
              )),
              DataCell(Text(
                order['items'],
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              )),
              DataCell(Text(
                order['amount'],
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              )),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusBackgroundColor(order['status']),
                    borderRadius: BorderRadius.circular(20), // full pill
                  ),
                  child: Text(
                    order['status'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: getStatusColor(order['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(Text(
                order['time'],
                style: theme.textTheme.bodySmall, // 13-14 px, color #6B7280
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
