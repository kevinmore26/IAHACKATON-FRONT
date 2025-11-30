import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Controladores para la animación del scroll infinito
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Iniciamos el auto-scroll suave
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll(_scrollController1, 20);
      _startAutoScroll(_scrollController2, 15); // Velocidad diferente para efecto paralaje
    });
  }

  void _startAutoScroll(ScrollController controller, int durationSeconds) {
    if (!controller.hasClients) return;
    try {
      double maxScroll = controller.position.maxScrollExtent;
      double currentScroll = controller.offset;
      
      // Si llegamos al final, volvemos al principio, si no, avanzamos
      double target = currentScroll >= maxScroll ? 0.0 : maxScroll;
      
      controller.animateTo(
        target,
        duration: Duration(seconds: durationSeconds),
        curve: Curves.linear,
      ).then((_) {
        // Loop infinito
        if (mounted) _startAutoScroll(controller, durationSeconds);
      });
    } catch (e) {
      // Ignoramos errores de scroll si se cierra la pantalla
    }
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. FONDO "PINTEREST" ANIMADO ---
          Row(
            children: [
              Expanded(child: _buildInfiniteColumn(_scrollController1, 0)),
              const SizedBox(width: 10), // Separación
              Expanded(child: _buildInfiniteColumn(_scrollController2, 5)),
            ],
          ),

          // --- 2. DEGRADADO BLANCO (Para que se lea el texto) ---
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // --- 3. CONTENIDO PRINCIPAL ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge decorativo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF4461F2), size: 16),
                        SizedBox(width: 8),
                        Text("IA para Creadores", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Título grande
                  const Text(
                    "Tu Estrategia de\nContenido Viral,\nLista en Segundos.",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF101828),
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtítulo
                  const Text(
                    "No más bloqueos creativos. Deja que la IA organice, guionice y dirija tus videos para vender más.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF667085),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Botón Gigante
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4461F2),
                        foregroundColor: Colors.white,
                        elevation: 10,
                        shadowColor: const Color(0xFF4461F2).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Empezar Gratis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Constructor de columnas infinitas con imágenes mock
  Widget _buildInfiniteColumn(ScrollController controller, int seed) {
    return ListView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(), // El usuario no puede scrollear, es automático
      itemBuilder: (context, index) {
        // Altura aleatoria para efecto "Masonry" (Ladrillos)
        final double height = (200 + (index * seed * 10) % 150).toDouble();
        return Container(
          height: height,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              // Usamos Picsum para imágenes aleatorias bonitas
              image: NetworkImage('https://picsum.photos/300/${height.toInt()}?random=$index$seed'),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}