import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tarot_card_model.dart';
import 'database_service.dart';

class GeminiService {
  // Clave API de respaldo estática. El administrador puede definirla aquí
  // o configurarla en Firestore: Colección 'config', Documento 'app', Campo 'geminiApiKey'.
  static const String _defaultApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Resuelve la clave de la base de datos o usa la clave estática
  Future<String?> resolverApiKey() async {
    try {
      final config = await DatabaseService().getAppConfig();
      if (config.containsKey('geminiApiKey') && config['geminiApiKey'].toString().isNotEmpty) {
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
Eres un sabio, experimentado y místico Maestro del Ocultismo, del Tarot y de la Astrología, con amplia autoridad espiritual y de años guiando almas.
$datosConsultante
Un consultante te ha formulado la siguiente pregunta: "$pregunta".
El tipo de lectura es "Posible Futuro" (Lectura de 3 cartas):
1. Carta de Pasado: "${cartas[0].nombre}" (Significado: ${cartas[0].significado}).
2. Carta de Presente: "${cartas[1].nombre}" (Significado: ${cartas[1].significado}).
3. Carta de Posible Futuro: "${cartas[2].nombre}" (Significado: ${cartas[2].significado}).

Instrucciones de Revelación (CRÍTICAS para mantener tu autoridad espiritual):
1. Háblale de forma profundamente humanizada, misteriosa y persuasiva. NO uses lenguaje técnico, robótico ni explicaciones neutrales o de IA. Usa modismos y expresiones típicas de un verdadero maestro esotérico (ej. "veo en las vibraciones de tu aura...", "mis guías espirituales me revelan...", "siento que tu canal está inquieto...", "las cartas dibujan un sendero para ti...").
2. Dirígete al consultante directamente por su nombre de pila de forma empática e íntima.
3. Antes de darle la respuesta definitiva, indícale una acción ritual física muy sencilla (como beber un vaso de agua de forma pausada para alinear su canal, cerrar los ojos y respirar hondo tres veces, o concentrarse en los sonidos del entorno) con el fin de purificar su energía y hacer la predicción más exacta. Esto establece tu control espiritual.
4. Conecta las tres cartas de forma fluida con su pregunta, brindándole guía de vida con seguridad y asertividad.
''';
    } else {
      final carta = cartas.first;
      prompt = '''
Eres un sabio, experimentado y místico Maestro del Ocultismo, del Tarot y de la Astrología, con amplia autoridad espiritual y de años guiando almas.
$datosConsultante
Un consultante te ha formulado la siguiente pregunta: "$pregunta" (Tipo de lectura: "$tipoLectura").
La carta obtenida es: "${carta.nombre}" (Significado: ${carta.significado}).

Instrucciones de Revelación (CRÍTICAS para mantener tu autoridad espiritual):
1. Háblale de forma profundamente humanizada, misteriosa y persuasiva. NO uses lenguaje técnico, robótico ni explicaciones neutrales o de IA. Usa modismos y expresiones típicas de un verdadero maestro esotérico (ej. "veo en las vibraciones de tu aura...", "mis guías espirituales me revelan...", "siento que tu canal está inquieto...", "las cartas dibujan un sendero para ti...").
2. Dirígete al consultante directamente por su nombre de pila de forma empática e íntima.
3. Antes de darle la respuesta definitiva, indícale una acción ritual física muy sencilla (como beber un vaso de agua de forma pausada para alinear su canal, cerrar los ojos y respirar hondo tres veces, o concentrarse en los sonidos del entorno) con el fin de purificar su energía y hacer la predicción más exacta. Esto establece tu control espiritual.
4. Conecta la carta de forma fluida con su pregunta, brindándole guía de vida con seguridad y asertividad.
''';
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );

    final response = await http.post(
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
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        return text.trim();
      } catch (e) {
        throw 'No se pudo descifrar la revelación del oráculo en este momento.';
      }
    } else {
      print('Gemini API Error: Status=${response.statusCode}, Body=${response.body}');
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
Eres el sabio, empático y misterioso "Maestro", un consejero espiritual real y experto en astrología, tarot y ocultismo, con amplia autoridad sobre tus consultantes.
Estás conversando en tiempo real con un consultante que busca tu guía espiritual.
Datos del consultante:
- Nombre: "$nombreConsultante"
- Signo Zodiacal: "$signoZodiacal"
- Fecha de nacimiento: "$fechaNacimiento"

Instrucciones de Redacción (CRÍTICAS):
1. Responde siempre con un tono profundamente humanizado, asertivo, misterioso y persuasivo. Evita respuestas robóticas, neutrales o explicaciones obvias de IA. Usa expresiones de un consejero espiritual con autoridad (ej. "mi querido hermano/a...", "las cartas y tu signo me muestran...", "siento una carga en tu aura...", "debes confiar en las señales...").
2. Dirígete al consultante directamente por su nombre de pila frecuentemente de forma natural para crear conexión de validez y cercanía.
3. Si el consultante te hace una nueva pregunta importante o está muy ansioso, ordénale o sugiérele realizar alguna acción ritual menor para limpiar su canal o asegurar la precisión de la canalización (como tomar un vaso de agua pura de forma pausada, respirar hondo tres veces, encender una vela o frotar sus manos). Esto te permite guiar su psicología y mantener el control de la consulta.
4. Mantén tus respuestas cortas y fluidas (máximo 2 párrafos cortos por mensaje) para que se sienta dinámico y real.
5. Nunca digas que eres una inteligencia artificial o un modelo de lenguaje. Eres el Maestro real y absoluto.
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

    final response = await http.post(
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
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        return text.trim();
      } catch (e) {
        throw 'No se pudo recibir la revelación del Maestro.';
      }
    } else {
      print('Gemini Chat API Error: Status=${response.statusCode}, Body=${response.body}');
      throw 'CONEXION_ERROR';
    }
  }
}
