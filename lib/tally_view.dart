import 'package:flutter/material.dart';
import 'package:merchant/common/global_menu_cache.dart';

class TallyView extends StatefulWidget {
  final int canteenId;
  final bool isTamil;
  final Map<int, Map<String, dynamic>> bill;
  final List<int> searchitems;
  final Function(Map<int, Map<String, dynamic>>) onBillUpdate;

  const TallyView(
    this.canteenId,
    this.isTamil,
    this.searchitems,
    this.bill,
    this.onBillUpdate, {
    super.key,
  });

  @override
  State<TallyView> createState() => _TallyViewState();
}

class _TallyViewState extends State<TallyView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemIds = widget.searchitems.isNotEmpty
        ? widget.searchitems
        : GlobalMenuCache.availableid.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemIds.length,
      itemBuilder: (context, index) {
        final itemId = itemIds[index];
        final item = GlobalMenuCache.items[itemId];
        if (item == null) return const SizedBox.shrink();

        final count = widget.bill[itemId]?['count'] ?? 0;
        final bool isSelected = count > 0;

        return Card(
          elevation: isSelected ? 4 : 1,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: isSelected
              ? theme.colorScheme.surfaceContainerHighest
              : theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: GlobalMenuCache.items[itemId]?.isVeg == true
                      ? Colors.green
                      : theme.colorScheme.error,
                  size: 14,
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${item.price}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (count > 0) ...[
                        _buildIconButton(
                          context: context,
                          icon: Icons.remove,
                          color: theme.colorScheme.error,
                          onPressed: () {
                            setState(() {
                              int currentCount =
                                  widget.bill[itemId]?['count'] ?? 0;
                              if (currentCount - 1 <= 0) {
                                widget.bill.remove(itemId);
                              } else {
                                widget.bill[itemId]!['count'] =
                                    currentCount - 1;
                                widget.bill[itemId]!['price'] =
                                    item.price * (currentCount - 1);
                              }
                              widget.onBillUpdate(widget.bill);
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            count.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      _buildIconButton(
                        context: context,
                        icon: Icons.add,
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          setState(() {
                            int currentCount =
                                widget.bill[itemId]?['count'] ?? 0;
                            if (currentCount == 0) {
                              widget.bill[itemId] = {
                                'name': item.name,
                                'price': item.price,
                                'count': 1,
                                'id': itemId,
                              };
                            } else {
                              widget.bill[itemId]!['count'] = currentCount + 1;
                              widget.bill[itemId]!['price'] =
                                  item.price * (currentCount + 1);
                            }
                            widget.onBillUpdate(widget.bill);
                          });
                        },
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

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        iconSize: 20,
        constraints: BoxConstraints.tight(const Size(36, 36)),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
