import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tarot_card_model.dart';
import 'database_service.dart';

class GeminiService {
  // Clave API de respaldo estática. El administrador puede definirla aquí
  // o configurarla en Firestore: Colección 'config', Documento 'app', Campo 'geminiApiKey'.
  static const String _defaultApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Resuelve la clave de la base de datos o usa la clave estática
  Future<String?> resolverApiKey() async {
    try {
      final config = await DatabaseService().getAppConfig();
      if (config.containsKey('geminiApiKey') &&
          config['geminiApiKey'].toString().isNotEmpty) {
        return config['geminiApiKey'].toString().trim();
      }
    } catch (_) {}
    return _defaultApiKey.isNotEmpty ? _defaultApiKey : null;
  }

  /// Envía una solicitud al Oráculo para interpretar la lectura de Tarot
  Future<String> obtenerInterpretacion({
    required String pregunta,
    required String tipoLectura,
    required List<TarotCardModel> cartas,
    String? nombreConsultante,
    String? signoZodiacal,
    String? fechaNacimiento,
  }) async {
    final apiKey = await resolverApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw 'CONEXION_ERROR';
    }

    String datosConsultante = '';
    if (nombreConsultante != null && nombreConsultante.isNotEmpty) {
      datosConsultante += 'El consultante se llama "$nombreConsultante". ';
    }
    if (signoZodiacal != null && signoZodiacal.isNotEmpty) {
      datosConsultante += 'Su signo zodiacal es $signoZodiacal. ';
    }
    if (fechaNacimiento != null && fechaNacimiento.isNotEmpty) {
      datosConsultante += 'Nació el $fechaNacimiento. ';
    }

    String prompt = '';
    if (tipoLectura == 'posible futuro' && cartas.length >= 3) {
      prompt = '''
Eres un asistente virtual de tarot y astrología que ofrece interpretaciones simbólicas para la reflexión personal.
$datosConsultante
Un consultante te ha formulado la siguiente pregunta: "$pregunta".
El tipo de lectura es "Posible Futuro" (Lectura de 3 cartas):
1. Carta de Pasado: "${cartas[0].nombre}" (Significado: ${cartas[0].significado}).
2. Carta de Presente: "${cartas[1].nombre}" (Significado: ${cartas[1].significado}).
3. Carta de Posible Futuro: "${cartas[2].nombre}" (Significado: ${cartas[2].significado}).

Instrucciones de Revelación (CRÍTICAS para mantener tu autoridad espiritual):
1. Usa un tono cálido, evocador y respetuoso. Presenta las interpretaciones como posibilidades simbólicas, sin afirmar poderes sobrenaturales ni certezas sobre el futuro.
2. Dirígete al consultante directamente por su nombre de pila de forma empática e íntima.
3. Puedes invitar a respirar con calma, de forma opcional. Respeta la autonomía del consultante y no atribuyas precisión predictiva a ninguna acción ritual.
4. Relaciona las cartas con la pregunta como una invitación a reflexionar y considerar opciones, sin prometer resultados.
''';
    } else {
      final carta = cartas.first;
      prompt = '''
Eres un asistente virtual de tarot y astrología que ofrece interpretaciones simbólicas para la reflexión personal.
$datosConsultante
Un consultante te ha formulado la siguiente pregunta: "$pregunta" (Tipo de lectura: "$tipoLectura").
La carta obtenida es: "${carta.nombre}" (Significado: ${carta.significado}).

Instrucciones de Revelación (CRÍTICAS para mantener tu autoridad espiritual):
1. Usa un tono cálido, evocador y respetuoso. Presenta las interpretaciones como posibilidades simbólicas, sin afirmar poderes sobrenaturales ni certezas sobre el futuro.
2. Dirígete al consultante directamente por su nombre de pila de forma empática e íntima.
3. Puedes invitar a respirar con calma, de forma opcional. Respeta la autonomía del consultante y no atribuyas precisión predictiva a ninguna acción ritual.
4. Relaciona las cartas con la pregunta como una invitación a reflexionar y considerar opciones, sin prometer resultados.
''';
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ]
          }),
        )
        .timeout(const Duration(seconds: 35));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        return text.trim();
      } catch (e) {
        throw 'No se pudo descifrar la revelación del oráculo en este momento.';
      }
    } else {
      throw 'CONEXION_ERROR';
    }
  }

  /// Envía una solicitud de conversación continua al Maestro
  Future<String> obtenerRespuestaChat({
    required List<Map<String, String>> historial,
    required String nombreConsultante,
    required String signoZodiacal,
    required String fechaNacimiento,
  }) async {
    final apiKey = await resolverApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw 'CONEXION_ERROR';
    }

    final systemPrompt = '''
Eres el asistente virtual del Maestro, un personaje de orientación simbólica basado en tarot y astrología.
Estás conversando en tiempo real con un consultante que busca tu guía espiritual.
Datos del consultante:
- Nombre: "$nombreConsultante"
- Signo Zodiacal: "$signoZodiacal"
- Fecha de nacimiento: "$fechaNacimiento"

Instrucciones de Redacción (CRÍTICAS):
1. Usa un tono cálido, evocador y respetuoso. Presenta las interpretaciones como posibilidades simbólicas, sin afirmar poderes sobrenaturales ni certezas sobre el futuro.
2. Dirígete al consultante directamente por su nombre de pila frecuentemente de forma natural para crear conexión de validez y cercanía.
3. Puedes invitar a respirar con calma, de forma opcional. Respeta la autonomía del consultante y no atribuyas precisión predictiva a ninguna acción ritual.
4. Mantén tus respuestas cortas y fluidas (máximo 2 párrafos cortos por mensaje) para que se sienta dinámico y real.
5. Eres una IA: si te preguntan, explícalo con claridad. Nunca te presentes como una persona real.
''';

    List<Map<String, dynamic>> contents = [];
    for (var msg in historial) {
      contents.add({
        'role': msg['role'] == 'user' ? 'user' : 'model',
        'parts': [
          {'text': msg['text']}
        ]
      });
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': contents,
            'systemInstruction': {
              'parts': [
                {'text': systemPrompt}
              ]
            }
          }),
        )
        .timeout(const Duration(seconds: 35));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        return text.trim();
      } catch (e) {
        throw 'No se pudo recibir la revelación del Maestro.';
      }
    } else {
      throw 'CONEXION_ERROR';
    }
  }
}
