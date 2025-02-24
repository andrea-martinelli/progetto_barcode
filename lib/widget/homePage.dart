import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/widget/caricaScaricaPage.dart';
import 'package:progetto_barcode/providers.dart'; // Importa il provider
import 'package:progetto_barcode/widget/loginPage.dart'; // Assicurati di importare LoginPage

class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<dynamic> stockData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchStockData(); // Inizializza con id e reference vuoti
  }

  Future<void> _fetchStockData() async {
    try {
      final productRepository = ref.read(productRepositoryProvider);
      final response = await productRepository.fetchGetStock();
     
      setState(() {
        stockData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Errore durante il caricamento: $e';
        isLoading = false;
      });
    }
  }

  List<Widget> _buildWarehouseButtons() {
    final userId = ref.read(userIdProvider); 

    return stockData.map((stock) {
      final warehouseId = stock['IDMagazzino'];
      final reference = stock['Nome_Magazzino'] ?? 'N/A';
  
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: ElevatedButton(
            onPressed: () {
              ref.read(warehouseIdProvider.notifier).state = warehouseId;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CaricaScaricaPage(
                    warehouseId: warehouseId,
                    userId: userId!,
                  ),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$reference',
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // Funzione per mostrare l'AlertDialog di conferma logout
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma Logout'),
          content: const Text('Sei sicuro di voler uscire?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi la finestra di dialogo
              },
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi la finestra di dialogo
                _logout(); // Esegui il logout
              },
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  // Funzione per gestire il logout
  void _logout() {
    // Reset dello stato dell'utente
    ref.read(userIdProvider.notifier).state = null;

    // Naviga verso la pagina di login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona Magazzino'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout, // Aggiungi l'AlertDialog qui
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage.isNotEmpty
                  ? Text(errorMessage)
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildWarehouseButtons(),
                      ),
                    ),
        ),
      ),
    );
  }
}

