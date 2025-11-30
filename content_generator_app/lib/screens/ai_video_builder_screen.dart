import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // <--- ¡ESTA ES LA LÍNEA QUE FALTABA!
import 'dart:io';

class AiVideoBuilderScreen extends StatefulWidget {
  final String missionTitle;
  const AiVideoBuilderScreen({super.key, required this.missionTitle});

  @override
  State<AiVideoBuilderScreen> createState() => _AiVideoBuilderScreenState();
}

class _AiVideoBuilderScreenState extends State<AiVideoBuilderScreen> {
  // SIMULACIÓN: La IA desglosó el guion en escenas (Bloques)
  final List<Map<String, dynamic>> _scenes = [
    {
      "id": 1,
      "type": "NARRATOR",
      "duration": "5s",
      "script": "POV: Eres la persona más torpe y acabas de comprar cartera nueva...",
      "instruction": "Sube una foto tuya con cara de preocupación.",
      "image": null,
    },
    {
      "id": 2,
      "type": "SHOWCASE",
      "duration": "9s",
      "script": "¡Pero no pasa nada si es nuestra cartera mágica! ¿Se cae el café?",
      "instruction": "Sube una foto del producto siendo usado o manchado.",
      "image": null,
    },
    {
      "id": 3,
      "type": "SHOWCASE", 
      "duration": "8s",
      "script": "¿Te preocupan las llaves? Olvídate de los rayones.",
      "instruction": "Foto detalle de la textura del material.",
      "image": null,
    },
    {
      "id": 4,
      "type": "NARRATOR",
      "duration": "4s",
      "script": "Así que ya sabes, para tu vida caótica, necesitas esto.",
      "instruction": "Foto tuya sonriendo con el producto.",
      "image": null,
    },
  ];

  final ImagePicker _picker = ImagePicker(); // Ahora sí funcionará

  Future<void> _pickImage(int index) async {
    // IMPORTANTE: Manejo de errores por si el usuario cancela o no hay permisos
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _scenes[index]['image'] = File(image.path);
        });
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo cargar la imagen. Revisa los permisos.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos si todas las escenas tienen imagen
    bool isReadyToGenerate = _scenes.every((scene) => scene['image'] != null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tablero de Rodaje 🎬", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var scene in _scenes) {
                  scene['image'] = null;
                }
              });
            },
            child: const Text("Limpiar", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
      body: Column(
        children: [
          // Header Explicativo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: const Color(0xFFF9FAFB),
            width: double.infinity,
            child: const Text(
              "Completa cada bloque con una foto. La IA usará 'Veo' para animarlas y narrar el texto.",
              style: TextStyle(color: Color(0xFF667085), fontSize: 14),
            ),
          ),
          
          // Lista de Escenas (Bloques)
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _scenes.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildSceneCard(index);
              },
            ),
          ),

          // Botón Final
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                // Solo se activa si subió todas las fotos (o puedes dejarlo activo para demo)
                onPressed: isReadyToGenerate ? () {
                  _simulateGeneration(context);
                } : null, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4461F2),
                  disabledBackgroundColor: const Color(0xFFEAECF0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isReadyToGenerate ? "Generar Video Final ✨" : "Sube las fotos faltantes",
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: isReadyToGenerate ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneCard(int index) {
    final scene = _scenes[index];
    final bool hasImage = scene['image'] != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasImage ? const Color(0xFF4461F2) : const Color(0xFFEAECF0), width: hasImage ? 1.5 : 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header de la Tarjeta
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono del tipo de escena
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    scene['type'] == 'NARRATOR' ? Icons.mic : Icons.videocam,
                    size: 20, color: const Color(0xFF344054),
                  ),
                ),
                const SizedBox(width: 12),
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Escena ${scene['id']}: ${scene['type']}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(4)),
                            child: Text(scene['duration'], style: const TextStyle(fontSize: 10, color: Color(0xFF4461F2), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        scene['script'],
                        style: const TextStyle(fontSize: 13, color: Color(0xFF667085), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Área de Subida (Upload Slot)
          GestureDetector(
            onTap: () => _pickImage(index),
            child: Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: hasImage ? Colors.black : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: hasImage ? null : Border.all(color: const Color(0xFFD0D5DD), style: BorderStyle.solid),
                image: hasImage ? DecorationImage(image: FileImage(scene['image']), fit: BoxFit.cover) : null,
              ),
              child: hasImage 
                ? const Center(child: Icon(Icons.edit, color: Colors.white70))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, color: Color(0xFF4461F2)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          scene['instruction'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
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

  void _simulateGeneration(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text("Enviando bloques a Veo...", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Estamos animando tus ${ _scenes.length} fotos.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );

    // Simular espera y éxito
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Cerrar loader
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Video Generado! (Simulado)")));
    });
  }
}
