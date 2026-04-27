# La Fuerza Del Ocultismo - Flutter App

Aplicación completa y funcional de servicios místicos y esotéricos.

## ✨ Características Completas

### 🔐 Autenticación
- Pantalla de login con diseño místico
- Validación de campos
- Navegación automática al menú principal

### 🏠 Menú Principal
- Drawer lateral con navegación
- Logo místico animado
- 5 secciones principales completamente funcionales

### 👤 Perfil
- Edición de información personal
- Nombre, email, fecha de nacimiento
- Signo zodiacal
- Guardar cambios

### ⭐ Horóscopo
- 12 signos zodiacales con iconos
- Selección visual de tu signo
- Predicciones personalizadas
- Múltiples lecturas por signo

### 🔮 Tarot
- 4 tipos de lectura:
  - **Pasado**: Descubre eventos que te marcaron
  - **Presente**: Comprende tu situación actual
  - **Posible Futuro**: Lectura de 3 cartas (pasado-presente-futuro)
  - **Pregunta Directa**: Respuesta específica a tu pregunta
- 22 cartas del Tarot Mayor
- Interpretaciones detalladas
- Sistema de selección aleatoria

### 💧 Limpiezas
- 8 tipos de limpiezas energéticas:
  - Cuerpo
  - Alma
  - Espíritu
  - Negocios
  - Casa
  - Lotes
  - Propiedad
  - Vehículos
- Descripción detallada de cada servicio
- Duración estimada
- Sistema de solicitud

### 🕯️ Rituales
- 7 rituales místicos:
  - Sanación
  - Abre Caminos
  - Atracción
  - Dinero
  - Trabajo o Empleo
  - Alejar Malas Energías
  - Alejamiento de Malos Vecinos
- Lista de elementos necesarios
- Expansión de detalles
- Sistema de solicitud

## 🎨 Diseño

- Tema oscuro completo
- Colores: Negro y rojo místico (#B71C1C)
- Efectos de sombra y brillo
- Iconos personalizados
- Animaciones suaves
- Diseño responsive

## 📱 Navegación

- Drawer lateral funcional
- Navegación entre todas las pantallas
- Botón de cerrar sesión
- Transiciones suaves

## 🚀 Instalación

### Opción 1: Ejecutar directamente
```bash
flutter run
```

### Opción 2: Construir APK
```bash
flutter build apk --release
```
El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

### Opción 3: Usar scripts
- Doble clic en `instalar.bat` para instalar en dispositivo conectado
- Doble clic en `construir_apk.bat` para generar APK

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada
├── screens/
│   ├── login_screen.dart          # Pantalla de login
│   ├── home_screen.dart           # Menú principal con drawer
│   ├── perfil_screen.dart         # Edición de perfil
│   ├── horoscopo_screen.dart      # Consulta de horóscopo
│   ├── tarot_screen.dart          # Lecturas de tarot
│   ├── limpiezas_screen.dart      # Servicios de limpieza
│   └── rituales_screen.dart       # Rituales místicos
└── widgets/
    ├── occult_logo.dart           # Logo dibujado con CustomPainter
    ├── custom_text_field.dart     # Campo de texto personalizado
    └── custom_button.dart         # Botón personalizado
```

## 🎯 Funcionalidades Implementadas

✅ Login completo con validación
✅ Navegación entre todas las pantallas
✅ Perfil editable
✅ Horóscopo con 12 signos y predicciones
✅ Tarot con 4 tipos de lectura y 22 cartas
✅ 8 tipos de limpiezas energéticas
✅ 7 rituales místicos con detalles
✅ Sistema de solicitud de servicios
✅ Drawer lateral funcional
✅ Cerrar sesión
✅ Diseño completamente responsive
✅ Tema oscuro consistente

## 🔧 Tecnologías

- Flutter 3.x
- Dart 3.x
- Material Design
- CustomPainter para gráficos
- Navegación con MaterialPageRoute

## 📝 Notas

- La app está completamente funcional
- Todas las pantallas están implementadas
- Los datos son simulados (no hay backend)
- Lista para conectar con Firebase o API REST
- Diseño fiel a las imágenes de referencia

## 🚀 Próximos Pasos Sugeridos

- Conectar con backend (Firebase/API REST)
- Agregar autenticación real
- Base de datos para guardar perfil
- Sistema de pagos
- Notificaciones push
- Chat en vivo con especialistas
- Historial de consultas
- Calendario de citas

## 📄 Licencia

Proyecto educativo - La Fuerza Del Ocultismo
