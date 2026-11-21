# Pruebas de RP Music 0.4.7

El análisis de Dart y una prueba directa de interfaz comprobaron los menús, la cabecera de Biblioteca a 320 px con texto ampliado y el cambio a un diseño ancho. El ejecutor habitual de pruebas quedó bloqueado por la conexión local del entorno.

## Validación en Android y Windows

1. Actualiza sobre la versión anterior. Confirma que se conservan biblioteca, listas y favoritos.
2. En Biblioteca, cambia entre Canciones, Álbumes, Artistas y Carpetas con texto normal y ampliado. Comprueba que el selector muestra el nombre completo en una fila.
3. En Canciones, abre los tres puntos y elige Filtrado. Comprueba que el primer menú se cierra, aplica Duración y confirma que vuelve a la biblioteca. Abre los tres puntos de nuevo y comprueba Actualizar.
4. Abre una lista con imagen propia y otra sin ella. Comprueba que la primera usa su carátula difuminada y la segunda usa el fondo del tema.
5. Abre un álbum con carátula clara y otro con carátula oscura. Comprueba legibilidad y fluidez al desplazar, el margen de las duraciones y las acciones de cola.
6. En Windows, alterna entre ventana estrecha y ancha. Confirma que la portada se recoloca y que el foco de teclado se distingue.
