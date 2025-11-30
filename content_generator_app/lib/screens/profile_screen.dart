import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // Importa ApiService para limpiar variables

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "Cargando...";
  String _orgName = "Mi Negocio";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Creador";
      // Podrías guardar el nombre de la org al crearla, por ahora hardcodeamos o ponemos genérico
      _orgName = "Estrategia Viral"; 
    });
  }

  Future<void> _handleLogout() async {
    // 1. Mostrar confirmación
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Cerrar Sesión?"),
        content: const Text("Tendrás que ingresar tus datos nuevamente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Salir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // 2. Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // ¡Borrón y cuenta nueva!

      // 3. Limpiar variables estáticas del ApiService (IMPORTANTE)
      // (Si no tienes un método logout estático, reiniciar la app suele bastar, 
      // pero esto es más limpio. Asumiendo que puedes acceder a las variables o reiniciar el estado).
      // Lo ideal es reiniciar la app navegando al Login y borrando historial.
      
      if (mounted) {
        // 4. Navegar al Login y matar todo lo anterior
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
        title: const Text("Mi Perfil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // AVATAR GIGANTE
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _orgName,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            
            const SizedBox(height: 40),

            // OPCIONES DE MENÚ
            _buildProfileOption(Icons.person_outline, "Editar Datos Personales"),
            _buildProfileOption(Icons.business, "Configuración del Negocio"),
            _buildProfileOption(Icons.credit_card, "Suscripción (Pro)"),
            _buildProfileOption(Icons.notifications_outlined, "Notificaciones"),
            
            const SizedBox(height: 40),

            // BOTÓN CERRAR SESIÓN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Text("Versión 1.0.0 (MVP)", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {}, // Futura implementación
    );
  }
}