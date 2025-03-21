import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/data/models/product_info.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/caricaScaricaPage.dart';

class BarcodeScannerPageScarico extends ConsumerStatefulWidget {
  const BarcodeScannerPageScarico({
    super.key,
    required this.IdOrdine,
    required this.userId,
    required this.warehouseId,
    required this.quantitaTotale,
    required this.quantitaRichiesta,
    required this.barcode,
    //required this.posizione,
    required this.materialiId,
  });
  final int IdOrdine;
  final int userId;
  final int warehouseId;
  final int quantitaTotale;
  final int quantitaRichiesta;
  final String barcode;
//  final String posizione;
  final int materialiId;

  @override
  _BarcodeScannerPageScaricoState createState() =>
      _BarcodeScannerPageScaricoState();
}

class _BarcodeScannerPageScaricoState
    extends ConsumerState<BarcodeScannerPageScarico> {
  ProductInfo? productInfo;
  bool isLoading = false;
  String? errorMessage;
  int totalQuantity = 0;
  String? selectedPosizione; // Per la posizione selezionata

//  List<String> posizioni = []; // Esempio di lista di posizioni

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
    // Inizializza la lista delle posizioni con il valore passato
    //posizioni = [widget.posizione];
    // Ottieni i dettagli del prodotto appena la pagina viene inizializzata
    _fetchProductDetails(widget.barcode);
   // _fetchPosizioniPerOrdini();
  }

  // Future<void> _fetchPosizioniPerOrdini() async {
  //   setState(() => isLoading = true);

  //   try {
  //     final repository = ref.read(productRepositoryProvider);

  //     final posizioneResponse = await repository.fetchPosizioneMaterialiScarico(
  //         widget.materialiId, widget.warehouseId, widget.userId);

  //     final List<String> extractedPositions = posizioneResponse
  //         .map<String>((position) => position['posizione'] as String)
  //         .toList();

  //     ref.read(materialpositionProvider.notifier).state = extractedPositions;

  //     setState(() {
  //       selectedPosizione =
  //           extractedPositions.isNotEmpty ? extractedPositions.first : null;
  //     });
  //   } catch (e) {
  //     print("Errore nel recupero delle posizioni: $e");
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }
// print("Errore nel recupero della posizione per l'ordine ${ordine['IDOrdine']}: $e");

  //  print("Ordini con posizioni aggiornate: $ordini");

  // Aggiorna lo stato con gli ordini modificati



  // Metodo per ottenere le posizioni del materiale dall'API
  Future<void> _fetchMaterialOrdiniScarico() async {
    setState(() => isLoading = true);

    try {
      final repository = ref.read(productRepositoryProvider);
      final positions = await repository.fetchPosizioneMaterialiScarico(
          widget.materialiId, widget.warehouseId, widget.userId);

      final List<String> extractedPositions = positions
          .map<String>((position) => position['posizione'] as String)
          .toList();

      // Aggiorna il provider con le posizioni ricevute dall'API
      ref.read(materialpositionProvider.notifier).state = extractedPositions;

      setState(() {
        selectedPosizione =
            extractedPositions.isNotEmpty ? extractedPositions.first : null;
      });
    } catch (e) {
      _showError('Errore durante il recupero delle posizioni: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchProductDetails(String barcode) async {
    try {
      setState(() => isLoading = true);

      final productRepository = ref.read(productRepositoryProvider);
      final product = await productRepository.getProductByBarcode(barcode);
      print("Risposta dell'API: $product"); // Debug

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
      await productRepository.updateProductScaricoQuantityOnServer(
        widget.barcode, // Usa il barcode passato dal costruttore
        widget.quantitaRichiesta,
        widget.IdOrdine,
        widget.userId,
        // selectedPosizione, // Includi la posizione selezionata
      );

      _showMessage('Quantità aggiornata con successo');
      setState(() {
        _quantityController.text = '0';
        selectedPosizione = null; // Resetta la selezione della posizione
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
    if (productInfo == null) {
      return const Center(child: Text('Prodotto non trovato'));
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome prodotto: ${productInfo!.Nome}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 8),
            Text('Quantità attuale: $totalQuantity',
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Quantità da scaricare: ${widget.quantitaRichiesta}',
                style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildPosizioneDropdown(), // Aggiungi il menu a tendina per le posizioni
            const SizedBox(height: 20),
            _buildQuantityInput(),
          ],
        ),
      ),
    );
  }

  // Widget per il menu a tendina per la selezione della posizione
  Widget _buildPosizioneDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedPosizione,
      items: ref.watch(materialpositionProvider).map<DropdownMenuItem<String>>(
        (String posizione) {
          return DropdownMenuItem<String>(
            value: 'posizione',
            child: Text(posizione),
          );
        },
      ).toList(),
      decoration: InputDecoration(
        labelText: 'Seleziona una posizione',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (String? newValue) {
        setState(() {
          selectedPosizione = newValue;
        });
      },
    );
  }

  Widget _buildQuantityInput() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 2.0,
          ),
        ),
        labelText: 'Quantità da scaricare',
        labelStyle: const TextStyle(fontSize: 14),
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildProductInfo(),
                            const SizedBox(height: 20),
                            _buildSaveButton(),
                            const SizedBox(height: 20),
                            _buildScanAnotherButton(),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        onPressed: selectedPosizione == null
            ? null // Disabilita il pulsante se la posizione non è selezionata
            : _saveQuantity,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text(
          'Salva',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildScanAnotherButton() {
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        onPressed: () {
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
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text('Scansiona un altro prodotto'),
      ),
    );
  }
}
