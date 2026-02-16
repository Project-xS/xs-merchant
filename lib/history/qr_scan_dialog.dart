import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final FocusNode _scanFocus = FocusNode();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  Map<String, dynamic>? _orderData;
  String? _error;
  String _scanBuffer = '';
  Timer? _scanDebounce;

  bool get _useCamera {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void dispose() {
    _scanDebounce?.cancel();
    _scanFocus.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_useCamera && mounted) {
        _scanFocus.requestFocus();
      }
    });
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
      if (kDebugMode) {
        debugPrint(
          '[QR] scan status=${response.statusCode} body=${response.body}',
        );
      }

      final body = response.body.trim();
      if (body.isEmpty) {
        setState(() {
          _error = "Scan failed: empty server response";
        });
        return;
      }

      Map<String, dynamic>? decoded;
      try {
        final json = jsonDecode(body);
        if (json is Map<String, dynamic>) {
          decoded = json;
        }
      } catch (_) {
        decoded = null;
      }

      if (response.statusCode == 200 &&
          decoded != null &&
          decoded['status'] == 'ok') {
        setState(() {
          _orderData = decoded?['data'] as Map<String, dynamic>?;
          _error = null;
        });
        return;
      }

      final msg = ApiClient.tryExtractErrorMessage(response) ??
          decoded?['error']?.toString() ??
          "Scan failed (${response.statusCode})";
      setState(() {
        _error = msg;
      });
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
        child: SingleChildScrollView(
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
                        final raw = barcodes.isNotEmpty
                            ? barcodes.first.rawValue
                            : null;
                        if (raw != null && raw.isNotEmpty) {
                          _submitToken(raw);
                        }
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (!_useCamera)
                Focus(
                  autofocus: true,
                  focusNode: _scanFocus,
                  onKeyEvent: _handleKeyEvent,
                  child: GestureDetector(
                    onTap: () => _scanFocus.requestFocus(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Scanner input active",
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _scanBuffer.isEmpty
                                ? "Waiting for scan..."
                                : "Captured ${_scanBuffer.length} chars",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _scanBuffer = '';
                        _orderData = null;
                        _error = null;
                      });
                      _scanFocus.requestFocus();
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

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (_isProcessing) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _scanDebounce?.cancel();
      final token = _scanBuffer;
      _scanBuffer = '';
      if (token.isNotEmpty) {
        _submitToken(token);
      }
      return KeyEventResult.handled;
    }

    final ch = event.character;
    if (ch == null || ch.isEmpty) return KeyEventResult.ignored;
    if (ch == '\n' || ch == '\r') return KeyEventResult.ignored;

    _scanBuffer += ch;
    _scanDebounce?.cancel();
    _scanDebounce = Timer(const Duration(milliseconds: 350), () {
      if (_scanBuffer.length >= 16) {
        final token = _scanBuffer;
        _scanBuffer = '';
        _submitToken(token);
      }
    });
    setState(() {});
    return KeyEventResult.handled;
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
