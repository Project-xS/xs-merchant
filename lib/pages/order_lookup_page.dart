import 'package:flutter/material.dart';

class OrderLookupPage extends StatefulWidget {
  const OrderLookupPage({super.key});

  @override
  State<OrderLookupPage> createState() => _OrderLookupPageState();
}

class _OrderLookupPageState extends State<OrderLookupPage> {
  bool _isRfidSearch = true; // true for RFID, false for User ID
  final TextEditingController _searchController = TextEditingController();
  bool _studentFound = false; // Placeholder for student lookup status
  bool _hasOrders = true; // Placeholder for orders availability

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0), // p-6
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Order Lookup",
              style: theme.textTheme.titleLarge, // font 24 px
            ),
            const SizedBox(height: 24), // gap-6
            // Search Area
            Container(
              padding: const EdgeInsets.all(12), // p-3
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // rounded-lg
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.06),
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Segmented Control
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6), // gray-100
                      borderRadius: BorderRadius.circular(8), // rounded-md
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isRfidSearch = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isRfidSearch
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: _isRfidSearch
                                    ? Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ) // gray-200
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  "RFID",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: _isRfidSearch
                                        ? const Color(0xFF2563EB)
                                        : const Color(
                                            0xFF6B7280,
                                          ), // blue-600 / gray-500
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isRfidSearch = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isRfidSearch
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: !_isRfidSearch
                                    ? Border.all(color: const Color(0xFFE5E7EB))
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  "User ID",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: !_isRfidSearch
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Spacing
                  // Inline Search Field and Button
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44, // Height 44 px
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                _isRfidSearch
                                    ? Icons.credit_card
                                    : Icons.person,
                                size: 20, // 20 px
                              ),
                              hintText: _isRfidSearch
                                  ? "Enter RFID..."
                                  : "Enter User ID...",
                              hintStyle: theme.inputDecorationTheme.hintStyle,
                              border: theme.inputDecorationTheme.border,
                              enabledBorder:
                                  theme.inputDecorationTheme.enabledBorder,
                              focusedBorder:
                                  theme.inputDecorationTheme.focusedBorder,
                              contentPadding:
                                  theme.inputDecorationTheme.contentPadding,
                            ),
                            onSubmitted: (_) => _performSearch(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12), // Spacing
                      SizedBox(
                        height: 44, // Height 44 px
                        width: 100, // width approximate 100-120 px
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF2563EB,
                            ), // blue-600
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // 8-12 px
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: _performSearch,
                          child: const Text("Search"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // gap-6
            // Demo Sample Box
            Container(
              padding: const EdgeInsets.all(12), // p-3
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // rounded-lg
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
                    "Sample IDs",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "RFID: 1234567890",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    "User ID: user123",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // gap-6
            // Student Info Card (visible when _studentFound is true)
            if (_studentFound) _buildStudentInfoCard(context),
            if (_studentFound) const SizedBox(height: 24), // gap-6
            // Orders List
            if (_studentFound)
              _buildOrdersList(context)
            else if (!_studentFound && _searchController.text.isNotEmpty)
              _buildNoStudentFoundState(context),
          ],
        ),
      ),
    );
  }

  void _performSearch() {
    // TODO: Implement actual search logic
    setState(() {
      _studentFound = _searchController
          .text
          .isNotEmpty; // For demo, assume student found if search not empty
      _hasOrders = _studentFound; // For demo, assume orders if student found
    });
  }

  Widget _buildStudentInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder student data
    final String studentName = "John Doe";
    final String studentId = "STU001";
    final String balance = "\$50.00";

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
          ], // subtle shadow
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 640) {
              // Stacked on narrow screens
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentInfoItem(theme, "Student Name", studentName),
                  const SizedBox(height: 12),
                  _buildStudentInfoItem(
                    theme,
                    "Student ID",
                    studentId,
                    isMonospace: true,
                  ),
                  const SizedBox(height: 12),
                  _buildStudentInfoItem(
                    theme,
                    "Balance",
                    balance,
                    isBalance: true,
                  ),
                ],
              );
            } else {
              // Three columns on wide screens
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildStudentInfoItem(
                      theme,
                      "Student Name",
                      studentName,
                    ),
                  ),
                  Expanded(
                    child: _buildStudentInfoItem(
                      theme,
                      "Student ID",
                      studentId,
                      isMonospace: true,
                    ),
                  ),
                  Expanded(
                    child: _buildStudentInfoItem(
                      theme,
                      "Balance",
                      balance,
                      isBalance: true,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStudentInfoItem(
    ThemeData theme,
    String label,
    String value, {
    bool isMonospace = false,
    bool isBalance = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall, // 12 px color #6B7280
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20, // 18-20 px
            fontWeight: FontWeight.w700,
            fontFamily: isMonospace ? 'monospace' : null,
            color: isBalance
                ? const Color(0xFF16A34A)
                : const Color(0xFF111827), // green-600 for balance
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    final theme = Theme.of(context);
    // Placeholder order data
    final List<Map<String, dynamic>> orders = [
      {
        'id': 'ORD001',
        'status': 'Pending',
        'type': 'Instant',
        'amount': '\$15.00',
        'time': '10:30 AM',
        'items': [
          {'name': 'Coffee', 'quantity': 2, 'subtotal': '\$5.00'},
          {'name': 'Sandwich', 'quantity': 1, 'subtotal': '\$10.00'},
        ],
      },
      {
        'id': 'ORD002',
        'status': 'Approved',
        'type': 'Pre-order',
        'amount': '\$20.00',
        'time': '09:00 AM',
        'timeSlot': 'Lunch (12:00 PM)',
        'items': [
          {'name': 'Biryani', 'quantity': 1, 'subtotal': '\$12.00'},
          {'name': 'Juice', 'quantity': 2, 'subtotal': '\$8.00'},
        ],
      },
      {
        'id': 'ORD003',
        'status': 'Rejected',
        'type': 'Instant',
        'amount': '\$7.50',
        'time': '11:00 AM',
        'items': [
          {'name': 'Tea', 'quantity': 3, 'subtotal': '\$7.50'},
        ],
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

    Color getOrderTypeColor(String type) {
      switch (type) {
        case 'Instant':
          return const Color(0xFF4338CA); // blue-700 (example)
        case 'Pre-order':
          return Colors.orange.shade700; // orange (example)
        default:
          return Colors.grey;
      }
    }

    Color getOrderTypeBackgroundColor(String type) {
      switch (type) {
        case 'Instant':
          return const Color(0xFFEEF2FF); // blue-50 (example)
        case 'Pre-order':
          return Colors.orange.shade50; // orange (example)
        default:
          return Colors.grey.shade200;
      }
    }

    if (!_hasOrders) {
      return _buildNoOrdersFoundState(context);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12), // margin bottom 12 px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // rounded-lg
          ),
          child: Container(
            padding: const EdgeInsets.all(16), // p-4 (12-16 px)
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
                // Header row
                Row(
                  children: [
                    Text(
                      order['id'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getOrderTypeBackgroundColor(order['type']),
                        borderRadius: BorderRadius.circular(20), // full pill
                      ),
                      child: Text(
                        order['type'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: getOrderTypeColor(order['type']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      order['amount'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      order['time'],
                      style: theme.textTheme.bodySmall, // 12 px gray
                    ),
                    if (order['timeSlot'] != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // rounded small pill
                          ),
                          child: Text(
                            order['timeSlot'],
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16), // Spacing
                // Items block
                Container(
                  padding: const EdgeInsets.all(12), // p-3
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF8FAFC,
                    ), // light gray rounded background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: (order['items'] as List<dynamic>).map<Widget>((
                      item,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${item['quantity']}x ${item['name']}",
                              style: theme.textTheme.bodyLarge, // 14 px
                            ),
                            Text(
                              item['subtotal'],
                              style: theme.textTheme.bodyLarge, // 14 px
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (order['status'] == 'Pending')
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0), // Spacing
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showSnackbar(
                                context,
                                "Order ${order['id']} approved",
                              );
                              // TODO: Update order status to Approved
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF16A34A,
                              ), // green-600
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 36), // height 36 px
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Approve"),
                          ),
                        ),
                        const SizedBox(width: 12), // Spacing
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showSnackbar(
                                context,
                                "Order ${order['id']} rejected",
                              );
                              // TODO: Update order status to Rejected
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFDC2626,
                              ), // red-600
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 36), // height 36 px
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Reject"),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoOrdersFoundState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined, // Package icon
            size: 48,
            color: theme.textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 12),
          Text(
            "No orders found",
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNoStudentFoundState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search, // Search icon
            size: 48,
            color: theme.textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 12),
          Text(
            "No student found with the provided ID",
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
