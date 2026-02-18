import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/api/api_constants.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/models/order_models.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanDialog extends StatefulWidget {
  final void Function(int orderId) onDeliver;

  const QrScanDialog({super.key, required this.onDeliver});

  @override
  State<QrScanDialog> createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<QrScanDialog> {
  final FocusNode _scanFocus = FocusNode();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  OrderItemContainer? _orderData;
  String? _error;
  String _scanBuffer = '';
  Timer? _scanDebounce;
  String? _lastToken;
  DateTime? _lastResultAt;
  String? _successMessage;
  static const Duration _rescanCooldown = Duration(seconds: 3);

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
    if (_shouldIgnoreToken(trimmed)) return;

    setState(() {
      _isProcessing = true;
      _isProcessing = true;
      _error = null;
      _successMessage = null;
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
          final data = decoded?['data'];
          if (data != null) {
            _orderData = OrderItemContainer.fromJson(data);
          }
          _error = null;
        });
        _recordResult(trimmed);
        return;
      }

      if (response.statusCode == 403) {
        final msg =
            decoded?['error']?.toString() ??
            "Valid QR but order is for a different canteen";
        setState(() {
          _error = msg;
        });
        _recordResult(trimmed);
        return;
      }

      final msg =
          ApiClient.tryExtractErrorMessage(response) ??
          decoded?['error']?.toString() ??
          "Scan failed (${response.statusCode})";
      setState(() {
        _error = msg;
      });
      _recordResult(trimmed);
    } catch (e) {
      setState(() {
        _error = "Scan failed: $e";
      });
      _recordResult(trimmed);
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
    final screenHeight = MediaQuery.of(context).size.height;

    // Use a large portion of the screen for the scanner, but keep it reasonable
    // for smaller devices or landscape modes.
    final scanHeight = (screenHeight * 0.45).clamp(250.0, 450.0);

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
                  height: scanHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: (capture) {
                            if (_isProcessing) return;
                            final barcodes = capture.barcodes;
                            final raw = barcodes.isNotEmpty
                                ? barcodes.first.rawValue
                                : null;
                            if (raw != null && raw.isNotEmpty) {
                              if (_shouldIgnoreToken(raw)) return;
                              _submitToken(raw);
                            }
                          },
                        ),
                        // Add a subtle overlay or viewfinder frame here if desired
                        // For now we just keep the video feed
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (!_useCamera || kDebugMode)
                // Fallback input visible in debug mode too for easier testing
                // or if camera is not available.
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
                      if (!_useCamera && _scanFocus.canRequestFocus) {
                        _scanFocus.requestFocus();
                      }
                    },
                    child: const Text("Clear Result"),
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
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      border: Border.all(color: theme.colorScheme.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
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
                  final orderId = _orderData!.orderId;
                  widget.onDeliver(orderId);

                  // Show inline success feedback
                  setState(() {
                    _successMessage = "Order #$orderId marked as delivered";
                    _orderData = null;
                    _error = null;
                    _scanBuffer = '';
                  });

                  // Clear success message after delay
                  Timer(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _successMessage = null;
                      });
                    }
                  });

                  // Refocus if needed
                  if (!_useCamera && _scanFocus.canRequestFocus) {
                    _scanFocus.requestFocus();
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
    final orderId = _orderData!.orderId;
    final totalPrice = _orderData!.totalPrice;
    final deliverAt = _orderData!.deliverAt;
    final items = _orderData!.items;

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
              if (deliverAt.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Deliver at: $deliverAt",
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Text("No items")
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final name = item.name;
                    final qty = item.quantity;
                    final price = item.price ?? 0;
                    return Row(
                      children: [
                        Expanded(
                          child: Text(name, style: theme.textTheme.bodyMedium),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            "x$qty",
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            "₹${qty * price}",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total", style: theme.textTheme.titleSmall),
                  Text(
                    "₹${totalPrice}",
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

  bool _shouldIgnoreToken(String token) {
    // If the token matches the last successfully scanned one
    if (_lastToken == token) {
      // If we are currently displaying an order, don't refresh it with the same token
      if (_orderData != null) return true;

      // If we aren't displaying an order (e.g. cleared), check cooldown
      if (_lastResultAt != null) {
        final elapsed = DateTime.now().difference(_lastResultAt!);
        if (elapsed < _rescanCooldown) return true;
      }
    }
    return false;
  }

  void _recordResult(String token) {
    _lastToken = token;
    _lastResultAt = DateTime.now();
  }
}
