import 'package:flutter/material.dart';
import 'package:merchant/common/global_menu_cache.dart';
// import 'package:merchant/main.dart';
import 'package:merchant/menupage.dart';
import 'package:merchant/models/menu_item.dart';

class EditItemPage extends StatefulWidget {
  final int itemId;

  const EditItemPage({super.key, required this.itemId});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _prepTimeController;
  late TextEditingController _imageUrlController;
  late bool _isVeg;
  String? _category;

  @override
  void initState() {
    super.initState();
    final item = GlobalMenuCache.items[widget.itemId];

    _nameController = TextEditingController(text: item?.name);
    _descriptionController = TextEditingController(text: '');
    _priceController = TextEditingController(text: item?.price.toString());
    _stockController = TextEditingController(text: item?.stock.toString());
    _prepTimeController = TextEditingController(text: '15');
    _imageUrlController = TextEditingController(text: item?.pic);
    _isVeg = item?.isVeg ?? false;
    _category = _isVeg ? 'Veg' : 'Non-Veg';
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final price = int.parse(_priceController.text);
      final stock = int.parse(_stockController.text);
      final isVeg = _category == 'Veg';
      final pic = _imageUrlController.text;
      final available = GlobalMenuCache.items[widget.itemId]?.available ?? false;

      final updatedItemMap = {
        'name': name,
        'price': price,
        'stocks': stock,
        'is_veg': isVeg,
        'description': _descriptionController.text,
        'prep_time': _prepTimeController.text,
        'pic': pic,
        'available': available,
      };

      MenupageState().updateitem(widget.itemId, updatedItemMap);

      // Update local cache
      final currentItem = GlobalMenuCache.items[widget.itemId];
      if (currentItem != null) {
        GlobalMenuCache.items[widget.itemId] = currentItem.copyWith(
          name: name,
          price: price,
          stock: stock,
          isVeg: isVeg,
          pic: pic,
          available: available,
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Edit Item', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageUrlController.text.isNotEmpty
                    ? Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                      )
                    : Icon(Icons.image, size: 48, color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(controller: _nameController, labelText: 'Name'),
              const SizedBox(height: 16),
              _buildTextFormField(controller: _descriptionController, labelText: 'Description', maxLines: 3),
              const SizedBox(height: 16),
              _buildTextFormField(controller: _priceController, labelText: 'Price', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextFormField(controller: _stockController, labelText: 'Stock', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextFormField(controller: _prepTimeController, labelText: 'Prep Time', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: ['Veg', 'Non-Veg'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _category = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(controller: _imageUrlController, labelText: 'Image URL'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Save'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.grey),
                    child: const Text('Cancel'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}

extension on MenuItem? {
  void operator [](String other) {}
}
