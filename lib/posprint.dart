// import 'dart:async';
// import 'package:flutter_blue_plus_platform_interface/src/guid.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrintBill extends StatefulWidget {
  final Map<int, Map<String, dynamic>> bill;

  const PrintBill({super.key, required this.bill});

  @override
  State<PrintBill> createState() => _PrintBillState();
}

class _PrintBillState extends State<PrintBill> {
  // Future<void> _sendToUsbPrinter(List<int> bytes) async {
  //   try {
  //     if (!Platform.isWindows) {
  //       await FlutterThermalPrinter.instance.getPrinters();
  //     }

  //     final printers = await FlutterThermalPrinter.instance.devicesStream.first;

  //     final usbPrinters = printers.where((p) => p.connectionType == ConnectionType.USB).toList();

  //     if (usbPrinters.isEmpty) {
  //       debugPrint("❌ No USB printers found.");
  //       return;
  //     }

  //     Printer selectedPrinter = usbPrinters.first;

  //     bool connected = await FlutterThermalPrinter.instance.connect(selectedPrinter);
  //     if (!connected) {
  //       debugPrint("❌ Failed to connect to USB printer.");
  //       return;
  //     }

  //     await FlutterThermalPrinter.instance.printData(
  //       selectedPrinter,
  //       bytes,
  //       longData: bytes.length > 2000,
  //     );

  //     debugPrint("✅ Print job sent to USB printer.");
  //   } catch (e) {
  //     debugPrint("❌ Error printing via USB: $e");
  //   }
  // }

  Future<void> _generatePrintData(
    BuildContext context,
    Map<int, Map<String, dynamic>> bill,
  ) async {
    try {
      final profile = await CapabilityProfile.load();
      final Generator generator = Generator(
        PaperSize.mm58,
        profile,
      ); // PaperSize.mm80

      List<int> bytes = [];

      bytes += generator.text(
        'PKS',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1,
      );
      bytes += generator.text(
        'Main Canteen',
        styles: PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
      bytes += generator.text(
        'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Time: ${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 5)}',
        styles: PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
      bytes += generator.text(
        '--------------------------------',
        styles: PosStyles(align: PosAlign.center),
      );

      bytes += generator.row([
        PosColumn(text: 'Item', width: 6, styles: PosStyles(bold: true)),
        PosColumn(
          text: 'Count',
          width: 3,
          styles: PosStyles(bold: true, align: PosAlign.center),
        ),
        PosColumn(
          text: 'Price',
          width: 3,
          styles: PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);
      bytes += generator.text(
        '--------------------------------',
        styles: PosStyles(align: PosAlign.center),
      );

      double subtotal = 0.0;
      int itemIndex = 0;
      for (var entry in bill.entries) {
        final item = entry.value;
        final String itemName = item['name'].toString();
        final String itemCount = item['count'].toString();
        final String itemPrice = item['price'].toString();
        subtotal += int.parse(itemPrice);

        //printer outputvaries, need testing.
        // The linebreak of width 6 may vary.
        bytes += generator.row([
          PosColumn(
            text:
                '$itemIndex. ${itemName.length > 18 ? '${itemName.substring(0, 15)}...' : itemName}',
            width: 6,
          ),
          PosColumn(
            text: itemCount.toString(),
            width: 3,
            styles: PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: 'Rs. $itemPrice',
            width: 3,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
        itemIndex++;
      }

      bytes += generator.text(
        '--------------------------------',
        styles: PosStyles(align: PosAlign.center),
      );

      bytes += generator.row([
        PosColumn(
          text: 'Subtotal',
          width: 6,
          styles: PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text: 'Rs. $subtotal',
          width: 6,
          styles: PosStyles(
            bold: true,
            height: PosTextSize.size2,
            align: PosAlign.right,
          ),
        ),
      ]);

      bytes += generator.feed(2);
      bytes += generator.text(
        'Thank you for your purchase!',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Please come again!',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(2);
      bytes += generator.cut();
      // debugPrint(bytes.toString());
      // _sendToUsbPrinter(bytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Print data generated for debugging! (No actual print)',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating print data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalBillAmount = 0.0;
    widget.bill.forEach((key, item) {
      totalBillAmount += (item['price'] ?? 0.0);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Thermal Bill Preview')),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PKS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Main Canteen',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              Text(
                'Time: ${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 5)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              const Divider(height: 20, thickness: 1, color: Colors.black),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0.0,
                  vertical: 6.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Item",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Count",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Price",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 10, thickness: 2, color: Colors.black),
              (widget.bill.isEmpty)
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          "No Items",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.bill.length,
                      itemBuilder: (context, index) {
                        int i = widget.bill.keys.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0.0,
                            vertical: 6.0,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "${index + 1}. ",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  widget.bill[i]?['name'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  widget.bill[i]?['count'].toString() ?? "",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "₹${((widget.bill[i]?['price'] ?? 0.0)).toStringAsFixed(2)}",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

              const Divider(height: 20, thickness: 1, color: Colors.black),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '₹${totalBillAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20, thickness: 1, color: Colors.black),
              const SizedBox(height: 10),
              Text(
                'Thank you for your purchase!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),
              Text(
                'Please come again!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generatePrintData(context, widget.bill),
        label: const Text('Generate Print Data (Debug)'),
        icon: const Icon(Icons.print),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
