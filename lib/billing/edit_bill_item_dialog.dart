import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditBillItemDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(int quantity) onUpdate;
  final VoidCallback onDelete;

  const EditBillItemDialog({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<EditBillItemDialog> createState() => _EditBillItemDialogState();
}

class _EditBillItemDialogState extends State<EditBillItemDialog> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item['count'].toString(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        "Edit Bill Item",
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Item: ${widget.item['name']}",
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            "Quantity:",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: "Enter Quantity",
              hintText: "items >= 1",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final quantity = int.tryParse(value);
              if (quantity != null && quantity >= 1) {
                widget.onUpdate(quantity);
              } else {
                // Logic to handle invalid input?
                // The original code reset to 1 immediately on invalid input which might be annoying while typing.
                // We will just not update if invalid, or handle it on submit/change.
                // Original code:
                /*
                  if (int.parse(value)>=1){
                    // update
                  }else{
                    // set to 1
                  }
                 */
                if (value.isNotEmpty && (quantity == null || quantity < 1)) {
                  widget.onUpdate(1); // Force to 1 if invalid
                }
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            "Or Delete Item:",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text(
              "Delete",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
