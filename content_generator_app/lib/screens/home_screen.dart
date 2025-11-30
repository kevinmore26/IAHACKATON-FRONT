import 'package:content_generator_app/screens/recording_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mission_detail_screen.dart';
import '../services/api_service.dart';
import 'ProjectsScreen.dart'; // <--- IMPORTA TU PANTALLA DE PROYECTOS
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Controla qué pestaña está activa
  List<dynamic> _ideas = [];
  bool _isLoading = true;
  String _userName = "Creador";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadHomeData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Creador";
    });
  }

  Future<void> _loadHomeData() async {
    final ideas = await ApiService.getHomeData();
    if (mounted) {
      setState(() {
        _ideas = ideas ?? [];
        _isLoading = false;
      });
    }
  }

  // --- LÓGICA DE NAVEGACIÓN ---
// En home_screen.dart

// --- LÓGICA DE NAVEGACIÓN ---
  void _onItemTapped(int index) {
    if (index == 1) {
      // SI TOCA "GRABAR" (ÍNDICE 1)

      // 1. Validar si hay ideas y si el usuario está cargado
      if (_ideas.isEmpty || ApiService.currentOrganizationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('⚠️ Espera a que cargue la estrategia.')),
        );
        return;
      }

      // 2. Navegación directa (push) pasando los IDs requeridos
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecordingScreen(
            // Asumimos que la misión activa es la primera de la lista
            ideaId: _ideas[0]['id'] ?? 'default_idea',
            organizationId:
                ApiService.currentOrganizationId!, // Org ID del servicio
          ),
        ),
      );
    } else {
      // SI ES PLAN, PROYECTOS O PERFIL, CAMBIAMOS LA VISTA
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // --- MODAL DE PREVIEW (LO QUE FALTABA) ---
  void _showPreviewModal(BuildContext context, String title, String script) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(8)),
                    child:
                        const Icon(Icons.lock_clock, color: Color(0xFF667085)),
                  ),
                  const SizedBox(width: 12),
                  const Text("Próximamente",
                      style: TextStyle(
                          color: Color(0xFF667085),
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                "Sneak Peek: \"${script.length > 80 ? '${script.substring(0, 80)}...' : script}\"",
                style: const TextStyle(
                    color: Color(0xFF667085),
                    height: 1.5,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              const Text(
                "Completa la misión de hoy para desbloquear el guion completo y las herramientas de grabación.",
                style: TextStyle(color: Color(0xFF344054), fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAECF0),
                    disabledBackgroundColor: const Color(0xFFEAECF0),
                    disabledForegroundColor: const Color(0xFF98A2B3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Bloqueado"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // DECIDIMOS QUÉ MOSTRAR SEGÚN EL ÍNDICE
    Widget bodyContent;

    switch (_selectedIndex) {
      case 0:
        bodyContent = _buildPlanView(); // Vista del Timeline
        break;
      case 2:
        bodyContent =
            const ProjectsScreen(); // Vista de Proyectos (Tab 2 ahora)
        break;
      case 3:
        bodyContent = const ProfileScreen();
        break;
      default:
        bodyContent = _buildPlanView();
    }

    return Scaffold(
      backgroundColor: Colors.white,

      // SOLO MOSTRAMOS EL APPBAR SI ESTAMOS EN EL HOME (PLAN)
      // Porque ProjectsScreen ya tiene su propio AppBar
      appBar: _selectedIndex == 0 ? _buildHomeAppBar() : null,

      body: bodyContent, // AQUÍ CAMBIA EL CONTENIDO DINÁMICAMENTE

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4461F2),
        unselectedItemColor: const Color(0xFF98A2B3),
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // <--- AQUÍ CONECTAMOS LA LÓGICA
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: "Plan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.videocam_outlined), label: "Grabar"),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_outlined), label: "Proyectos"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Perfil"),
        ],
      ),
    );
  }

  // --- VISTA 1: EL PLAN (Lo que tenías antes en el body) ---
  Widget _buildPlanView() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hola, $_userName 👋",
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF101828),
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            "Tu plan para dominar las redes está listo.",
            style:
                TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.4),
          ),
          const SizedBox(height: 24),

          // TARJETA GRADIENTE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF4461F2), Color(0xFF354DBF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4461F2).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.rocket_launch,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Objetivo Semanal",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0)),
                      const SizedBox(height: 4),
                      const Text("Estrategia de Ventas",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text("${_ideas.length} videos",
                      style: const TextStyle(
                          color: Color(0xFF4461F2),
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Text("TU RUTA DE ACCIÓN",
              style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 16),

          // LISTA
          if (_ideas.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text("No hay un plan activo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ideas.length,
              itemBuilder: (context, index) {
                final item = _ideas[index];
                return _buildTimelineItem(
                  idea: item,
                  title: item['title'] ?? "Misión sin título",
                  script: item['script'] ?? "...",
                  date: _getDateForIndex(index),
                  isActive: index == 0,
                  isLast: index == _ideas.length - 1,
                );
              },
            ),
        ],
      ),
    );
  }

  // --- COMPONENTES AUXILIARES ---

  AppBar _buildHomeAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 24,
      title: Row(
        children: [
          SvgPicture.asset('lib/assets/Logo_icon_luqebb.svg', height: 32),
          const SizedBox(width: 8),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 24.0),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFF2F4F7),
            child: CircleAvatar(
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=12'),
                radius: 20),
          ),
        )
      ],
    );
  }

  String _getDateForIndex(int index) {
    DateTime date = DateTime.now().add(Duration(days: index));
    if (index == 0) return "Hoy, ${date.day}/${date.month}";
    if (index == 1) return "Mañana, ${date.day}/${date.month}";
    return "Día ${index + 1}";
  }

  Widget _buildTimelineItem(
      {required Map<String, dynamic> idea,
      required String title,
      required String script,
      required String date,
      required bool isActive,
      required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF4461F2) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isActive
                            ? const Color(0xFF4461F2)
                            : const Color(0xFFEAECF0),
                        width: isActive ? 0 : 2),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                                color: const Color(0xFF4461F2).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ]
                        : null,
                  ),
                  child: isActive
                      ? const Center(
                          child: CircleAvatar(
                              backgroundColor: Colors.white, radius: 4))
                      : null,
                ),
                if (!isLast)
                  Expanded(
                      child:
                          Container(width: 2, color: const Color(0xFFEAECF0))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0, left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? const Color(0xFF101828)
                              : const Color(0xFF344054))),
                  const SizedBox(height: 4),
                  Text(date,
                      style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  if (isActive) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) =>
                                      MissionDetailScreen(ideaData: idea)));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4461F2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Text("Comenzar Misión",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _showPreviewModal(context, title, script),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Text("Ver detalles",
                              style: TextStyle(
                                  color: Color(0xFF4461F2),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              size: 16, color: Color(0xFF4461F2))
                        ]),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
