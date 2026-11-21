# Pruebas de RP Music 0.4.8

El análisis de Dart quedó limpio en los archivos modificados. La prueba directa de Flutter comprobó el tamaño de la portada en Android, el menú de álbum, la barra del minirreproductor de Windows y la respuesta a los atajos simulados.

## Pruebas en dispositivos

1. Actualiza desde 0.4.7 y confirma que se conservan la biblioteca, los favoritos y las listas.
2. En Android, compara las portadas de un álbum y de una lista. Verifica el fondo con carátulas claras y oscuras.
3. Entra a un álbum. Comprueba que su único menú permite guardar las canciones en una lista o añadirlas a la cola. Vuelve a la cuadrícula.
4. En Windows, pulsa la portada, el título o la barra del minirreproductor para expandirlo. Comprueba el progreso y ajusta el volumen en el reproductor expandido.
5. Prueba los atajos descritos en USO.md con el teclado físico y comprueba que puedas escribir normalmente en la búsqueda.
