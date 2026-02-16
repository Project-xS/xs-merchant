import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/api/api_constants.dart';
import 'package:merchant/common/button_styles.dart';
import 'package:merchant/l10n/app_localizations.dart';

class VerificationDialog extends StatefulWidget {
  final bool isPortrait;
  final int canteenId;
  final Function(int orderId, Map<String, dynamic> data) onOrderFetched;
  final Function(bool submit, int orderId) onMarkDelivered;

  const VerificationDialog({
    super.key,
    required this.isPortrait,
    required this.canteenId,
    required this.onOrderFetched,
    required this.onMarkDelivered,
  });

  @override
  State<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchBarFocus = FocusNode();

  int _orderId = 0;
  bool _rfid = true;
  Map<String, dynamic>? _currentOrderData;

  @override
  void dispose() {
    _controller.dispose();
    _searchBarFocus.dispose();
    super.dispose();
  }

  void _resetSearch() {
    setState(() {
      _controller.clear();
      _orderId = 0;
      _currentOrderData = null;
      FocusScope.of(context).requestFocus(_searchBarFocus);
    });
  }

  bool _isLoading = false;

  Future<void> _fetchOrder(String value) async {
    if (value.isEmpty) return;

    setState(() {
      _isLoading = true;
      _orderId = 0;
      _currentOrderData = null;
    });

    try {
      // Small delay to prevent rapid flickering if API is too fast, and to let UI update
      await Future.delayed(const Duration(milliseconds: 200));
      final queryParam = _rfid ? "rfid=$value" : "user_id=$value";
      final response = await ApiClient.get(
        ApiConstants.ordersByUser(queryParam),
      );

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        if (decodedJson["data"] != null &&
            (decodedJson["data"] as List).isNotEmpty) {
          for (var order in decodedJson["data"]) {
            final int orderId = order["order_id"];
            final int price = order["total_price"];
            final List<String> names = [];
            final List<int> counts = [];
            final List<dynamic> statuses = [];

            for (var item in order["items"]) {
              names.add(item["name"]);
              counts.add(item["quantity"]);
              statuses.add(null);
            }

            final orderData = {
              'name': names,
              'count': counts,
              'price': price,
              'status': statuses,
              'submitted': null,
            };

            widget.onOrderFetched(orderId, orderData);

            if (mounted) {
              setState(() {
                _orderId = orderId;
                _currentOrderData = orderData;
                _isLoading = false;
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error Getting Order : ${response.statusCode}"),
            ),
          );
          setState(() {
            _orderId = 0;
            _currentOrderData = null;
            _isLoading = false;
          });
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Not Connected, $e")));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Text(
        localizations.item_delivery,
        style: theme.textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchBar(
            autoFocus: true,
            focusNode: _searchBarFocus,
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: widget.isPortrait ? 5 : 10.0),
            ),
            controller: _controller,
            keyboardType: TextInputType.number,
            leading: const Icon(Icons.verified),
            hintText: localizations.s_tap,
            trailing: [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _controller.clear(),
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt),
                onPressed: _resetSearch,
              ),
            ],
            onChanged: (value) async {
              String filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (_controller.text != filtered) {
                _controller.text = filtered;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              }
              if (filtered.isNotEmpty) {
                await _fetchOrder(filtered);
              }
            },
          ),
          SizedBox(
            width: 200,
            height: 50,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("User ID", style: theme.textTheme.bodyLarge),
                  Switch(
                    value: _rfid,
                    onChanged: (value) {
                      setState(() {
                        _rfid = value;
                        _resetSearch();
                      });
                    },
                  ),
                  Text("RFID", style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_orderId != 0 && _currentOrderData != null)
            Flexible(
              child: SingleChildScrollView(
                child: _buildVerificationCard(theme, localizations),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  localizations.not_found,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    if (_currentOrderData == null) return const SizedBox.shrink();

    final names = _currentOrderData!['name'] as List;
    final counts = _currentOrderData!['count'] as List;
    // We create a local copy of status for editing in the dialog
    final currentStatus = List<bool?>.from(
      _currentOrderData!['status'] as List,
    );
    final bool? isSubmitted = (_currentOrderData!['submitted'] == null)
        ? null
        : false;
    final int price = _currentOrderData!['price'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isPortrait ? 10 : 30,
          vertical: 10.0,
        ),
        child: StatefulBuilder(
          builder: (context, setStateCard) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.titleLarge,
                        children: [
                          TextSpan(text: "${localizations.order_id} #"),
                          TextSpan(
                            text: _orderId.toString(),
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.00),
                Divider(thickness: 1, color: theme.dividerColor),
                ...List.generate(names.length, (i) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: isSubmitted == true
                                ? null
                                : () {
                                    setStateCard(() {
                                      if (currentStatus[i] == null ||
                                          currentStatus[i] == false) {
                                        currentStatus[i] = true;
                                      } else {
                                        currentStatus[i] = false;
                                      }
                                    });
                                  },
                            icon: Icon(
                              currentStatus[i] == true
                                  ? Icons.check_circle
                                  : currentStatus[i] == false
                                  ? Icons.cancel
                                  : Icons.help_outline,
                              color: currentStatus[i] == true
                                  ? theme.colorScheme.secondary
                                  : currentStatus[i] == false
                                  ? theme.colorScheme.error
                                  : Colors.yellow,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "${names[i]}",
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "x ${counts[i]}",
                            style: theme.textTheme.bodyLarge,
                          ),
                          Checkbox(
                            tristate: true,
                            value: currentStatus[i],
                            onChanged: isSubmitted == true
                                ? null
                                : (value) {
                                    setStateCard(() {
                                      currentStatus[i] = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                      const Divider(thickness: 1),
                    ],
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.titleLarge,
                        children: [
                          TextSpan(text: "${localizations.price}: "),
                          TextSpan(
                            text: "₹$price",
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: getActionButtonStyle(context, true),
                      onPressed: isSubmitted == true
                          ? null
                          : () {
                              _showConfirmationDialog(
                                context,
                                theme,
                                localizations,
                                names,
                                counts,
                                currentStatus,
                              );
                            },
                      child: Row(
                        children: [
                          const Icon(Icons.check),
                          const SizedBox(width: 8),
                          Text(localizations.submit),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    List names,
    List counts,
    List<bool?> currentStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.confirm_order_changes),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < names.length; i++)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${names[i]}",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: currentStatus[i] == true
                                    ? theme.colorScheme.secondary
                                    : currentStatus[i] == null
                                    ? Colors.yellow
                                    : theme.colorScheme.error,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "x ${counts[i]}",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: Text(
                              currentStatus[i] == true
                                  ? localizations.accept
                                  : currentStatus[i] == null
                                  ? localizations.deliver_later
                                  : localizations.reject,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: currentStatus[i] == true
                                    ? theme.colorScheme.secondary
                                    : currentStatus[i] == null
                                    ? Colors.yellow
                                    : theme.colorScheme.error,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(thickness: 1),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: getActionButtonStyle(context, false),
                    onPressed: () => Navigator.pop(context, false),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close),
                        const SizedBox(width: 8),
                        Text(localizations.cancel),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: getActionButtonStyle(context, true),
                    onPressed: () {
                      // Update logic
                      bool isAllTrue = currentStatus.every((e) => e == true);
                      bool isAllFalse = currentStatus.every((e) => e == false);

                      Map<String, dynamic> updatedData = Map.from(
                        _currentOrderData!,
                      );
                      updatedData['status'] = List<bool?>.from(currentStatus);

                      if (!isAllTrue && !isAllFalse) {
                        updatedData['submitted'] = null;
                        // Partial -> Deliver Later
                        widget.onOrderFetched(_orderId, updatedData);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              currentStatus.any((e) => e == null)
                                  ? "Made order(s) to be delivered later"
                                  : "Accepted/Rejected Order",
                            ),
                            backgroundColor: currentStatus.any((e) => e == null)
                                ? Colors.yellowAccent
                                : Colors.orangeAccent,
                          ),
                        );
                      } else {
                        // All true or All false
                        updatedData['submitted'] = true;
                        widget.onOrderFetched(_orderId, updatedData);
                        widget.onMarkDelivered(isAllTrue, _orderId);
                      }

                      Navigator.pop(context); // Close confirmation
                      Navigator.pop(context); // Close verification dialog
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check),
                        const SizedBox(width: 8),
                        Text(localizations.submit),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
