import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/data/models/product_info.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/caricaScaricaPage.dart';

class BarcodeScannerPageScarico extends ConsumerStatefulWidget {
  const BarcodeScannerPageScarico({super.key, required this.IdOrdine, required this.userId, required this.warehouseId, required this.quantitaTotale, required this.orderPosition, required this.quantitaRichiesta});
  
  final int IdOrdine;
  final int userId;
  final int warehouseId;
  final int quantitaTotale;
  final String orderPosition;
  final int quantitaRichiesta;
  @override
  _BarcodeScannerPageScaricoState createState() => _BarcodeScannerPageScaricoState();
}

class _BarcodeScannerPageScaricoState extends ConsumerState<BarcodeScannerPageScarico> {
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
    return barcode?.isNotEmpty == true  
        ? barcode!.padLeft(13, '0')
        : barcode;
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
      // int quantityChange = int.tryParse(_quantityController.text) ?? 0;

      await productRepository.updateProductScaricoQuantityOnServer(
        scannedBarcode!,
        widget.quantitaRichiesta,
        widget.IdOrdine,
        widget.userId,
      ); 

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
      children: [
        if (productInfo != null) ...[
          Text('Nome prodotto: ${productInfo!.Nome}',
              style: const TextStyle(fontSize: 22)),
          Text('Quantità attuale: $totalQuantity',
              style: const TextStyle(fontSize: 24)),
          Text('Quantità da scaricare: ${widget.quantitaRichiesta}',
              style: const TextStyle(fontSize: 24)),
           Text('Posizione: ${widget.orderPosition}',
          style: const TextStyle(fontSize: 24)),

          const SizedBox(height: 40),
          _buildQuantityInput(),
          const SizedBox(height: 20),
          // _buildQuantityButtons(),
          // const SizedBox(height: 30),
          SizedBox(
            width: 180,
            height: 100,
            child: ElevatedButton(
              onPressed: _saveQuantity,
              child: const Text('Salva', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 180,
            height: 100,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  scannedBarcode = null;
                  productInfo = null;
                });
                     // Poi naviga alla pagina CaricaScaricaPage
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
              child: const Text('Scansiona un altro prodotto', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuantityInput() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Nuova quantità',
          labelStyle: TextStyle(fontSize: 30),
        ),
      ),
    );
  }

  //Widget _buildQuantityButtons() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       _buildIncrementButton('-', () {
  //         setState(() {
  //           int currentQuantity = int.tryParse(_quantityController.text) ?? 0;
  //           _quantityController.text = (currentQuantity - 1).toString();
  //         });
  //       }),
  //       const SizedBox(width: 30),
  //       _buildIncrementButton('+', () {
  //         setState(() {
  //           int currentQuantity = int.tryParse(_quantityController.text) ?? 0;
  //           _quantityController.text = (currentQuantity + 1).toString();
  //         });
  //       }),
  //     ],
  //   );
  // }

  // Widget _buildIncrementButton(String label, VoidCallback onPressed) {
  //   return SizedBox(
  //     width: 120,
  //     height: 80,
  //     child: ElevatedButton(
  //       onPressed: onPressed,
  //       child: Text(label, style: const TextStyle(fontSize: 36)),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Scanner')), 
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
