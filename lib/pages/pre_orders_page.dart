import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:merchant/providers/auth_provider.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/models/order_models.dart';

class PreOrdersPage extends StatefulWidget {
  const PreOrdersPage({super.key});

  @override
  State<PreOrdersPage> createState() => _PreOrdersPageState();
}

class _PreOrdersPageState extends State<PreOrdersPage>
    with OrderFetchMixin<PreOrdersPage> {
  String? _selectedTimeSlot = "All";
  String? _selectedStatus = "All";
  List<Map<String, dynamic>> _allPreOrders = [];
  List<Map<String, dynamic>> _filteredPreOrders = [];
  bool _isLoading = true;

  @override
  int get canteenIdForOrders =>
      Provider.of<AuthProvider>(context, listen: false).canteenId ?? 0;

  @override
  void onOrdersUpdated(Map<String, List<ActiveOrderItem>> orders) {
    setState(() {
      _allPreOrders = _transformOrders(orders);
      _applyFilters();
      _isLoading = false;
    });
  }

  @override
  void onOrderFetchError(dynamic error) {
    setState(() {
      _isLoading = false;
    });
    // Optionally show an error message
    _showSnackbar(context, "Error fetching pre-orders: $error");
  }

  List<Map<String, dynamic>> _transformOrders(
    Map<String, List<ActiveOrderItem>> fetchedOrders,
  ) {
    List<Map<String, dynamic>> transformedList = [];
    int orderIdCounter = 1;

    fetchedOrders.forEach((time, orderItems) {
      List<dynamic> items = [];
      double totalAmount = 0.0;

      for (var item in orderItems) {
        // Placeholder for subtotal, as it's not directly available from OrderFetchMixin
        // In a real scenario, you'd fetch item prices or calculate based on known prices.
        double subtotal =
            item.numOrdered *
            5.0; // Assuming a placeholder price of 5.0 per item
        totalAmount += subtotal;

        items.add({
          'name': item.itemName,
          'quantity': item.numOrdered,
          'subtotal': '\$${subtotal.toStringAsFixed(2)}',
        });
      }

      transformedList.add({
        'displayId': 'PRE${orderIdCounter.toString().padLeft(3, '0')}',
        'status':
            'Pending', // Default status, can be updated based on actual API response if available
        'type': 'Pre-order',
        'amount': '\$${totalAmount.toStringAsFixed(2)}',
        'time': time,
        'timeSlot': _getTimeSlotFromTime(time), // Derive time slot from time
        'items': items,
      });
      orderIdCounter++;
    });
    return transformedList;
  }

  String _getTimeSlotFromTime(String time) {
    // Simple logic to derive a time slot for demonstration
    // In a real app, you'd have a more robust way to map times to slots.
    final hour = int.parse(time.split(':')[0]);
    if (hour >= 7 && hour < 10) {
      return 'Breakfast ($time)';
    } else if (hour >= 12 && hour < 15) {
      return 'Lunch ($time)';
    } else if (hour >= 18 && hour < 21) {
      return 'Dinner ($time)';
    }
    return 'General ($time)';
  }

  void _applyFilters() {
    _filteredPreOrders = _allPreOrders.where((order) {
      bool matchesTimeSlot = true;
      if (_selectedTimeSlot != null && _selectedTimeSlot != 'All') {
        matchesTimeSlot =
            order['timeSlot']?.contains(_selectedTimeSlot!) ?? false;
      }

      bool matchesStatus = true;
      if (_selectedStatus != null && _selectedStatus != 'All') {
        matchesStatus = order['status'] == _selectedStatus;
      }
      return matchesTimeSlot && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> uniqueTimeSlots =
        _allPreOrders
            .map((order) => _getTimeSlotFromTime(order['time'] as String))
            .toSet()
            .toList()
          ..sort();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0), // p-6
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Pre-Orders",
              style: theme.textTheme.titleLarge, // font 24 px
            ),
            const SizedBox(height: 24), // gap-6

            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                if (constraints.maxWidth < 640) {
                  crossAxisCount = 1; // Narrow
                } else {
                  crossAxisCount = 2; // Wide
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16, // p-4
                    mainAxisSpacing: 16, // p-4
                    childAspectRatio: 2.0, // Adjust as needed
                  ),
                  itemCount: uniqueTimeSlots.length,
                  itemBuilder: (context, index) {
                    return _buildTimeSlotCard(context, index, uniqueTimeSlots);
                  },
                );
              },
            ),
            const SizedBox(height: 24), // gap-6
            // Global filter bar
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
              child: Row(
                children: [
                  Expanded(child: _buildTimeSlotDropdown(theme)),
                  const SizedBox(width: 12), // Spacing
                  Expanded(child: _buildStatusDropdown(theme)),
                ],
              ),
            ),
            const SizedBox(height: 24), // gap-6
            // Pre-orders list area
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredPreOrders.isNotEmpty)
              _buildPreOrdersList(context)
            else
              _buildNoPreOrdersState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(
    BuildContext context,
    int index,
    List<String> uniqueTimeSlots,
  ) {
    final theme = Theme.of(context);

    if (index >= uniqueTimeSlots.length) {
      return const SizedBox.shrink(); // Return an empty widget if index is out of bounds
    }

    final String timeSlotName = uniqueTimeSlots[index];
    final String timeRange = timeSlotName.substring(
      timeSlotName.indexOf('(') + 1,
      timeSlotName.indexOf(')'),
    );

    // Calculate placeholder stats based on filtered orders for this time slot
    final List<Map<String, dynamic>> ordersInSlot = _allPreOrders
        .where(
          (order) =>
              _getTimeSlotFromTime(order['time'] as String) == timeSlotName,
        )
        .toList();
    final int totalOrders = ordersInSlot.length;
    final int pendingOrders = ordersInSlot
        .where((order) => order['status'] == 'Pending')
        .length;
    double revenue = 0.0;
    // Since subtotal is a placeholder, revenue will also be a placeholder calculation
    for (var order in ordersInSlot) {
      for (var item in order['items']) {
        revenue +=
            (item['quantity'] as int) * 5.0; // Using the same placeholder price
      }
    }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeSlotName
                          .split(' (')
                          .first, // Display only the name part
                      style: theme.textTheme.titleMedium, // 16 px
                    ),
                    Text(
                      timeRange,
                      style: theme.textTheme.bodySmall, // 12 px
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (pendingOrders > 0)
                        ? const Color(0xFFFEF3C7)
                        : Colors
                              .grey
                              .shade200, // active color tint based on pending orders
                    borderRadius: BorderRadius.circular(18), // circular
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: (pendingOrders > 0)
                        ? const Color(0xFFD97706)
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Spacing
            // Small 3-stat inline row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  theme,
                  Icons.list_alt,
                  totalOrders.toString(),
                  "Total Orders",
                ),
                _buildStatItem(
                  theme,
                  Icons.pending_actions,
                  pendingOrders.toString(),
                  "Pending",
                ),
                _buildStatItem(
                  theme,
                  Icons.attach_money,
                  '\$${revenue.toStringAsFixed(2)}',
                  "Revenue",
                ),
              ],
            ),
            const SizedBox(height: 16), // Spacing
            // Optional top items list (simplified)
            // Since top items are not directly available, we can show a generic message or omit.
            Text(
              "Items in this slot",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (ordersInSlot.isNotEmpty)
              ...ordersInSlot
                  .take(2)
                  .map(
                    (order) => Text(
                      (order['items'] as List)
                          .map((item) => item['name'])
                          .join(', '),
                      style: theme.textTheme.bodyLarge, // 14 px
                    ),
                  )
            else
              Text(
                "No items",
                style: theme.textTheme.bodyLarge, // 14 px
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: theme.textTheme.bodyMedium?.color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ), // 18-20 px bold
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall, // 12 px
        ),
      ],
    );
  }

  Widget _buildTimeSlotDropdown(ThemeData theme) {
    final List<String> uniqueTimes = [
      "All",
      ..._allPreOrders.map((order) => order['time'] as String).toSet().toList()
        ..sort(),
    ];

    return SizedBox(
      height: 44, // Height 44 px
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Time Slot",
          border: theme.inputDecorationTheme.border,
          enabledBorder: theme.inputDecorationTheme.enabledBorder,
          focusedBorder: theme.inputDecorationTheme.focusedBorder,
          contentPadding: theme.inputDecorationTheme.contentPadding,
        ),
        value: _selectedTimeSlot ?? uniqueTimes.first,
        items: uniqueTimes.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedTimeSlot = newValue;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildStatusDropdown(ThemeData theme) {
    final List<String> statuses = [
      "All",
      "Pending",
      "Approved",
      "Rejected",
      "Completed",
    ]; // Placeholder statuses

    return SizedBox(
      height: 44, // Height 44 px
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Status",
          border: theme.inputDecorationTheme.border,
          enabledBorder: theme.inputDecorationTheme.enabledBorder,
          focusedBorder: theme.inputDecorationTheme.focusedBorder,
          contentPadding: theme.inputDecorationTheme.contentPadding,
        ),
        value: _selectedStatus ?? statuses.first,
        items: statuses.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedStatus = newValue;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildPreOrdersList(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredPreOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredPreOrders[index];
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
                      order['displayId'],
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
                    // Removed amount display as it's not directly from backend
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      order['time'],
                      style: theme.textTheme.bodySmall, // 12 px gray
                    ),
                    // Removed timeSlot display as it's derived and not directly from backend
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
                            // Removed subtotal display as it's not directly from backend
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
                                "Pre-order ${order['displayId']} approved",
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
                                "Pre-order ${order['displayId']} rejected",
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

  Widget _buildNoPreOrdersState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today, // Calendar icon
            size: 48,
            color: theme.textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 12),
          Text(
            "No pre-orders for selected filters",
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
