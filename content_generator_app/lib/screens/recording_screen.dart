import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

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

  // DATOS MOCK
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
    // Esta librería requiere permiso de almacenamiento explícito
    await Permission.storage.request();

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

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      // --- DETENER Y GUARDAR ---
      try {
        final XFile videoFile = await _controller!.stopVideoRecording();

        _teleprompterTimer?.cancel();
        setState(() => _isRecording = false);

        // --- GUARDAR CON IMAGE_GALLERY_SAVER ---
        print("Guardando en ruta: ${videoFile.path}");
        // final result = await ImageGallerySaver.saveFile(videoFile.path);

        // ... dentro de _toggleRecording, después de ImageGallerySaver.saveFile ...

        if (mounted) {
          // 1. Mostrar diálogo de celebración
          await showDialog(
            context: context,
            barrierDismissible: false, // Obligar a esperar
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 10),
                  Text("¡Misión Cumplida!", textAlign: TextAlign.center),
                ],
              ),
              content: const Text(
                "Video guardado. Tu estrategia avanza.",
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cierra el diálogo
                    // 2. Regresa al Home devolviendo "true" (significa: Tarea completada)
                    Navigator.pop(context, true);
                  },
                  child: const Text("Continuar",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        print("Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
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
          // --- CAPA 1: CÁMARA CORREGIDA (Cubre toda la pantalla sin estirarse) ---
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 1. Calculamos el tamaño de la pantalla y de la cámara
                final size = constraints.biggest;
                var scale = size.aspectRatio * _controller!.value.aspectRatio;

                // 2. Ajustamos la escala para que cubra todo (efecto BoxFit.cover)
                if (scale < 1) scale = 1 / scale;

                // 3. Aplicamos la transformación
                return Transform.scale(
                  scale: scale,
                  child: Center(
                    child: CameraPreview(_controller!),
                  ),
                );
              },
            ),
          ),
          if (_showGhostOverlay)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.3,
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/17/17004.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
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
                      IconButton(
                          icon: Icon(
                              _showGhostOverlay
                                  ? Icons.person
                                  : Icons.person_off,
                              color: Colors.white),
                          onPressed: () => setState(
                              () => _showGhostOverlay = !_showGhostOverlay)),
                    ],
                  ),
                ),
                const Spacer(),
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
