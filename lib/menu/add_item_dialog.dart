import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant/common/global_menu_cache.dart';
import 'package:merchant/image_upload.dart';
import 'package:merchant/l10n/app_localizations.dart';

class AddItemDialog extends StatefulWidget {
  final int canteenId;
  final bool isPortrait;
  final Future<void> Function(
    String name,
    int price,
    int stock,
    bool isVeg,
    bool available,
    Uint8List? imageBytes,
  )
  onAdd;

  const AddItemDialog({
    super.key,
    required this.canteenId,
    required this.isPortrait,
    required this.onAdd,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  bool _isVeg = false;
  bool _available = true;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  // To track if the item already exists (for warning/error styling)
  bool _isDuplicate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController(text: "0");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.add_item_head),
      content: RepaintBoundary(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizations.name,
                    border: const OutlineInputBorder(),
                    errorText: _isDuplicate
                        ? "Item Already Exists (Will Update)"
                        : null,
                  ),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _checkDuplicate(value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: localizations.price,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Price is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: localizations.stock,
                    hintText: "-1 for unlimited",
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stock is required';
                    }
                    final parsed = int.tryParse(value);
                    if (parsed == null) {
                      return 'Stock must be a number';
                    }
                    if (parsed < -1) {
                      return 'Stock must be -1 or >= 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${localizations.veg}: "),
                    Switch(
                      value: _isVeg,
                      onChanged: (value) => setState(() => _isVeg = value),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Available: "),
                    Switch(
                      value: _available,
                      onChanged: (value) => setState(() => _available = value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ImageUpload(widget.canteenId, widget.isPortrait, (
                  id,
                  bytes,
                  loading,
                ) {
                  if (bytes != null) {
                    setState(() => _imageBytes = bytes);
                  }
                }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(localizations.submit),
        ),
      ],
    );
  }

  void _checkDuplicate(String name) {
    if (name.isEmpty) {
      if (_isDuplicate) setState(() => _isDuplicate = false);
      return;
    }
    final normalized = name.trim().toLowerCase().replaceAll(' ', '');
    final exists = GlobalMenuCache.items.values.any(
      (item) =>
          item.name.trim().toLowerCase().replaceAll(' ', '') == normalized,
    );

    if (exists != _isDuplicate) {
      setState(() => _isDuplicate = exists);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await widget.onAdd(
          _nameController.text.trim(),
          int.parse(_priceController.text),
          int.parse(_stockController.text),
          _isVeg,
          _available,
          _imageBytes,
        );
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
