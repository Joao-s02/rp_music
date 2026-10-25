# Correcciones para probar — 0.2.1

Versión preliminar 0.2.1-alpha.1, posterior a 0.2.0-alpha.1. Conserva la carpeta de datos `v2` y las listas existentes. Descargas en la [release de GitHub](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.1-alpha.1).

## Qué cambió

1. La biblioteca muestra las canciones descubiertas mientras se completa su información. Las actualizaciones reutilizan metadatos de archivos sin cambios. Android intenta usar su índice multimedia y limita a dos lectores simultáneos.
2. Las listas muestran cuántas canciones están disponibles y cuántas están fuera de la carpeta actual. Las referencias ausentes se conservan por si vuelves a la raíz anterior. Dentro de la lista, **Quitar** limpia las ausentes si así lo eliges.
3. Cada canción de una lista tiene el botón **Quitar de la lista**. Esto no borra el archivo musical.
4. Se guarda y restaura canción, cola y posición. Al reabrir queda en pausa. La primera sesión guardada se crea al utilizar esta nueva versión.
5. Windows utiliza otro backend de audio y se añadió una prueba real de cambios repetidos con WAV. El cierre exacto observado en tu PC aún requiere volver a comprobarse con tus MP3/WAV.
6. Al abrir el teclado, Android oculta temporalmente el reproductor inferior y la navegación; puedes seguir buscando. Al cerrar el teclado reaparecen.

## Repetir las pruebas

- Usa la misma carpeta anterior y anota por separado cuánto tarda en aparecer la lista y cuánto tarda en completarse la información. Repite **Actualizar biblioteca** sin modificar archivos para comprobar la reutilización.
- Cambia de raíz con una lista ya creada: comprueba disponibles/ausentes, vuelve a la raíz original y verifica que reaparecen. Prueba después quitar una canción de una lista.
- Reproduce una canción unos segundos, pausa, cierra y vuelve a abrir. Debe aparecer la misma canción/posición en pausa. Un cierre forzado mientras reproduce puede perder hasta el último intervalo de guardado, normalmente cinco segundos.
- En Windows prueba siguiente, anterior y selección desde la biblioteca con MP3 y WAV.
- En Android abre el teclado en búsqueda, filtra por artista y título, ciérralo y comprueba los controles.

La mejora cuantitativa de escaneo en tus celulares y la corrección del cierre con tus archivos necesitan estas pruebas; las verificaciones locales no sustituyen su resultado.

El paquete Windows debe extraerse completo y ejecutarse desde su propia carpeta. No copiar solo el EXE ni mezclar los DLL del paquete anterior con los nuevos. El APK continúa firmado con la clave de desarrollo de esta máquina.
