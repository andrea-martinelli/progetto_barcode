import 'package:progetto_barcode/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/widget/ModificaMaterialePage.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class MaterialiPage extends ConsumerStatefulWidget {
  final int warehouseId; // ID del magazzino selezionato
  final int userId;

  MaterialiPage({required this.warehouseId, required this.userId});

  @override
  _MaterialiPage createState() => _MaterialiPage();
}

class _MaterialiPage extends ConsumerState<MaterialiPage> {
  List<Map<String, dynamic>> materials = [];
  bool isLoading = true;
  String errorMessage = '';
  String scannedBarcode =
      ''; // Variabile per memorizzare il risultato del barcode scansionato

  @override
  void initState() {
    super.initState();
    _fetchMateriali(widget.warehouseId,
        ref.read(userIdProvider)); // Chiamata API per recuperare gli ordini
  }

  Future<void> _fetchMateriali(IdMagazzino, userId) async {
    try {
      // Recupera il repository dal provider
      final repository = ref.read(productRepositoryProvider);

      final fetchedMaterials =
          await repository.fetchMateriali(IdMagazzino, userId);
      setState(() {
        materials = fetchedMaterials;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        // errorMessage = 'Errore durante il caricamento degli ordini: $e';
        isLoading = false;
      });
    }
  }

  // Funzione per scansionare il barcode
  Future<void> _scanBarcode() async {
    try {
      var result =
          await BarcodeScanner.scan(); // Avvia la fotocamera per la scansione

      if (result.rawContent.isNotEmpty) {
        // Se la scansione è andata a buon fine e il barcode non è vuoto
        final scannedBarcode = result.rawContent;

        // Cerca il materiale corrispondente al barcode scansionato
        final material = materials.firstWhere(
          (m) => m['barcode'] == scannedBarcode,
          orElse: () => {},
        );

        if (material.isNotEmpty) {
          // Aggiorna il warehouseId nel provider
          ref.read(warehouseIdProvider.notifier).state = widget.warehouseId;

          // Naviga verso la pagina ModificaMaterialePage con i dati scansionati
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModificaMaterialePage(
                warehouseId: widget.warehouseId,
                userId: widget.userId,
                materialId: material['id'],
                nome: material['nome'],
                barcode: material['barcode'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        //    errorMessage = 'Errore durante la scansione del barcode: $e';
      });
    }
  }

  // Funzione per costruire la lista di materiali
  List<Widget> _buildMaterialList() {
    return materials.map((materiali) {
      final materialId = materiali['id'];
      final materialName = materiali['nome'];
      final materialBarcode = materiali['barcode'];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              backgroundColor: Colors.blueGrey[800], // Colore di sfondo
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12.0), // Bottone arrotondato
              ),
              elevation: 6, // Aggiungi ombra per un effetto moderno
            ),
            onPressed: () {
              // Aggiorna il warehouseId nel provider
              ref.read(warehouseIdProvider.notifier).state = widget.warehouseId;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModificaMaterialePage(
                    warehouseId: widget.warehouseId,
                    userId: widget.userId,
                    materialId: materialId,
                    nome: materialName,
                    barcode: materialBarcode,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Ordine: $materialId',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Colore del testo bianco
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nome prodotto: $materialName',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70, // Colore del testo più chiaro
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Barcode: $materialBarcode',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // Bottoni e lista dei materiali
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona Materiali'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage.isNotEmpty
                  ? Text(errorMessage)
                  : Column(
                      children: [
                        // Il pulsante per la scansione rimane sopra e fisso
                        ElevatedButton.icon(
                          onPressed: _scanBarcode,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Scansiona Barcode'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white70,
                            padding: const EdgeInsets.all(16.0),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // La lista dei materiali sarà scrollabile
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildMaterialList(),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
