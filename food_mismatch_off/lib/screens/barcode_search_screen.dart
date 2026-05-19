import 'package:flutter/material.dart';

class BarcodeSearchScreen extends StatefulWidget {
  const BarcodeSearchScreen({super.key});

  @override
  State<BarcodeSearchScreen> createState() => _BarcodeSearchScreenState();
}

class _BarcodeSearchScreenState extends State<BarcodeSearchScreen> {
  final TextEditingController barcodeController = TextEditingController();

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  void searchBarcode() {
    final barcode = barcodeController.text.trim();

    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen barkod numarası girin')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Barkod aranıyor: $barcode')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF7CB68A);
    final darkGreen = const Color(0xFF4D7C57);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBFC),
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          'Barkodla Ara',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ürün barkodunu gir',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Barkod numarasını aşağıdaki alana yazabilirsin.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: green.withValues(alpha: 0.55)),
              ),
              child: TextField(
                controller: barcodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Barkod numarası',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  suffixIcon: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: darkGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: searchBarcode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Ara',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6EA),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Barkod genellikle ürün ambalajının arka veya alt kısmında bulunur.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 56,
                    color: darkGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
