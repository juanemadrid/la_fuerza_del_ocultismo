# 📱 Cómo Instalar "La Fuerza Del Ocultismo" en tu Celular

## ✅ Todo el código ya está listo!

La app está completamente programada y lista para usar. Solo falta compilarla e instalarla.

## 🚀 Opción 1: Instalación Directa (Recomendada)

### Paso 1: Conecta tu celular
1. Conecta tu celular con el cable USB
2. Activa "Depuración USB" en tu celular:
   - Ve a Ajustes → Acerca del teléfono
   - Toca 7 veces en "Número de compilación"
   - Regresa y entra a "Opciones de desarrollador"
   - Activa "Depuración USB"

### Paso 2: Verifica la conexión
```bash
flutter devices
```
Deberías ver tu celular en la lista.

### Paso 3: Instala la app
```bash
flutter run
```

La primera vez tomará 3-5 minutos porque Gradle descarga dependencias.

## 🔧 Opción 2: Construir APK e Instalar Manualmente

### Paso 1: Construir el APK
```bash
flutter build apk --release
```

### Paso 2: El APK estará en:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Paso 3: Instalar en el celular
Opción A - Con cable USB:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

Opción B - Sin cable:
1. Copia el archivo `app-release.apk` a tu celular
2. Abre el archivo desde el celular
3. Permite instalar desde fuentes desconocidas si te lo pide
4. Instala la app

## ⚡ Opción 3: Modo Rápido (Si ya compilaste antes)

Si ya compilaste una vez y solo quieres reinstalar:
```bash
flutter install
```

## 🐛 Solución de Problemas

### Si Gradle toma mucho tiempo:
Es normal la primera vez. Ten paciencia, puede tomar 5-10 minutos.

### Si dice "device not found":
```bash
adb devices
```
Si no aparece tu celular, desconecta y vuelve a conectar el cable.

### Si hay error de permisos:
En tu celular, cuando aparezca el mensaje "¿Permitir depuración USB?", toca "Permitir".

## 📂 Archivos del Proyecto

```
F:\Leyson\
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── screens/
│   │   └── login_screen.dart        # Pantalla de login
│   └── widgets/
│       ├── occult_logo.dart         # Logo místico
│       ├── custom_text_field.dart   # Campos de texto
│       └── custom_button.dart       # Botón personalizado
├── assets/
│   ├── images/                      # (Opcional) Imagen de fondo
│   └── fonts/                       # (Opcional) Fuente gótica
└── pubspec.yaml                     # Configuración del proyecto
```

## 🎨 Personalización (Opcional)

### Agregar imagen de fondo:
1. Copia tu imagen a: `assets/images/background.jpg`
2. Edita `pubspec.yaml` y descomenta la sección de assets
3. Edita `lib/screens/login_screen.dart` según las instrucciones
4. Ejecuta: `flutter pub get`

## ✨ La app incluye:

✅ Pantalla de login completa
✅ Logo místico animado
✅ Campos de usuario y contraseña
✅ Mostrar/ocultar contraseña
✅ Botón "Olvidé contraseña"
✅ Validación de campos
✅ Tema oscuro con efectos rojos brillantes
✅ Diseño responsive

## 🎯 Próximos Pasos

Una vez instalada, puedes:
- Conectar con un backend (Firebase, API REST)
- Agregar más pantallas
- Implementar autenticación real
- Agregar animaciones
- Publicar en Google Play Store
