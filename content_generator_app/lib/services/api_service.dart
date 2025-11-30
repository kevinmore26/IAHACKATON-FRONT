import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl =
      'https://iahackaton-back-production.up.railway.app/v1';

  static String? _token;
  // NUEVO: Guardamos el ID de la organización activa aquí
  static String? _currentOrganizationId;
  static final Map<String, List<dynamic>> _scriptCache = {};
  static String? get token => _token;
  static String? get currentOrganizationId => _currentOrganizationId;

  // --- 1. SIGN UP ---
// --- EN services/api_service.dart ---

  static Future<bool> signup(String name, String email, String password) async {
    print("🔵 INTENTANDO REGISTRO con: $email");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'), //
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name, // [cite: 13]
          'email': email, // [cite: 13]
          'password': password // [cite: 13]
        }),
      );

      print("🟡 SIGNUP STATUS: ${response.statusCode}");
      print("🟡 SIGNUP BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // 1. Guardar Token inmediatamente
        _token = data['data']['token'];
        await _saveToken(_token!);

        // 2. Guardar nombre usuario
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', data['data']['user']['name']);

        // 3. Usuario nuevo NO tiene organización todavía
        _currentOrganizationId = null;

        print("✅ Usuario creado y token guardado.");
        return true;
      } else {
        print("❌ Error Signup: ${response.body}");
        return false;
      }
    } catch (e) {
      print("💥 Error Fatal Signup: $e");
      return false;
    }
  }

  // --- 2. LOGIN (MODIFICADO PARA GUARDAR ORG ID) ---
// --- EN services/api_service.dart ---

  static Future<bool> login(String email, String password) async {
    print("🔵 INTENTANDO LOGIN con: $email"); // DEBUG 1

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("🟡 STATUS CODE: ${response.statusCode}"); // DEBUG 2
      print(
          "🟡 BODY: ${response.body}"); // DEBUG 3: ¡Esto es lo más importante!

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 1. Guardar Token
        _token = data['data']['token'];
        print("✅ Token recibido: ${_token?.substring(0, 10)}..."); // DEBUG 4

        // 2. Guardar Nombre
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', data['data']['user']['name']);
        await _saveToken(_token!);

        // 3. BUSCAR ORGANIZACIONES
        // Según la documentación, esto debería ser una lista
        List<dynamic> orgs = data['data']['user']['organizations'];
        print("🏢 Organizaciones encontradas: ${orgs.length}"); // DEBUG 5

        if (orgs.isNotEmpty) {
          _currentOrganizationId = orgs[0]['id'];
          await prefs.setString('org_id', _currentOrganizationId!);
          print("🚀 Org seleccionada ID: $_currentOrganizationId");
        } else {
          print(
              "⚠️ El usuario no tiene organizaciones (Es nuevo o hubo error)");
          _currentOrganizationId = null; // Aseguramos que sea null
        }

        return true;
      } else {
        print("❌ Error Login (Server): ${response.body}");
        return false;
      }
    } catch (e) {
      print("💥 EXCEPCIÓN FATAL EN LOGIN: $e"); // DEBUG 6
      return false;
    }
  }

  // --- 3. CREATE ORGANIZATION (MODIFICADO PARA RETORNAR EL ID) ---
  // Cambiamos el return de Future<bool> a Future<String?> para devolver el ID
  static Future<String?> createOrganization({
    required String name,
    required String businessType,
    required String mainProduct,
    required String objective,
    required String audience,
  }) async {
    if (_token == null) await _loadToken();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/organizations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'name': name,
          'business_type': businessType,
          'main_product': mainProduct,
          'content_objective': objective,
          'target_audience': audience
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // NUEVO: Extraemos y guardamos el ID
        String newOrgId = data['data']['organization']['id'];
        _currentOrganizationId = newOrgId;
        return newOrgId; // Retornamos el ID exitoso
      } else {
        print("Error al crear Org: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error Fatal Org: $e");
      return null;
    }
  }

  // --- 4. GENERATE IDEAS (NUEVO) ---
  static Future<bool> generateIdeas(String orgId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/organizations/$orgId/generate-ideas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'count': 3}), // Pedimos 3 ideas por defecto
      );

      print("Generar Ideas Status: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error generando ideas: $e");
      return false;
    }
  }

  // --- 5. GET HOME DATA (NUEVO) ---
  // Retorna una Lista de mapas (JSON) con las ideas
  static Future<List<dynamic>?> getHomeData() async {
    if (_currentOrganizationId == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organizations/$_currentOrganizationId/home'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['ideas']; // Retorna la lista de ideas
      }
    } catch (e) {
      print("Error getting home data: $e");
    }
    return null;
  }

  // ... (Tus métodos _saveToken y _loadToken siguen igual) ...
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    // NUEVO: Cargar el ID de la organización si existe
    _currentOrganizationId = prefs.getString('org_id');
    print("🔄 Token cargado: ${_token != null ? 'SI' : 'NO'}");
    print("🔄 Org ID cargado: $_currentOrganizationId");
  }

// --- 6. GENERATE SCRIPT (Con Debugging) ---
  static Future<List<dynamic>?> generateScript(String ideaId) async {
    // 1. PRIMERO: Revisamos si ya tenemos este guion en memoria
    if (_scriptCache.containsKey(ideaId)) {
      print("🚀 FLASH: Usando guion en caché para $ideaId");
      return _scriptCache[ideaId]; // Retorno inmediato
    }

    // 2. Si no está en caché, llamamos a la API
    if (_token == null) await _loadToken();

    print("📡 NETWORK: Generando script en servidor para $ideaId...");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scripts/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'ideaId': ideaId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        List<dynamic> blocks = data['data'];

        // 3. ¡GUARDAMOS EN CACHÉ ANTES DE RETORNAR!
        _scriptCache[ideaId] = blocks;

        return blocks;
      } else {
        print("❌ Error del servidor: ${response.body}");
        return null;
      }
    } catch (e) {
      print("💥 Error de conexión: $e");
      return null;
    }
  }

  // --- 7. UPLOAD BLOCK MEDIA (Subir Imagen) ---
  static Future<bool> uploadBlockMedia(String blockId, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/blocks/$blockId/upload'),
      );

      request.headers['Authorization'] = 'Bearer $_token';

      // Adjuntamos el archivo
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Upload Status: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error uploading media: $e");
      return false;
    }
  }

  // --- 8. GENERATE BLOCK VIDEO (Animar 1 Bloque) ---
  static Future<bool> generateBlockVideo(String blockId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/blocks/$blockId/generate'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error generating block video: $e");
      return false;
    }
  }

  // En services/api_service.dart

// --- NUEVO: 10. GET GALLERY ITEMS ---
// Retorna todos los ítems (videos y fotos) de la galería de la organización.
  static Future<List<dynamic>?> getGalleryItems() async {
    if (_currentOrganizationId == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organizations/$_currentOrganizationId/gallery'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // La respuesta contiene una lista de ítems directamente en 'data' [cite: 1034]
        return data['data'];
      }
    } catch (e) {
      print("Error getting gallery items: $e");
    }
    return null;
  }

// --- NUEVO: 11. UPLOAD GALLERY ITEM (Implementar si el botón de subida se usa) ---
// Sube un archivo a la galería [cite: 1004]
  static Future<bool> uploadGalleryItem({
    required String organizationId,
    required File file,
  }) async {
    if (_token == null) {
      print("❌ uploadGalleryItem: _token es null");
      return false;
    }
    
    final url = Uri.parse('$baseUrl/organizations/$organizationId/gallery');
    print("➡️ Subiendo a URL: $url");
    print("➡️ Archivo local: ${file.path}");

    try {
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $_token';

      // Si sabes que es mp4, puedes dejarlo así. Si no, igual funciona sin contentType.
      request.files.add(await http.MultipartFile.fromPath(
        'file', // ⚠️ Asegúrate de que el backend espera el campo 'file'
        file.path,
        // contentType: MediaType('video', 'mp4'),
      ));

      final streamedResponse = await request.send();
      final statusCode = streamedResponse.statusCode;
      final body = await streamedResponse.stream.bytesToString();

      print("⬅️ uploadGalleryItem status=$statusCode");
      print("⬅️ uploadGalleryItem body=$body");

      return statusCode == 200 || statusCode == 201;
    } catch (e, st) {
      print("💥 EXCEPCIÓN en uploadGalleryItem: $e");
      print(st);
      return false;
    }
  }

  // --- 9. RENDER FINAL VIDEO (Unir Todo) ---
  // Devuelve la URL final (signed_url) o null si falla
  static Future<String?> renderFinalVideo(String scriptId) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/scripts/$scriptId/render'), // Usamos el ID de la idea/script
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data']['signed_url'];
      }
    } catch (e) {
      print("Error rendering final video: $e");
    }
    return null;
  }
}
