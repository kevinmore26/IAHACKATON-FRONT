// Archivo: ProjectsScreen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ai_video_builder_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lista de Borradores (Mock)
  final List<Map<String, dynamic>> _drafts = [
    {
      "id": "cm4...",
      "title": "Estrategia de Zapatillas (Borrador)",
      "status": "DRAFT",
      "date": "Hace 2 horas",
      "thumbnail":
          "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=200&auto=format&fit=crop"
    },
  ];
  final Set<String> _selectedIds = {};

  bool get _isSelectionMode => _selectedIds.isNotEmpty;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- TAB 1: LISTA DE BORRADORES (MOCK) ---
  Widget _buildDraftsList() {
    if (_drafts.isEmpty) {
      return const Center(
          child: Text("No tienes borradores activos.",
              style: TextStyle(color: Colors.grey)));
    }

    // Obtenemos el ID de la organización fuera del constructor de ListView
    final String? orgId = ApiService.currentOrganizationId;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _drafts.length,
      itemBuilder: (context, index) {
        final project = _drafts[index];

        return GestureDetector(
          onTap: () {
            // 🔴 FIX: VALIDACIÓN DEL ID ANTES DE NAVEGAR
            if (orgId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        "Error: Debes iniciar sesión y crear una organización.")),
              );
              return;
            }

            // 🔴 FIX: PASAMOS AMBOS IDs REQUERIDOS AL EDITOR
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AiVideoBuilderScreen(
                          ideaId: project['id']!,
                          missionTitle: project['title']!,
                          organizationId: orgId, // <-- ID DE ORG AGREGADO
                        )));
          },
          child: _buildProjectCard(project),
        );
      },
    );
  }

  // --- TAB 2: GRUPO DE GALERÍA (API REAL) ---
  Widget _buildGalleryGrid() {
    // ⚠️ ATENCIÓN: Si el orgId no está cargado, FutureBuilder fallará.
    final String? orgId = ApiService.currentOrganizationId;

    if (orgId == null) {
      return const Center(child: Text("Error: ID de organización no cargado."));
    }

    return FutureBuilder<List<dynamic>?>(
      future: ApiService.getGalleryItems(), // Llama a la nueva función
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const Center(
              child: Text("No hay videos ni imágenes en tu Galería.",
                  style: TextStyle(color: Colors.grey)));
        }

        final galleryItems = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columnas tipo galería
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: galleryItems.length,
          itemBuilder: (context, index) {
            final item = galleryItems[index] as Map<String, dynamic>;
            final String url = item['signed_url'] ?? '';
            final String type = item['type'] ?? 'IMAGE'; // "IMAGE" o "VIDEO"
            final bool isVideo = type == 'VIDEO';

            // Usamos un id, si tu API no manda 'id', usamos la url como fallback
            final String id = (item['id'] ?? url).toString();
            final bool isSelected = _selectedIds.contains(id);

            return GestureDetector(
              onLongPress: () => _toggleSelection(id), // entra modo selección
              onTap: () {
                if (_isSelectionMode) {
                  _toggleSelection(id); // selecciona / deselecciona
                } else {
                  _showGalleryItem(context, url, type); // abre el viewer normal
                }
              },
              child: Stack(
                children: [
                  // Fondo (imagen o placeholder de video)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isVideo
                          ? Container(
                              color: Colors.black12,
                              child: const Center(
                                child: Icon(
                                  Icons.videocam,
                                  size: 32,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                          : Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                    ),
                  ),

                  // Icono de play encima solo si es video
                  if (isVideo)
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),

                  // Check de selección
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
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

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Mis Proyectos",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4461F2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4461F2),
          tabs: const [ 
            Tab(text: "Galería (Videos Finales)"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ 
          _buildGalleryGrid(), // Tab 2: Galería (API Real)
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    // (código de _buildProjectCard aquí)
    final bool isCompleted = project['status'] == 'COMPLETED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            child: Image.network(
              project['thumbnail'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.movie)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project['title'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCompleted ? "Listo" : "Borrador",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(project['date'],
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  )
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          )
        ],
      ),
    );
  }

  void _showGalleryItem(BuildContext context, String url, String type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: type == 'IMAGE'
                  ? DecorationImage(
                      image: NetworkImage(url), fit: BoxFit.contain)
                  : null,
            ),
            child: type == 'VIDEO'
                ? const Center(
                    child: Text("Reproductor de Video aquí",
                        style: TextStyle(color: Colors.white)))
                : null,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar")),
          ],
        );
      },
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _exportSelected() {
    // TODO: aquí haces la lógica de exportar / compartir / lo que sea
    print("Exportando IDs: $_selectedIds");
  }
}
