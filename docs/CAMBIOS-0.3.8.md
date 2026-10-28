# Cambios de RP Music 0.3.8

- Motor JavaScript/API 3 paralelo a Dart/API 2. Los paquetes actuales no se convierten ni se sustituyen.
- Pantallas compuestas por árboles nativos de columnas, filas, tarjetas, textos, campos y botones; estado/eventos y navegación interna definidos por la extensión.
- Lectura autorizada de biblioteca mediante IDs opacos, estado privado y reproducción explícita desde botones; rechazo de árbol inválido, permisos revocados o respuestas incompatibles.
- Motor QuickJS con límite nativo de tiempo y heap, contexto nuevo por evento y liberación antes de responder. No equivale a aislamiento OS o cuota total de proceso.
- Laboratorio JS 0.1.0, opción independiente en el repositorio de extensiones, demuestra tres páginas/formulario/contador/búsqueda local. Abrir pantalla desde gestor o navegación.

App 0.3.8+17, Android universal/ARM64 y Windows x64 completo. YouTube estable y Explorador conservan bytes/funciones existentes y siguen usando Dart. La extensión de prueba no controla Fuente ni viene en APK/ZIP.

Verificación:122 pruebas aprobadas (120 de app + 2 específicas de extensión), una prueba optativa de red omitida. Análisis completo sin incidencias. Interfaz a 360 px, estado/revocación y paquetes Dart reales comprobados. Bucle JS interrumpido nativamente en unos 1037 ms, siguiente evaluación correcta. No se suman repeticiones.

Pendiente: prueba física Android y cobertura de más dispositivos. Sin Node/npm, HTML/CSS libre ni red/cuentas/sincronización en API 3. YouTube Windows conserva límites previos; no se acredita escucha nueva completa de YouTube por estas pruebas de compatibilidad. Spotify/Play Store cancelados, licencia concreta pendiente.
