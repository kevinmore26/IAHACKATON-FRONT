import 'package:content_generator_app/screens/mission_detail_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Estado mock de progreso
  bool _mission1Completed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Quitamos botón atrás
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Semana 1: Ventas 🔥",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            // Barra de progreso animada
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _mission1Completed ? 0.35 : 0.05,
                backgroundColor: const Color(0xFFEAECF0),
                color: const Color(0xFF4461F2),
                minHeight: 8,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: Colors.black),
              onPressed: () {},
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN 1: HOY ---
            const Text(
              "TU MISIÓN DE HOY",
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // TARJETA ACTIVA (Hero Card)
            GestureDetector(
              onTap: _mission1Completed
                  ? null
                  : () {
                      // EN LUGAR DE IR DIRECTO A RECORDING, VAMOS AL DETALLE
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MissionDetailScreen()),
                      ).then((result) {
                        // Si vuelven con éxito (true), marcamos completado
                        if (result == true) {
                          setState(() => _mission1Completed = true);
                        }
                      });
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: _mission1Completed
                      ? const LinearGradient(colors: [
                          Colors.white,
                          Colors.white
                        ]) // Si completado, blanco
                      : const LinearGradient(
                          colors: [
                            Color(0xFF4461F2),
                            Color(0xFF354dbf)
                          ], // Si no, Azul Brand
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4461F2).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chip de Estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _mission1Completed
                            ? Colors.green.withOpacity(0.1)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _mission1Completed
                                ? Icons.check_circle
                                : Icons.schedule,
                            color: _mission1Completed
                                ? Colors.green
                                : Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _mission1Completed ? "COMPLETADO" : "PENDIENTE",
                            style: TextStyle(
                              color: _mission1Completed
                                  ? Colors.green
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Video 1: El Gancho",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _mission1Completed ? Colors.black : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Atrapa a tu audiencia en los primeros 3 segundos con este script de controversia.",
                      style: TextStyle(
                        fontSize: 16,
                        color: _mission1Completed
                            ? const Color(0xFF667085)
                            : Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (!_mission1Completed)
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Comenzar Misión",
                            style: TextStyle(
                              color: Color(0xFF4461F2),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- SECCIÓN 2: LÍNEA DE TIEMPO ---
            const Text(
              "TU RUTA DE LA SEMANA",
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de próximos pasos
            _buildTimelineTile(
              day: "MAÑANA",
              title: "Video 2: Educación",
              isLocked: true,
              isLast: false,
            ),
            _buildTimelineTile(
              day: "MIÉRCOLES",
              title: "Video 3: Venta Directa",
              isLocked: true,
              isLast: true,
            ),
          ],
        ),
      ),

      // Navbar simple
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4461F2),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: "Plan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.videocam_outlined), label: "Grabar"),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: "Tendencias"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Perfil"),
        ],
      ),
    );
  }

  Future<void> _goToCamera(BuildContext context) async {
    // Vamos a la cámara y esperamos si completó
    final result = await Navigator.pushNamed(context, '/recording');
    if (result == true) {
      setState(() {
        _mission1Completed = true;
      });
      // Confeti o feedback visual aquí
    }
  }

  Widget _buildTimelineTile(
      {required String day,
      required String title,
      required bool isLocked,
      required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Columna Izquierda (Línea)
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: isLocked
                          ? const Color(0xFFF2F4F7)
                          : const Color(0xFF4461F2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        if (!isLocked)
                          BoxShadow(
                              color: const Color(0xFF4461F2).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                      ]),
                  child: Icon(
                    isLocked ? Icons.lock : Icons.check,
                    size: 14,
                    color: isLocked ? const Color(0xFF98A2B3) : Colors.white,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFEAECF0),
                    ),
                  ),
              ],
            ),
          ),

          // Contenido Derecha
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF98A2B3))),
                          const SizedBox(height: 4),
                          Text(title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isLocked
                                      ? const Color(0xFF667085)
                                      : Colors.black)),
                        ],
                      ),
                    ),
                    if (isLocked)
                      const Icon(Icons.lock_outline,
                          color: Color(0xFFD0D5DD), size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
