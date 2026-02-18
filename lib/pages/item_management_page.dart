import 'package:flutter/material.dart';

class ItemManagementPage extends StatefulWidget {
  const ItemManagementPage({super.key});

  @override
  State<ItemManagementPage> createState() => _ItemManagementPageState();
}

class _ItemManagementPageState extends State<ItemManagementPage> {
  String? _selectedCategory;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Item Management",
                  style: theme.textTheme.titleLarge, // font 24 px weight w700
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Add Item functionality (open modal)
                    _showAddItemModal(context);
                  },
                  icon: const Icon(Icons.add, size: 24), // Plus icon
                  label: const Text("Add Item"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // blue-600
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 8-12 px
                    ),
                    minimumSize: const Size(0, 44), // height 44 px
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ), // Adjust padding
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24), // gap-6
            // Filter bar
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ), // py-3, px-3
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 640) {
                    // Stacked on narrow screens
                    return Column(
                      children: [
                        _buildSearchField(theme),
                        const SizedBox(height: 12), // 12 px vertical gap
                        _buildCategoryDropdown(theme),
                      ],
                    );
                  } else {
                    // Inline on wider screens
                    return Row(
                      children: [
                        Expanded(child: _buildSearchField(theme)),
                        const SizedBox(width: 16), // 12-16 px spacing
                        _buildCategoryDropdown(theme),
                      ],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24), // gap-6
            // Items grid
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                if (constraints.maxWidth < 640) {
                  crossAxisCount = 1; // Narrow
                } else if (constraints.maxWidth < 1024) {
                  crossAxisCount = 2; // Medium
                } else {
                  crossAxisCount = 3; // Wide
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16, // p-4
                    mainAxisSpacing: 16, // p-4
                    childAspectRatio: 0.7, // Adjust as needed for card content
                  ),
                  itemCount: 6, // Placeholder item count
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, index);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return SizedBox(
      height: 44, // Height 44 px
      child: TextField(
        onChanged: (value) {
          setState(() {
            // TODO: Implement search filter
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search,
            size: 24,
          ), // Leading search icon 20-24 px
          hintText: "Search items...",
          hintStyle: theme.inputDecorationTheme.hintStyle,
          border: theme.inputDecorationTheme.border,
          enabledBorder: theme.inputDecorationTheme.enabledBorder,
          focusedBorder: theme.inputDecorationTheme.focusedBorder,
          contentPadding: theme.inputDecorationTheme.contentPadding,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    final List<String> categories = [
      "All",
      "Veg",
      "Non-Veg",
      "Beverages",
    ]; // Placeholder categories

    return Container(
      height: 44, // Height 44 px
      padding: const EdgeInsets.symmetric(horizontal: 12), // px-3
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // rounded-md
        border: Border.all(color: const Color(0xFFE5E7EB)), // gray-200
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory ?? categories.first,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 24,
          ), // Small chevron icon
          style: theme.textTheme.bodyLarge, // 14 px
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          items: categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, int index) {
    final theme = Theme.of(context);
    // Placeholder data
    final bool isActive = index % 2 == 0; // Example: alternate active/inactive
    final bool isLowStock = index == 1; // Example: one item is low stock

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // rounded-lg
      ),
      child: Container(
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
            // Top image area
            Stack(
              children: [
                Container(
                  height: 192, // 12 rem
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/friedrice.png',
                      ), // Placeholder image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (!isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Disabled",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEE2E2), // green-100 / red-100
                      borderRadius: BorderRadius.circular(18), // circular
                    ),
                    child: Icon(
                      isActive ? Icons.visibility : Icons.visibility_off,
                      color: isActive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626), // green-600 / red-600
                      size: 20, // 18-20 px
                    ),
                  ),
                ),
              ],
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16.0), // p-4
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Item Name ${index + 1}", // Placeholder item name
                        style: theme.textTheme.titleMedium, // 18 px w600
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5), // green-50
                          borderRadius: BorderRadius.circular(
                            4,
                          ), // small rounded
                        ),
                        child: Text(
                          "\$12.99", // Placeholder price
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF16A34A), // green-600
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // top padding 8 px
                  Text(
                    "A short description of the item.", // Placeholder description
                    style:
                        theme.textTheme.bodyMedium, // 13-14 px, color #6B7280
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12), // vertical spacing 8-12 px
                  // Info row(s)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6), // gray-100
                          borderRadius: BorderRadius.circular(
                            4,
                          ), // small rounded
                        ),
                        child: Text(
                          "Category", // Placeholder category
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF374151), // gray-700
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF), // blue-50
                          borderRadius: BorderRadius.circular(
                            4,
                          ), // small rounded
                        ),
                        child: Text(
                          "Instant Order", // Instant order indicator
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF4338CA), // blue-700
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                          ), // Small clock icon
                          const SizedBox(width: 4),
                          Text(
                            "15 min", // Prep time
                            style: theme.textTheme.bodySmall, // 12-13 px
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // vertical spacing 8-12 px
                  // Stock row
                  Row(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(
                              color: theme.dividerColor,
                            ), // Neutral background
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 20,
                            color: Colors.black,
                          ), // Minus button
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            isLowStock ? "5" : "50", // Stock number
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isLowStock
                                  ? const Color(0xFFDC2626)
                                  : Colors.black, // red if low
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(
                              color: theme.dividerColor,
                            ), // Neutral background
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.black,
                          ), // Plus button
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // p-4
                  // Action row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Implement Edit functionality (open modal)
                            _showAddItemModal(context, isEdit: true);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6B7280), // gray
                            side: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ), // gray-200
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // 8 px
                            ),
                            minimumSize: const Size(0, 36), // height 36-40 px
                          ),
                          child: const Text("Edit"),
                        ),
                      ),
                      const SizedBox(width: 12), // Spacing
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement Delete functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFDC2626,
                            ), // solid red
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // 8 px
                            ),
                            minimumSize: const Size(0, 36), // height 36-40 px
                          ),
                          child: const Text("Delete"),
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

  void _showAddItemModal(BuildContext context, {bool isEdit = false}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Do not close on backdrop tap
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // rounded-lg
          ),
          contentPadding: const EdgeInsets.all(24), // p-6
          title: Text(
            isEdit ? "Edit Item" : "Add New Item",
            style: Theme.of(context).textTheme.titleMedium, // 16 px w600
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 448, // max width 448 px
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Name",
                      hintText: "Enter item name",
                    ),
                  ),
                  const SizedBox(height: 12), // vertical spacing 12 px
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Price",
                      hintText: "Enter price",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Stock",
                      hintText: "Enter stock quantity",
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Category"),
                    value: "Veg", // Placeholder value
                    items: <String>["Veg", "Non-Veg", "Beverages"]
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      // TODO: Handle category change
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    maxLines: 4,
                    minLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Enter item description",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Prep Time (minutes)",
                      hintText: "Enter preparation time",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Image URL",
                      hintText: "Enter image URL",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: true, // Placeholder value
                        onChanged: (bool? newValue) {
                          // TODO: Handle instant order checkbox
                        },
                      ),
                      Text(
                        "Instant Order",
                        style: Theme.of(context).textTheme.bodyLarge, // 14 px
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Save functionality
                Navigator.of(context).pop();
              },
              child: Text(isEdit ? "Save Changes" : "Add Item"),
            ),
          ],
        );
      },
    );
  }
}
