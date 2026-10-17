# RP Music

Reproductor musical local-first, multiplataforma y de alto rendimiento para **Android**, **Windows** y **Web**, construido con **Flutter**, arquitectura de **Puertos y Adaptadores (Arquitectura Hexagonal)**, persistencia reactiva en **Drift (SQLite)** y gestión de audio mediante **Riverpod**.

---

## 🚀 Características Principales

- **Arquitectura Limpia**: Monolito modular con separación estricta entre Dominio, Aplicación, Infraestructura y Presentación. Cero dependencias de framework/UI en el núcleo de dominio.
- **Reproducción Robusta**:
  - Un único coordinador de audio (`PlaybackCoordinator`) que gestiona el ciclo de vida del motor.
  - Separación entre intención de reproducción (`playIntent`) y estado de procesamiento (`ProcessingState`).
  - Serialización de cambios de pista mediante generaciones (`sourceGeneration`) para descartar eventos obsoletos de carga asíncrona.
  - Agrupamiento (coalescing / debouncing) de comandos consecutivos de búsqueda de posición (`seek`).
  - Tolerancia a fallos: detención automática tras 3 errores consecutivos para evitar bucles de salto ante archivos corruptos.
  - Restauración de sesión (restaura la última pista y posición exacta sin reproducir automáticamente al iniciar).
- **Gestión de Recursos y Ciclo de Vida (`SourceResolver` & `SourceLease`)**:
  - Revocación automática de `Blob URLs` en Web mediante `URL.revokeObjectURL`.
  - Liberación inmediata de descriptores de archivo temporales en entornos nativos.
- **Persistencia Reactiva (Drift / SQLite)**:
  - Base de datos relacional compartida con integridad referencial (`PRAGMA foreign_keys = ON;`) y eliminación en cascada.
  - Conexión nativa en background isolate para Android y Windows; base de datos Wasm / IndexedDB en Web.
  - Índices optimizados para ordenación y búsqueda instantánea con normalización de caracteres (`title_sort`).
- **Integración con Controles del Sistema**:
  - **Android**: Foreground Service con notificación multimedia, pantalla de bloqueo y control desde auriculares/Bluetooth (`audio_service` + `audio_session`).
  - **Web**: Integración con la API nativa de controles multimedia del navegador (`navigator.mediaSession`).
  - **Windows**: Soporte de rutas largas / Unicode y persistencia minimizada.
- **UI Adaptable Material 3**:
  - Barra lateral `NavigationRail` en pantallas medianas/grandes (Escritorio / Tablet).
  - Barra inferior `NavigationBar` en móviles.
  - Miniplayer y barra de reproducción accesible desde cualquier vista.
  - Búsqueda reactiva con debounce de 200ms.
  - Ajustes de tema (claro, oscuro, sistema), densidad y paletas de color con exportación de logs de diagnóstico con redacción de datos privados.

---

## 📁 Estructura del Proyecto

```text
lib/
├── app/                  # Composición de providers Riverpod y shell principal de la UI
├── bootstrap/            # Inicialización de dependencias, base de datos y sesión
├── core/                 # Extension types (IDs fuertemente tipados), tokens y diagnósticos
├── features/
│   ├── library/          # Dominio, repositorio Drift e indexador incremental de archivos
│   ├── playback/         # Contratos AudioEngine, JustAudioEngine y PlaybackCoordinator
│   ├── queue/            # Modelo de cola, ordenamiento, shuffle determinista y repetición
│   └── settings/         # Preferencias de usuario (tema, densidad, color)
└── infrastructure/       # Adaptadores de plataforma, base de datos Drift y puentes del sistema
```

---

## 🛠️ Requisitos Previos

- **Flutter SDK**: 3.29+ / 3.47+ (Dart 3.7+ / 3.13+)
- **Android**: Android SDK con NDK 28+ o 30+, Java 17+
- **Windows**: Windows 10/11 con Modo Desarrollador habilitado y Visual Studio C++ build tools

---

## 💻 Ejecución y Compilación

### 1. Ejecutar en Modo Desarrollo

```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d <id_dispositivo_o_emulador>

# Windows
flutter run -d windows
```

### 2. Compilar Paquetes de Distribución

```bash
# Generar APK de Android (Debug)
flutter build apk --debug

# Generar Bundle Web optimizado
flutter build web --release
```

---

## 🧪 Pruebas y Calidad de Código

El proyecto cuenta con un 100% de cobertura en pruebas de contratos de audio, base de datos y renderizado:

```bash
# Análisis estático (0 advertencias, 0 errores)
dart analyze

# Ejecutar la suite completa de pruebas
flutter test
```
