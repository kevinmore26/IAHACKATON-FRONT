import 'package:flutter/material.dart';
import 'ai_video_builder_screen.dart'; // <--- 1. IMPORTAR LA NUEVA PANTALLA AQUÍ

class MissionDetailScreen extends StatefulWidget {
  const MissionDetailScreen({super.key});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  // MOCK DATA
  final String _missionTitle = "Video 1: El Gancho";
  final String _script = "POV: Eres la persona más torpe del mundo y acabas de comprarte una cartera nueva...";
  final String _visualPrompt = "Estilo Cinematográfico, iluminación suave, producto en primer plano.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detalles de la Misión", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. EL GUION
                  _buildSectionHeader("📜 Tu Guion (IA)"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Text(
                      _script,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF344054)),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // 2. ESTILO
                  _buildSectionHeader("🎨 Vibe & Estilo"),
                  const SizedBox(height: 8),
                  Text(
                    "Basado en tu perfil, sugerimos: $_visualPrompt",
                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),

          // 3. FOOTER DE ACCIONES
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("¿Cómo quieres crear este video?", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // OPCIÓN A: GRABARME (Teleprompter)
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.videocam_outlined,
                        label: "Grabarme",
                        color: Colors.black,
                        isPrimary: false,
                        onTap: () {
                          Navigator.pushNamed(context, '/recording');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // OPCIÓN B: GENERAR IA (Veo)
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.auto_awesome,
                        label: "Generar IA",
                        color: const Color(0xFF4461F2),
                        isPrimary: true,
                        onTap: () {
                          // <--- 2. AQUÍ LLAMAMOS A LA PANTALLA NUEVA
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AiVideoBuilderScreen(
                                missionTitle: _missionTitle, // Le pasamos el título
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required Color color, required bool isPrimary, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isPrimary ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(color: isPrimary ? color : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}