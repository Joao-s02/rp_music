# Pruebas 0.3.15

## Completadas

- 166 pruebas automáticas aprobadas, una de red opcional omitida; análisis del código sin incidencias. Incluye modo de actualización manual sin descarga/instalador interno y diálogo sin pausa del audio.
- Universal: comparación de APK con el control confirma DEX, AOT Flutter, bibliotecas y recursos idénticos. Solo manifiesto y firmas de integridad diferentes; único permiso retirado REQUEST_INSTALL_PACKAGES.
- Emulador API 37: análisis automático autorizado de ambos APK. Control bloqueado; candidato This app looks safe, instalado sin ignorar alertas. Hash del APK instalado idéntico al candidato, misma fecha original y lista de prueba conservadas.
- Usuario en dos dispositivos reales: Samsung Galaxy A34 actualiza sin mostrar Play Protect; Tecno Pova 7 solicita análisis y se instala normalmente, sin clasificación dañina. Versión de Android/Google y variante de APK no especificadas; no es medición universal.
- Android ARM64 y Windows se compilan para esta versión y se verifican versión, estructura, firmas/ABI cuando corresponda y contenido del ZIP. No equivalen a escucha física nueva.

## Comprobaciones del usuario

1. Actualizar Android desde Archivos sin desinstalar. Verificar versión 0.3.15, listas, ajustes y extensiones. Mantener protecciones activas; registrar cualquier alerta en otro dispositivo.
2. Probar reproducción local, letras sincronizadas y descargas desde las extensiones instaladas; comprobar álbum y letra en una descarga nueva. No se deben reescribir archivos anteriores.
3. Al existir una versión posterior, comprobar que Actualizar abre la página oficial y no solicita permiso de instalar paquetes ni pausa audio. En 0.3.15 no se debe ofrecer una versión anterior como actualización.
4. Windows: extraer el ZIP completo, reproducir archivos y fuentes habituales, comprobar cola/letras y cerrar desde bandeja. Sus mejoras de audio previas se conservan; no se afirma una nueva escucha prolongada.

Pendientes: instalación física ARM64, más teléfonos, reproducción prolongada y diagnóstico de latencia API 3 Android.
