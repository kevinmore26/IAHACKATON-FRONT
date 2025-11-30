import 'package:flutter/material.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll(_scrollController1, 20);
      _startAutoScroll(_scrollController2, 15);
    });
  }

  void _showDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // para que pueda ocupar más alto
      backgroundColor: Colors.transparent, // para ver el redondeado lindo
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45, // 45% de alto al abrir
          minChildSize: 0.3, // mínimo 30%
          maxChildSize: 0.9, // máximo 90%
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    offset: Offset(0, -4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  // barrita de arrastre
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Título
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Detalles del plan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Contenido scrolleable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: const [
                        Text(
                          "• Punto 1: descripción del beneficio.\n"
                          "• Punto 2: otro detalle importante.\n"
                          "• Punto 3: condiciones, límites, etc.\n\n"
                          "Aquí puedes meter lo que quieras: "
                          "texto, iconos, filas, etc.",
                        ),
                      ],
                    ),
                  ),

                  // Botón de acción abajo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // aquí podrías disparar algo más, tipo ir a signup
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text("Entendido"),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startAutoScroll(ScrollController controller, int durationSeconds) {
    if (!controller.hasClients) return;
    try {
      double maxScroll = controller.position.maxScrollExtent;
      double currentScroll = controller.offset;
      double target = currentScroll >= maxScroll ? 0.0 : maxScroll;

      controller
          .animateTo(
        target,
        duration: Duration(seconds: durationSeconds),
        curve: Curves.linear,
      )
          .then((_) {
        if (mounted) _startAutoScroll(controller, durationSeconds);
      });
    } catch (e) {}
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
          // FONDO ANIMADO
          Row(
            children: [
              Expanded(child: _buildInfiniteColumn(_scrollController1, 0)),
              const SizedBox(width: 10),
              Expanded(child: _buildInfiniteColumn(_scrollController2, 5)),
            ],
          ),

          // DEGRADADO
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.9),
                    Colors.white
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // CONTENIDO
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tu Estrategia Viral,\nLista en Segundos.",
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1.1)),
                  const SizedBox(height: 16),
                  const Text(
                      "Deja que la IA organice, guionice y dirija tus videos.",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 40),

                  // BOTÓN 1: REGISTRO (ONBOARDING)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // CORRECCIÓN AQUÍ: Ahora va al Registro primero
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4461F2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Empezar Gratis",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BOTÓN 2: LOGIN (USUARIO VIEJO)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Usuario viejo va directo al Login
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text("¿Ya tienes cuenta? Inicia Sesión",
                          style: TextStyle(
                              color: Color(0xFF4461F2),
                              fontWeight: FontWeight.bold)),
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

  Widget _buildInfiniteColumn(ScrollController controller, int seed) {
    return ListView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final double height = (200 + (index * seed * 10) % 150).toDouble();
        return Container(
          height: height,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(
                  'https://picsum.photos/300/${height.toInt()}?random=$index$seed'),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
