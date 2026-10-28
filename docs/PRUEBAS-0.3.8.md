# Pruebas de RP Music 0.3.8

## Comprobado

122 pruebas finales aprobadas en una ejecución conjunta:120 de app y2 específicas de extensión; una red optativa omitida. Análisis lib/test/integration_test/tools limpio. QuickJS nativo Windows, UI a 360 px, persistencia, rechazo de árbol inválido, revocación y restauración de registro mixto Dart/JS aprobados. Bucle interrumpido en unos 1037 ms y llamada posterior correcta. Paquetes reales YouTube estable/Explorador conservan hashes y ejecutan operaciones Dart; no es una nueva escucha completa en esta versión.

## Comprobar en dispositivos

1. Instalar APK universal o ARM64 encima sin desinstalar. Windows: extraer todo el ZIP y ejecutar rp_music.exe junto con DLL/data. Confirmar raíz, listas, ajustes y extensiones conservados.
2. Instalar Laboratorio JS 0.1.0 desde catálogo, revisar permisos y pulsar Abrir pantalla. Debe aparecer saludo/formulario sin cambiar el propietario de Fuente.
3. Guardar un apodo, abrir panel, sumar/restar y volver. Cerrar/reabrir: saludo y contador persisten. Navegar sin errores de tamaño en pantalla estrecha, texto ampliado y teclado visible.
4. Abrir biblioteca, buscar y reproducir una canción local. Hasta500 pistas autorizadas/ocho resultados. Audio pasa por controles base; comprobar pausa, cola, notificación/widget según plataforma.
5. Desactivar Laboratorio y revisar que no recibe acciones. Reactivar conserva estado. No probar código ajeno sin revisar su procedencia; este SDK sigue siendo experimental.
6. Volver a YouTube Android 0.4.0 y Explorador 0.1.0: búsqueda/reproducción/descarga, páginas e importación como antes. Las extensiones no se migran a JavaScript.
7. SD/SAF, permisos revocados, escucha larga y actualizaciones conservando datos en varios equipos. YouTube Windows sigue fuera de las capacidades confirmadas.

Sin Android conectado para validar físicamente este motor. Compilar APK, verificar firma o ejecutar pruebas Windows no equivale a probarlo en el teléfono. Informar versión/equipo/pasos si falla. No hay conexión de cuenta ni sincronización en esta entrega.
