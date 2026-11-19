# Pruebas de RP Music 0.4.6

Pasaron el análisis Dart, la compilación Kotlin y las pruebas directas de interfaz de menús, gestos, temporizadores y Deshacer. En una compilación previa de corrección, el usuario confirmó en su Redmi que el reproductor volvió a abrir. Para este paquete completo quedan las pruebas físicas de instalación y cambio de salida en vivo.

1. Instala Android sobre la 0.4.5 o extrae el ZIP completo en Windows.
2. Reproduce una canción, expande el mini reproductor con un gesto hacia arriba y verifica la apertura. Sube la cola y ciérrala deslizando hacia abajo desde su contenido.
3. Desplázate por Biblioteca en ambas direcciones y espera cinco segundos después de que reaparezca la navegación.
4. Actualiza Biblioteca. Comprueba el contador durante el escaneo y durante los tres segundos siguientes.
5. Abre una lista, usa sus tres puntos y mantén pulsada una canción. Elige Quitar de esta lista y luego Deshacer.
6. En Android, alterna altavoz, cable y Bluetooth con el reproductor abierto y verifica el indicador.
