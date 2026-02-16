import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:merchant/common/global_menu_cache.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/models/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final int itemId;
  final MenuItem item;
  final bool isTamil;
  final bool available;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuItemCard({
    super.key,
    required this.itemId,
    required this.item,
    required this.isTamil,
    required this.available,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final isVeg = item.isVeg;
    final stockValue = item.stock;
    final stockDisplay = stockValue == -1 ? '∞' : stockValue.toString();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image Background
            Positioned.fill(child: _buildImage(itemId)),

            // Gradient Overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.4, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // "Off Menu" Overlay
            if (!available)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Text(
                      localizations.off_menu,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Veg/Non-Veg Icon (Top Left)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  isVeg ? "assets/images/veg.png" : "assets/images/nonveg.png",
                  width: 20,
                  height: 20,
                ),
              ),
            ),

            // Action Menu (Top Right)
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        localizations.delete,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content (Bottom)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${item.price}",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${localizations.stock}: $stockDisplay",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(int itemId) {
    final imageUrl = GlobalMenuCache.items[itemId]?.pic;
    final etag = GlobalMenuCache.items[itemId]?.etag;

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      return ExtendedImage.network(
        imageUrl,
        fit: BoxFit.cover,
        cache: true,
        cacheKey: etag,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            case LoadState.completed:
              return ExtendedRawImage(
                image: state.extendedImageInfo?.image,
                fit: BoxFit.cover,
              );
            case LoadState.failed:
              return const Center(
                child: Icon(Icons.fastfood, color: Colors.white24, size: 40),
              );
          }
        },
      );
    }
    return const Center(
      child: Icon(Icons.fastfood, color: Colors.white24, size: 40),
    );
  }
}
