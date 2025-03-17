import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/data/models/product_info.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/caricaScaricaPage.dart';

class BarcodeScannerPageCarico extends ConsumerStatefulWidget {
  const BarcodeScannerPageCarico(
      {super.key,
      required this.IdOrdine,
      required this.userId,
      required this.warehouseId,
      required this.quantitaDiRientro,
      required this.orderPosition,
      required this.orderBarcode});


  final int IdOrdine;
  final int userId;
  final int warehouseId;
  final int quantitaDiRientro;
  final String orderPosition;
  final String orderBarcode;

  @override
  _BarcodeScannerPageCaricoState createState() =>
      _BarcodeScannerPageCaricoState();
}

class _BarcodeScannerPageCaricoState
    extends ConsumerState<BarcodeScannerPageCarico> {
  String? scannedBarcode;
  ProductInfo? productInfo;
  bool isLoading = false;
  String? errorMessage;
  int totalQuantity = 0;
  String? reference;

  final TextEditingController _quantityController =
      TextEditingController(text: '0');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startBarcodeScan();
  }

  String? modifyScannedBarcode(String? barcode) {
    return barcode?.isNotEmpty == true ? barcode!.padLeft(13, '0') : barcode;
  }

  Future<void> _startBarcodeScan() async {
    setState(() => isLoading = true);

    try {
      final result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        scannedBarcode = modifyScannedBarcode(result.rawContent);
        print('Codice a barre scansionato: $scannedBarcode');
        await _fetchProductDetails(scannedBarcode!);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchProductDetails(String barcode) async {
    try {
      setState(() => isLoading = true);

      final productRepository = ref.read(productRepositoryProvider);
      final product = await productRepository.getProductByBarcode(barcode);

      setState(() {
        productInfo = ProductInfo(
          Id: product.Id,
          Nome: product.Nome,
          Giacenza: product.Giacenza,
        );
        totalQuantity = product.Giacenza;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Errore nel recupero dei dettagli del prodotto: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveQuantity() async {
    setState(() => isLoading = true);

    final productRepository = ref.read(productRepositoryProvider);

    try {
      await productRepository.updateProductCaricoQuantityOnServer(
        scannedBarcode!,
        widget.quantitaDiRientro,
        widget.IdOrdine,
        widget.userId,
      );

      await _fetchProductDetails(scannedBarcode!);
      _showMessage('Quantità aggiornata con successo');

      setState(() {
        _quantityController.text = '0';
      });
    } catch (e) {
      _showError('Errore durante l\'aggiornamento della quantità: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() => errorMessage = message);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (productInfo != null) ...[
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Nome prodotto: ${productInfo!.Nome}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Quantità attuale: $totalQuantity',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Quantità da aggiungere: ${widget.quantitaDiRientro}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Posizione: ${widget.orderPosition}',
                      style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildQuantityInput(),
          const SizedBox(height: 20),
          _buildSaveButton(),
          const SizedBox(height: 30),
          _buildScanAnotherButton(),
        ],
      ],
    );
  }

  Widget _buildQuantityInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          labelText: 'Nuova quantità',
          labelStyle: const TextStyle(fontSize: 24),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: 180,
      height: 60,
      child: ElevatedButton(
        onPressed: _saveQuantity,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          textStyle: const TextStyle(fontSize: 22),
        ),
        child: const Text('Salva', style: TextStyle(fontSize: 24)),
      ),
    );
  }

  Widget _buildScanAnotherButton() {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            scannedBarcode = null;
            productInfo = null;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CaricaScaricaPage(
                warehouseId: widget.warehouseId,
                userId: widget.userId,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          textStyle: const TextStyle(fontSize: 20),
        ),
        child: const Text('Scansiona un altro prodotto'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner di Codici a Barre'),
        backgroundColor: Colors.blueAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else ...[
                  if (scannedBarcode != null) const SizedBox(height: 16),
                  if (productInfo != null) _buildProductInfo(),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
