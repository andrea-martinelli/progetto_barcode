import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progetto_barcode/domain/repositories/product_repository.dart';
import 'package:progetto_barcode/widget/homePage.dart'; // Importa la tua HomePage
import 'package:progetto_barcode/providers.dart'; // Importa il provider del repository

class LoginPage extends ConsumerStatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Imposta lo stato su "caricamento" per mostrare un indicatore
    setState(() {
      _isLoading = true;
    });

    // Recupera il ProductRepository dal provider
    final ProductRepository = ref.read(productRepositoryProvider);

    try {
      final username = _emailController.text;
      final password = _passwordController.text;

      // Chiama la funzione di login
      final response = await ProductRepository.login(username, password);

      // Gestisci il successo del login
      if (response['success'] == true) {
        final userId = response['userId'];

         // Memorizza userId nel provider
      ref.read(userIdProvider.notifier).state = userId;


        // Naviga alla HomePage se il login ha successo
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Mostra un messaggio di errore se il login fallisce
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] )),
        );
      }
    } catch (e) {
      // Mostra un messaggio di errore in caso di eccezione
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il login, riprova')),
      );
    } finally {
      // Rimuovi lo stato di caricamento
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // CircleAvatar(
              //   radius: 60,
              //   backgroundImage: AssetImage(''), // Percorso dell'immagine
              // ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontSize: 20),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Disabilita il pulsante durante il caricamento
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Accedi',
                          style: TextStyle(fontSize: 20),
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
