import 'package:content_generator_app/services/api_service.dart';
import 'package:flutter/material.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  // Controladores de Texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); // Nuevo

  // Variables de Estado para selección
  final Set<String> _selectedInterests = {};
  int _currentStep = 0; // 0: Datos Estratégicos, 1: Estilo Visual

  String? _selectedGoal;
  String? _selectedFrequency;

  // Opciones para los Dropdowns
  final List<String> _goals = [
    "Vender más",
    "Ganar seguidores",
    "Crear comunidad",
    "Educar clientes"
  ];
  // Antes era _frequencies, ahora lo renombramos para que tenga sentido
  final List<String> _targetAudiences = [
    "18 - 24 años",
    "25 - 39 años",
    "40+ años"
  ];

  // Datos Mock para el Grid tipo Pinterest
  final List<Map<String, String>> _pinterestCards = [
    {
      "id": "fashion",
      "title": "Moda & Estilo",
      "image":
          "https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=300&auto=format&fit=crop"
    },
    {
      "id": "food",
      "title": "Foodie / Gastro",
      "image":
          "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=300&auto=format&fit=crop"
    },
    {
      "id": "fitness",
      "title": "Fitness & Salud",
      "image":
          "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=300&auto=format&fit=crop"
    },
    {
      "id": "tech",
      "title": "Tech & Reviews",
      "image":
          "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=300&auto=format&fit=crop"
    },
    {
      "id": "beauty",
      "title": "Belleza & Skincare",
      "image":
          "https://images.unsplash.com/photo-1596462502278-27bfdd403cc2?q=80&w=300&auto=format&fit=crop"
    },
    {
      "id": "consulting",
      "title": "Servicios / Tips",
      "image":
          "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?q=80&w=300&auto=format&fit=crop"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Usamos resizeToAvoidBottomInset para que el teclado no tape los botones
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // --- BARRA DE PROGRESO ANIMADA ---
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              width: MediaQuery.of(context).size.width *
                  (_currentStep == 0 ? 0.5 : 1.0),
              color: const Color(0xFF4461F2),
              alignment: Alignment.centerLeft,
            ),

            // --- CONTENIDO PRINCIPAL ---
            Expanded(
              child: _currentStep == 0
                  ? _buildStepOneForm()
                  : _buildStepTwoPinterest(),
            ),

            // --- BOTÓN FLOTANTE INFERIOR ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text("Atrás",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentStep == 0) {
                        // Validación simple antes de avanzar
                        if (_nameController.text.isEmpty ||
                            _selectedGoal == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Por favor completa los datos básicos")),
                          );
                          return;
                        }
                        setState(() => _currentStep++);
                      } else {
                        // TERMINAR Y IR AL HOME
                        _handleCreateAndGenerate();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4461F2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          _currentStep == 0 ? "Siguiente" : "Generar Plan",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (_currentStep == 0) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PASO 1: FORMULARIO ESTRATÉGICO
  Widget _buildStepOneForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Configuremos tu IA 🧠",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ayúdanos a entender tu negocio para crear la estrategia perfecta.",
            style: TextStyle(color: Color(0xFF667085), fontSize: 16),
          ),
          const SizedBox(height: 32),

          // 1. NOMBRE
          _buildLabel("¿Cómo se llama tu marca?"),
          TextField(
            controller: _nameController,
            decoration: _inputDecoration("Ej. Zapatillas Urbanas", Icons.store),
          ),
          const SizedBox(height: 20),

          // 2. DESCRIPCIÓN (NUEVO)
          _buildLabel("¿Qué vendes en una frase?"),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: _inputDecoration(
                "Ej. Ropa deportiva cómoda para gente que odia el gimnasio.",
                Icons.description),
          ),
          const SizedBox(height: 20),

          // 3. OBJETIVO (DROPDOWN)
          _buildLabel("¿Cuál es tu prioridad este mes?"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD0D5DD)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGoal,
                hint: const Text("Selecciona un objetivo",
                    style: TextStyle(color: Color(0xFF98A2B3))),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Color(0xFF667085)),
                items: _goals.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedGoal = val),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4. FRECUENCIA (CHIPS)
          _buildLabel("¿Cuál es tu público objetivo?"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _targetAudiences.map((freq) {
              final isSelected = _selectedFrequency == freq;
              return ChoiceChip(
                label: Text(freq),
                selected: isSelected,
                selectedColor: const Color(0xFF4461F2),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF344054),
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFD0D5DD),
                  ),
                ),
                onSelected: (val) => setState(() => _selectedFrequency = freq),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

// Sustituye tu función _handleCreateAndGenerate por esta:
  Future<void> _handleCreateAndGenerate() async {
    // Variable para controlar el texto dinámico
    final ValueNotifier<String> loadingText =
        ValueNotifier("Conectando con la IA...");

    // 1. Mostrar Dialogo Personalizado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        // Evita que cierren el dialogo con "Atrás"
        canPop: false,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Un spinner más bonito o una animación si tuvieras Lottie
                const CircularProgressIndicator(color: Color(0xFF4461F2)),
                const SizedBox(height: 20),
                const Text("Generando tu Estrategia",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                // Aquí usamos ValueListenableBuilder para cambiar el texto sin reconstruir todo
                ValueListenableBuilder<String>(
                  valueListenable: loadingText,
                  builder: (context, value, child) {
                    return Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 2. Preparar datos
    loadingText.value = "Analizando tu nicho de mercado...";
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulamos un poco para que lean

    String businessType = _selectedInterests.join(", ");
    if (businessType.isEmpty) businessType = "General";

    // 3. Crear Organización
    loadingText.value = "Estructurando tus pilares de contenido...";

    final String? orgId = await ApiService.createOrganization(
      name: _nameController.text,
      businessType: businessType,
      mainProduct: _descriptionController.text,
      objective: _selectedGoal ?? "Ventas",
      audience: _selectedFrequency ?? "General",
    );

    // 4. Generar Ideas
    if (orgId != null) {
      loadingText.value = "La IA está redactando tus guiones virales...";
      await ApiService.generateIdeas(orgId);

      loadingText.value = "¡Todo listo! 🚀";
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Error al crear el perfil. Intenta de nuevo.")),
        );
      }
    }
  }

  // PASO 2: SELECCIÓN VISUAL (Pinterest Style) - Igual que antes pero ajustado
  Widget _buildStepTwoPinterest() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Define tu Vibe ✨",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            "Toca las imágenes que mejor representen el estilo visual que quieres lograr.",
            style: TextStyle(color: Color(0xFF667085), fontSize: 16),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio:
                  0.75, // Un poco más vertical para que se vea más Pinterest
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _pinterestCards.length,
            itemBuilder: (context, index) {
              final card = _pinterestCards[index];
              final isSelected = _selectedInterests.contains(card['id']);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(card['id']);
                    } else {
                      _selectedInterests.add(card['id']!);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF4461F2), width: 4)
                        : null,
                    image: DecorationImage(
                      image: NetworkImage(card['image']!),
                      fit: BoxFit.cover,
                      colorFilter: isSelected
                          ? ColorFilter.mode(
                              const Color(0xFF4461F2).withOpacity(0.5),
                              BlendMode.srcOver)
                          : null,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Texto flotante abajo
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent
                              ],
                            ),
                          ),
                          child: Text(
                            card['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      // Icono de Check Gigante si está seleccionado
                      if (isSelected)
                        const Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            child: Icon(Icons.check,
                                color: Color(0xFF4461F2), size: 24),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helpers de Estilo
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF344054),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: Color(0xFF98A2B3), fontWeight: FontWeight.normal),
      prefixIcon: Icon(icon, color: const Color(0xFF667085), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4461F2), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
