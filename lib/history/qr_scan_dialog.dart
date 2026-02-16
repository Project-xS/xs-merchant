import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/api/api_constants.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanDialog extends StatefulWidget {
  final void Function(int orderId) onDeliver;

  const QrScanDialog({
    super.key,
    required this.onDeliver,
  });

  @override
  State<QrScanDialog> createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<QrScanDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  Map<String, dynamic>? _orderData;
  String? _error;

  bool get _useCamera {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocus.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _submitToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _error = null;
      _orderData = null;
    });

    try {
      final response = await ApiClient.post(
        ApiConstants.ordersScan,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': trimmed}),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map<String, dynamic> &&
          decoded['status'] == 'ok') {
        setState(() {
          _orderData = decoded['data'] as Map<String, dynamic>?;
          _error = null;
        });
      } else {
        final msg = ApiClient.tryExtractErrorMessage(response) ??
            (decoded is Map<String, dynamic> ? decoded['error'] : null) ??
            "Scan failed (${response.statusCode})";
        setState(() {
          _error = msg;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Scan failed: $e";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.item_delivery),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_useCamera)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      if (_isProcessing) return;
                      final barcodes = capture.barcodes;
                      final raw =
                          barcodes.isNotEmpty ? barcodes.first.rawValue : null;
                      if (raw != null && raw.isNotEmpty) {
                        _submitToken(raw);
                      }
                    },
                  ),
                ),
              ),
            if (_useCamera) const SizedBox(height: 12),
            TextField(
              controller: _controller,
              focusNode: _inputFocus,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: _useCamera
                    ? "Scan fallback (paste token)"
                    : "Scan QR (hardware scanner)",
                hintText: "Paste or scan token",
              ),
              onSubmitted: _submitToken,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _submitToken(_controller.text),
                  child: const Text("Verify"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _orderData = null;
                      _error = null;
                    });
                    _inputFocus.requestFocus();
                  },
                  child: const Text("Clear"),
                ),
                const Spacer(),
                if (_isProcessing)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            if (_orderData != null) _buildOrderDetails(theme),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        FilledButton.icon(
          onPressed: (_orderData == null || _isProcessing)
              ? null
              : () {
                  final orderId = _orderData?['order_id'];
                  if (orderId is int) {
                    widget.onDeliver(orderId);
                    Navigator.pop(context);
                  }
                },
          icon: const Icon(Icons.check),
          label: const Text("Confirm & Deliver"),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(ThemeData theme) {
    final orderId = _orderData?['order_id'];
    final totalPrice = _orderData?['total_price'];
    final deliverAt = _orderData?['deliver_at'];
    final items = (_orderData?['items'] as List?) ?? const [];

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order #$orderId",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (deliverAt != null && deliverAt.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Deliver at: $deliverAt",
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index] as Map<String, dynamic>;
                    final name = item['name']?.toString() ?? 'Item';
                    final qty = item['quantity'];
                    final price = item['price'];
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          "x$qty",
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "₹$price",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total", style: theme.textTheme.titleSmall),
                  Text(
                    "₹$totalPrice",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
