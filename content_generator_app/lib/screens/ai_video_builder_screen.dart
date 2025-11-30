import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AiVideoBuilderScreen extends StatefulWidget {
  final String ideaId;
  final String missionTitle;
  final String organizationId;

  const AiVideoBuilderScreen({
    super.key,
    required this.ideaId,
    required this.missionTitle,
    required this.organizationId,
  });

  @override
  State<AiVideoBuilderScreen> createState() => _AiVideoBuilderScreenState();
}

class _AiVideoBuilderScreenState extends State<AiVideoBuilderScreen> {
  List<dynamic> _blocks = [];
  bool _isLoadingScript = true;
  String _loadingStatusText = "Iniciando...";
  bool _isGeneratingFinal = false;
  final ImagePicker _picker = ImagePicker();

  // Key: Block ID, Value: File
  final Map<String, File> _selectedImages = {};

  // Variable para manejar errores
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchScriptBlocks();
  }

  Future<void> _fetchScriptBlocks() async {
    setState(() {
      _errorMessage = null;
      _isLoadingScript = true;
    });

    // Llamada al servicio
    print(widget);
    print(widget.ideaId);
    final blocks = await ApiService.generateScript(widget.ideaId);

    if (mounted) {
      setState(() {
        if (blocks != null) {
          _blocks = blocks;
          if (_blocks.isEmpty) {
            _errorMessage = "La IA no devolvió bloques. Intenta de nuevo.";
          }
        } else {
          _errorMessage = "Error de conexión. Revisa tu internet o el token.";
        }
        _isLoadingScript = false;
      });
    }
  }

  Future<void> _pickAndUploadImage(String blockId) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        File file = File(image.path);

        setState(() {
          _selectedImages[blockId] = file;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Subiendo imagen..."),
            duration: Duration(seconds: 1)));

        bool success = await ApiService.uploadBlockMedia(blockId, file);

        if (success) {
          print("Imagen subida para bloque $blockId");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Error al subir imagen a la nube.")));
        }
      }
    } catch (e) {
      print("Error picker: $e");
    }
  }

  Future<void> _handleFinalGeneration() async {
    setState(() {
      _isGeneratingFinal = true;
      _loadingStatusText = "Preparando motores de IA...";
    });

    // 1. Generar video por bloques
    for (var i = 0; i < _blocks.length; i++) {
      var block = _blocks[i];
      String blockId = block['id'];

      if (_selectedImages.containsKey(blockId)) {
        setState(() {
          // Mensaje dinámico: "Animando escena 1 de 3..."
          _loadingStatusText =
              "Animando escena ${i + 1} de ${_blocks.length}... 🎨";
        });
        await ApiService.generateBlockVideo(blockId);
      }
    }

    // 2. Render final
    setState(() {
      _loadingStatusText = "Uniendo todo en una obra maestra... 🎬";
    });

    String? finalUrl = await ApiService.renderFinalVideo(widget.ideaId);

    setState(() => _isGeneratingFinal = false);

    if (finalUrl != null && mounted) {
      _showSuccessDialog(finalUrl);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error generando el video final."),
            backgroundColor: Colors.red));
      }
    }
  }

  void _showSuccessDialog(String url) {
    // Variable para mostrar carga en el botón de exportar
    // (Usamos StatefulBuilder para actualizar solo el diálogo)
    bool isDownloading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text("¡Video Generado!",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Tu video .MP4 está listo. Expórtalo para editarlo en CapCut o guárdalo en tu galería.",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            // BOTÓN CERRAR
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: Colors.grey)),
            ),

            // BOTÓN EXPORTAR PRO
            ElevatedButton.icon(
              onPressed: isDownloading
                  ? null
                  : () async {
                      // 1. Mostrar carga en el botón
                      setDialogState(() => isDownloading = true);

                      try {
                        // 2. Descargar el video de la URL
                        final response = await http.get(Uri.parse(url));
                        final bytes = response.bodyBytes;

                        // 3. Obtener carpeta temporal del celular
                        final tempDir = await getTemporaryDirectory();
                        final savePath =
                            '${tempDir.path}/video_ia_generado.mp4';
                        final file = File(savePath);

                        // 4. Guardar los bytes en un archivo real .mp4
                        await file.writeAsBytes(bytes);

                        // 5. Compartir EL ARCHIVO (No el link)
                        // Esto abre el menú nativo y apps como CapCut detectan que es video
                        await Share.shareXFiles([XFile(savePath)],
                            text: '¡Video generado con mi IA!');
                      } catch (e) {
                        print("Error exportando: $e");
                      } finally {
                        // Dejar de cargar
                        setDialogState(() => isDownloading = false);
                      }
                    },
              icon: isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.ios_share),
              label: Text(isDownloading ? "Descargando..." : "Exportar Video"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isReady = _blocks.isNotEmpty &&
        _blocks.every((b) => _selectedImages.containsKey(b['id']));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tablero de Rodaje 🎬",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(isReady),
    );
  }

  Widget _buildBody(bool isReady) {
    // 1. ESTADO CARGANDO
    if (_isLoadingScript) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. ESTADO ERROR
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchScriptBlocks,
                icon: const Icon(Icons.refresh),
                label: const Text("Reintentar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4461F2),
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      );
    }

    // 3. ESTADO ÉXITO (LA LISTA)
    return Column(
      children: [
        // Header informativo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: const Color(0xFFF9FAFB),
          width: double.infinity,
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF667085)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Sube una foto para cada escena generada por la IA.",
                  style: TextStyle(color: Color(0xFF667085), fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        // Lista de Bloques
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _blocks.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildBlockCard(_blocks[index]);
            },
          ),
        ),

        // Botón Final
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (isReady && !_isGeneratingFinal)
                  ? _handleFinalGeneration
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4461F2),
                disabledBackgroundColor: const Color(0xFFEAECF0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isGeneratingFinal
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text(_loadingStatusText,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    )
                  : Text(
                      isReady
                          ? "Generar Video Final ✨"
                          : "Completa las fotos (${_selectedImages.length}/${_blocks.length})",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isReady ? Colors.white : Colors.grey[500],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockCard(dynamic block) {
    String blockId = block['id'];
    bool hasImage = _selectedImages.containsKey(blockId);
    File? imageFile = _selectedImages[blockId];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: hasImage ? const Color(0xFF4461F2) : const Color(0xFFEAECF0),
            width: hasImage ? 2 : 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.movie_filter,
                      size: 20, color: Color(0xFF344054)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Escena ${block['order'] ?? '-'}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(block['type'] ?? 'CLIP',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(block['script'] ?? "...",
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF344054),
                              height: 1.4)),
                      const SizedBox(height: 6),
                      Text("Instrucción IA: ${block['instructions'] ?? ''}",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667085),
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _pickAndUploadImage(blockId),
            child: Container(
              height: 140,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: hasImage ? Colors.black : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                image: hasImage
                    ? DecorationImage(
                        image: FileImage(imageFile!), fit: BoxFit.cover)
                    : null,
                border: hasImage
                    ? null
                    : Border.all(
                        color: const Color(0xFFD0D5DD),
                        style: BorderStyle.solid),
              ),
              child: hasImage
                  ? Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withOpacity(0.3)),
                      child: const Center(
                          child:
                              Icon(Icons.edit, color: Colors.white, size: 30)))
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: Color(0xFF4461F2), size: 32),
                        SizedBox(height: 8),
                        Text("Subir Referencia",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4461F2))),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
