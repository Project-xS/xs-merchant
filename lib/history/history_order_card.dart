import 'package:flutter/material.dart';
import 'package:merchant/l10n/app_localizations.dart';

class HistoryOrderCard extends StatelessWidget {
  final int orderId;
  final Map<String, dynamic> orderData;

  const HistoryOrderCard({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final isHoldOrder = orderData['submitted'] == null;
    final holdOrderStyle = TextStyle(
      color: theme.colorScheme.primary,
      fontSize: theme.textTheme.titleLarge?.fontSize,
      fontWeight: theme.textTheme.titleLarge?.fontWeight,
      fontFamily: theme.textTheme.titleLarge?.fontFamily,
    );

    final names = orderData['name'] as List;
    final statuses = orderData['status'] as List;
    final counts = orderData['count'] as List;
    final price = orderData['price'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.order_items,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.titleLarge,
                    children: [
                      const TextSpan(text: '#'),
                      TextSpan(
                        text: orderId.toString(),
                        style: isHoldOrder ? holdOrderStyle : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            ...List.generate(names.length, (i) {
              final status = statuses[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      status == true
                          ? Icons.check_circle
                          : status == null
                          ? Icons.help_outline
                          : Icons.cancel,
                      color: status == true
                          ? Colors.green
                          : status == null
                          ? Colors.amber
                          : Colors.red,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        names[i].toString(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "x ${counts[i]}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.titleLarge,
                    children: [
                      TextSpan(
                        text: "${localizations.total}: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "₹$price",
                        style: (isHoldOrder ? holdOrderStyle : null)?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
