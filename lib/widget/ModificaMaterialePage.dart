import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/providers.dart';
import 'package:progetto_barcode/widget/caricaScaricaPage.dart';

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

  @override
  void dispose() {
    _giacenzaController.dispose();
    super.dispose();
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
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
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

  Widget _buildQuantityInput() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: _giacenzaController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          labelText: 'Nuova quantità',
          labelStyle: TextStyle(fontSize: 20),
        ),
      ),
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
        child: const Text('Salva',
            style: TextStyle(
              fontSize: 20,
            )),
      ),
    );
  }

  // Widget per il pulsante "Scansiona un altro prodotto"
  Widget _buildScanAnotherButton() {
    return SizedBox(
      height: 70,
      child: OutlinedButton(
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: const Text('Scansiona un altro prodotto'),
      ),
    );
  }
}
