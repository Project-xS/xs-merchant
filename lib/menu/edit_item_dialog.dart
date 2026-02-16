import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant/image_upload.dart';
import 'package:merchant/l10n/app_localizations.dart';

class EditItemDialog extends StatefulWidget {
  final int itemId;
  final String initialName;
  final int initialPrice;
  final int initialStock;
  final bool initialIsVeg;
  final bool initialAvailable;
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
  onUpdate;

  const EditItemDialog({
    super.key,
    required this.itemId,
    required this.initialName,
    required this.initialPrice,
    required this.initialStock,
    required this.initialIsVeg,
    required this.initialAvailable,
    required this.canteenId,
    required this.isPortrait,
    required this.onUpdate,
  });

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _price;
  late int _stock;
  late bool _isVeg;
  late bool _available;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _price = widget.initialPrice;
    _stock = widget.initialStock;
    _isVeg = widget.initialIsVeg;
    _available = widget.initialAvailable;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.modify_item(widget.initialName)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: localizations.new_name),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _price.toString(),
                decoration: InputDecoration(labelText: localizations.new_price),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Price is required';
                  return null;
                },
                onSaved: (value) => _price = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: InputDecoration(
                  labelText: localizations.stock,
                  hintText: "-1 for unlimited",
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
                onSaved: (value) => _stock = int.parse(value!),
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        await widget.onUpdate(
          _name,
          _price,
          _stock,
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
