# Pruebas de RP Music 0.4.4

El análisis Dart y las pruebas directas de cabeceras, cola simulada y cálculo de ganancia pasaron. libmpv aceptó la cadena de filtros y la precarga. La suite Flutter no pudo abrir su conexión local en el entorno de compilación. Las siguientes comprobaciones físicas siguen pendientes.

1. En Android instala el APK sobre la versión anterior y confirma que conserva biblioteca, listas y favoritos. En Windows, extrae el ZIP completo y comprueba que abre.
2. En Ajustes → Reproducción activa el ecualizador. Compara Plano y Graves con audífonos. Cambia una banda y reinicia la app. Comprueba que el ajuste se conserva.
3. Carga dos pistas contiguas de un álbum continuo. Deja que avancen naturalmente con gapless activo. Prueba también con un fundido aplicable y confirma que el avance sigue la cola.
4. Prueba ReplayGain por canción con archivos etiquetados a distintos niveles y por álbum con un disco etiquetado. Comprueba que al desactivarlo vuelven a su nivel habitual. Prueba una canción sin etiquetas.
5. Abre el selector de Biblioteca y cambia a Artistas. En Favoritos y Listas cambia el criterio y la dirección desde Ordenar. En Listas comprueba el acceso Nueva lista.
