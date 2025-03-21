import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/MaterialiPage.dart';

class ModificaMaterialePage extends ConsumerStatefulWidget {
  const ModificaMaterialePage(
      {super.key,
      required this.warehouseId,
      required this.userId,
      required this.materialId,
      required this.barcode,
      required this.nome});

  final int warehouseId;
  final int userId;
  final int materialId;
  final String barcode;
  final String nome;

  @override
  _ModificaMaterialiPageState createState() => _ModificaMaterialiPageState();
}

class _ModificaMaterialiPageState extends ConsumerState<ModificaMaterialePage> {
  bool isLoading = false;
  String? errorMessage;
  TextEditingController _giacenzaController = TextEditingController();
  String? selectedOperation; // Operazione selezionata (Carico o Scarico)
  String? selectedPosition; // Posizione selezionata

  @override
  void initState() {
    super.initState();
    // Quando la pagina viene caricata, chiama l'API per ottenere le posizioni del materiale
    _fetchMaterialPositions();
  }

  @override
  void dispose() {
    _giacenzaController.dispose();
    super.dispose();
  }

  // Metodo per ottenere le posizioni del materiale dall'API
  Future<void> _fetchMaterialPositions() async{ 
    setState(() => isLoading = true);

    try {
      final repository = ref.read(productRepositoryProvider);
      final positions = await repository.fetchPosizioneMateriali(
          widget.materialId, widget.warehouseId, widget.userId);

          // Estrai solo le posizioni dalla risposta dell'API
    final List<String> extractedPositions = positions
        .map<String>((position) => position['posizione'] as String)
        .toList();
        
      // Aggiorna il provider con le posizioni ricevute dall'API
      ref.read(materialpositionProvider.notifier).state = extractedPositions;

      setState(() {
         selectedPosition = extractedPositions.isNotEmpty
          ? extractedPositions.first
          : null;
      });
    } catch (e) {
      _showError('Errore durante il recupero delle posizioni: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  
  Future<void> _saveQuantity() async {
    setState(() => isLoading = true);

    final productRepository = ref.read(productRepositoryProvider);

    try {
      await productRepository.updateMaterialQuantityOnServer(
        widget.barcode,
        widget.userId,
        widget.warehouseId,
        widget.materialId,
      );

      _showMessage('Quantità aggiornata con successo');
      setState(() {
        _giacenzaController.text = '0';
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

  Widget _buildMaterialInfo() {
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
            Text('Nome materiale: ${widget.nome}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            SizedBox(height: 8),
            Text('Barcode: ${widget.barcode}',
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            SizedBox(height: 8),
            Text('Id materiale: ${widget.materialId}',
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            SizedBox(height: 20),
            _buildQuantityInput(),
          ],
        ),
      ),
    );
  }

  // Widget che gestisce il menu a tendina per Carico/Scarico e Posizione
Widget _buildQuantityInput() {
  // Otteniamo le posizioni dal provider
  final materialPositions = ref.watch(materialpositionProvider);
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // Primo menu a tendina: Carico o Scarico
      DropdownButtonFormField<String>(
        value: selectedOperation,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
           //   color: Colors.teal, // Colore del bordo
              width: 2.0, // Spessore del bordo
            ),
          ),
          labelText: 'Seleziona operazione',
          labelStyle: const TextStyle(fontSize: 16, ),
          filled: true,
         // fillColor: Colors.teal[50], // Colore dello sfondo del campo
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
       //   prefixIcon: const Icon(Icons.build, ), // Icona a sinistra
        ),
   //     dropdownColor: Colors.teal[50], // Colore dello sfondo del menu dropdown
        icon: const Icon(Icons.arrow_drop_down, ), // Icona della freccia del dropdown
        items: const [
          DropdownMenuItem(
            value: 'Carico',
            child: Text('Carico'),
          ),
          DropdownMenuItem(
            value: 'Scarico',
            child: Text('Scarico'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedOperation = value; // Aggiorna il valore selezionato
            selectedPosition = null; // Resetta la posizione quando si cambia operazione
          });
        },
      ),
      const SizedBox(height: 10), // Spazio tra i due dropdown

      // Secondo menu a tendina: Posizione (mostrato solo se un'operazione è selezionata)
      if (selectedOperation != null && materialPositions.isNotEmpty == true)
        DropdownButtonFormField<String>(
          value: selectedPosition,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.teal, // Colore del bordo
                width: 2.0, // Spessore del bordo
              ),
            ),
            labelText: 'Seleziona posizione',
            labelStyle: const TextStyle(fontSize: 14, ),
            filled: true,
         //   fillColor: Colors.teal[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            prefixIcon: const Icon(Icons.place, ), // Icona a sinistra
          ),
         // dropdownColor: Colors.teal[50], // Colore dello sfondo del dropdown
          icon: const Icon(Icons.arrow_drop_down,), // Icona del dropdown
          items: materialPositions.map<DropdownMenuItem<String>>((position) {
            return DropdownMenuItem<String>(
              value: position,
              child: Text(position),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedPosition = value; // Aggiorna la posizione selezionata
            });
          },
        ),

      const SizedBox(height: 10),

      // Campo per la quantità
      TextFormField(
        controller: _giacenzaController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
          //    color: Colors.teal, // Colore del bordo
              width: 2.0, // Spessore del bordo
            ),
          ),
          labelText: 'Quantità',
          labelStyle: const TextStyle(fontSize: 14,),
          filled: true,
       //   fillColor: Colors.teal[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
         // prefixIcon: const Icon(Icons.production_quantity_limits, ),
        ),
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica materiale'),
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
                      ? _buildErrorMessage()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildMaterialInfo(),
                            SizedBox(height: 20),
                            _buildSaveButton(),
                            SizedBox(height: 20),
                            _buildScanAnotherButton(),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget per mostrare il messaggio di errore
  Widget _buildErrorMessage() {
    return Center(
      child: Text(
        errorMessage!,
        style: TextStyle(color: Colors.red, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Widget per il pulsante Salva
  Widget _buildSaveButton() {
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        onPressed: _saveQuantity, // Logica del salvataggio
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

  // Widget per il pulsante "Scansiona un altro prodotto"
  Widget _buildScanAnotherButton() {
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MaterialiPage(
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text('Scansiona un altro prodotto'),
      ),
    );
  }
}
