# 🔮 La Fuerza Del Ocultismo - Instrucciones de Instalación

## ✅ Ya está todo listo para ejecutar!

La aplicación funcionará inmediatamente con un fondo degradado oscuro.

## 🚀 Ejecutar la aplicación

```bash
flutter pub get
flutter run
```

## 🎨 (Opcional) Agregar tu imagen de fondo personalizada

Si quieres usar la imagen de fondo que tienes:

1. Copia tu imagen a: `assets/images/background.jpg`

2. Edita `pubspec.yaml` y descomenta estas líneas:
```yaml
assets:
  - assets/images/
```

3. Edita `lib/screens/login_screen.dart` y reemplaza el `RadialGradient` con:
```dart
decoration: const BoxDecoration(
  image: DecorationImage(
    image: AssetImage('assets/images/background.jpg'),
    fit: BoxFit.cover,
  ),
),
```

4. Ejecuta: `flutter pub get` y reinicia la app

## 🔤 (Opcional) Agregar fuente gótica

1. Descarga una fuente estilo gótico (por ejemplo "Old English")
2. Guárdala como: `assets/fonts/OldEnglish.ttf`
3. Descomenta la sección de fonts en `pubspec.yaml`
4. Ejecuta: `flutter pub get`

## 📱 Características implementadas

✅ Pantalla de login completa
✅ Logo místico dibujado con código
✅ Campos de usuario y contraseña
✅ Mostrar/ocultar contraseña
✅ Botón de "Olvidé contraseña"
✅ Validación básica de campos
✅ Tema oscuro con efectos rojos brillantes

## 🔧 Próximos pasos sugeridos

- Conectar con un backend (Firebase, API REST)
- Agregar pantalla de registro
- Implementar recuperación de contraseña real
- Agregar animaciones
- Validación avanzada de formularios
