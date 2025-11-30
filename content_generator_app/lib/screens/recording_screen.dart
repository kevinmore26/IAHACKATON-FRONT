// Archivo: recording_screen.dart

import 'package:camera/camera.dart';
import 'package:content_generator_app/screens/video_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class RecordingScreen extends StatefulWidget {
  // AHORA RECIBIMOS LOS IDs AL INICIAR
  final String ideaId;
  final String organizationId;
  // NOTA: El script ya no se recibe aquí porque esta pantalla es genérica para "Grabar"
  // Si quieres el script, debes pasarlo a través del constructor, pero el flujo te está pidiendo estos IDs.

  const RecordingScreen({super.key, required this.ideaId, required this.organizationId});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with WidgetsBindingObserver {
  // --- VARIABLES ---
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isRecording = false;

  // --- UI VARIABLES ---
  bool _showGhostOverlay = true;
  final ScrollController _scrollController = ScrollController();
  Timer? _teleprompterTimer;

  // DATOS MOCK (Los usaremos para el Teleprompter)
  final String _hook = "¡DEJA DE PERDER DINERO EN TUS ANUNCIOS!";
  final String _script = """
Hola, soy [Tu Nombre].
Si tienes una MYPE, sé que te duele gastar en ads que no funcionan.
Por eso creamos esta herramienta.
Mira cómo en 3 pasos generamos tu estrategia.
1. Define tu objetivo.
2. Graba con nuestra guía.
3. Publica y vende.
¡Haz clic en el enlace!
""";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // 1. Pedir permisos
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request(); // Aunque no guardamos a galería, es buena práctica para permisos generales

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _controller!.initialize();
    if (mounted) setState(() => _isCameraInitialized = true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _scrollController.dispose();
    _teleprompterTimer?.cancel();
    super.dispose();
  }

// --- FUNCIÓN DE GRABACIÓN Y NAVEGACIÓN ---

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      // --- DETENER Y LIBERAR RECURSOS ---
      try {
        final XFile videoFile = await _controller!.stopVideoRecording();

        _teleprompterTimer?.cancel();

        // 1. GUARDAR REFERENCIA Y DISPONER INMEDIATAMENTE
        final tempController = _controller;
        _controller = null; // Anular la referencia

        // 2. DETENER LA RENDERIZACIÓN EN EL WIDGET TREE (FIX para evitar CameraException)
        setState(() {
            _isCameraInitialized = false; 
            _isRecording = false;
        });
        
        await tempController?.dispose(); // Liberación forzada (segura)

        // 3. NAVEGAR a la pantalla de Revisión con todos los IDs
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VideoReviewScreen(
                    videoPath: videoFile.path,
                    ideaId: widget.ideaId, // PASANDO EL ID
                    organizationId: widget.organizationId, // PASANDO EL ORG ID
                  ),
            ),
          );

          // 4. CUANDO EL USUARIO REGRESE, REINICIALIZAMOS LA CÁMARA
          _initializeCamera();
        }
      } catch (e) {
        print("Error al detener o guardar: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al grabar: $e"), backgroundColor: Colors.red),
          );
          _initializeCamera(); 
        }
      }
    } else {
      // --- EMPEZAR ---
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
      _startTeleprompter();
    }
  }

  void _startTeleprompter() {
    const scrollSpeed = 20.0;
    const refreshRate = Duration(milliseconds: 100);
    _teleprompterTimer = Timer.periodic(refreshRate, (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        if (currentScroll >= maxScroll) {
          timer.cancel();
          _toggleRecording();
        } else {
          _scrollController.animateTo(
            currentScroll + (scrollSpeed * 0.1),
            duration: refreshRate,
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- CAPA 1: CÁMARA CORREGIDA ---
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                var scale = size.aspectRatio * _controller!.value.aspectRatio;

                if (scale < 1) scale = 1 / scale;

                return Transform.scale(
                  scale: scale,
                  child: Center(
                    child: CameraPreview(_controller!),
                  ),
                );
              },
            ),
          ),
          
          // --- CAPA 2: CONTENIDO (Teleprompter y UI) ---
          SafeArea(
            child: Column(
              children: [
                // ... (AppBar superior igual) ...
                // ... (Ghost Overlay, si lo usas, igual) ...
                
                // HEADER UI
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context)),
                      const Spacer(),
                      const Text("Misión: Ventas",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // Botón que no existe en el flujo actual, pero lo dejamos por estética
                      IconButton(
                          icon: Icon(
                              _showGhostOverlay ? Icons.person : Icons.person_off,
                              color: Colors.white),
                          onPressed: () => setState(
                              () => _showGhostOverlay = !_showGhostOverlay)),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // TELEPROMPTER/SCRIPT UI
                Container(
                  height: 250,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text(_hook,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFFFEF08A),
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      const Divider(color: Colors.white30),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Text(_script,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // BOTÓN DE GRABAR
                GestureDetector(
                  onTap: _toggleRecording,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: _isRecording ? Colors.red : Colors.red,
                      child: _isRecording
                          ? const Icon(Icons.stop, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}