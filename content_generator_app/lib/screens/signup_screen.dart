import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleSignup() async {
    // 1. Validaciones básicas
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, llena todos los campos")));
      return;
    }

    setState(() => _isLoading = true);

    // 2. Llamada a la API
    final success = await ApiService.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        // 3. ÉXITO: Navegar a Crear Perfil (Borramos historial para que no vuelva al login)
        // Un usuario nuevo SIEMPRE necesita crear organización
        print("🚀 Navegando a Create Profile...");
        Navigator.pushNamedAndRemoveUntil(
            context, '/create-profile', (route) => false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Error al registrar. El email podría estar en uso."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ICONO BONITO
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF9F5FF),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.person_add,
                    color: Color(0xFF4461F2), size: 32),
              ),
            ),
            const SizedBox(height: 24),

            const Text("Crea tu cuenta",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Empieza a generar contenido viral hoy.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // CAMPOS DE TEXTO
            _buildTextField(
                "Nombre completo", "Ej. Juan Pérez", _nameController),
            const SizedBox(height: 20),
            _buildTextField("Email", "tu@email.com", _emailController),
            const SizedBox(height: 20),
            _buildTextField(
                "Contraseña", "Mínimo 8 caracteres", _passwordController,
                isPassword: true),

            const SizedBox(height: 32),

            // BOTÓN REGISTRO
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4461F2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Registrarme",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF344054))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
