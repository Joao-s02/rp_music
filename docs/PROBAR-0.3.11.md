# Probar RP Music0.3.11

Release pública: https://github.com/Joao-s02/rp_music/releases/tag/v0.3.11-alpha.1 . [Guía vigente de instalación y catálogo](USO-0.3.11.md). La preparación y evidencia locales se conservan en [Resultados](RESULTADOS-0.3.11.md).

## Gestos y widgets Android

En la carátula del reproductor o el minirreproductor, desliza a la izquierda para siguiente y a la derecha para anterior. Los roces cortos no cambian canción; avance y volumen mantienen sus propios controles. Comprueba también una cola aleatoria y música en línea.

Mantén pulsado el inicio del teléfono → Widgets → RP Music. Hay tres tipos: compacto, horizontal y carátula. Después de colocarlo, mantén pulsado y arrastra sus bordes. El tamaño final y los pasos dependen de la cuadrícula del launcher. Al reducirlo se ocultan controles secundarios para conservar título y reproducción. Amplíalo para mostrar anterior/siguiente y portada. Si el launcher conserva información del widget antiguo, quítalo y vuelve a añadirlo. Comprueba controles con la app abierta/cerrada y una canción seleccionada.

## Listas y álbumes

Abre una lista: portada grande, nombre, cantidad/duración, Reproducir, Aleatorio y Cambiar carátula. Desplaza hacia abajo para ver canciones; quitar de lista sigue sin borrar audio. Las listas automáticas conservan indicador de activación y las referencias ausentes no se borran automáticamente.

En YouTube Explorador, busca un álbum y ábrelo: se muestra su portada grande, artista y pistas. Reproducir conserva el orden de la fuente. Descargar álbum reúne todas las páginas antes de empezar. Elige una carpeta una vez; la cola muestra canciones guardadas/fallidas y permite cancelar. Mantén RP Music abierto durante el proceso; todavía no es una cola persistente tras cerrar la app.

Las descargas no sobrescriben originales. Todos los archivos de un lote comparten álbum/artista de álbum/portada y numeración según el orden reunido; una pista fallida conserva su número para identificarla. Se incrustan los datos conocidos y letras disponibles, sin recodificar. No se inventan año, disco o álbum desconocido. Descarga dos canciones del mismo álbum y el álbum completo, actualiza biblioteca y comprueba que no se separen por una colaboración. La primera actualización relee una vez las etiquetas antiguas para incorporar artista del álbum, sin escribir en la música.

## Extensiones y fotos de artistas

En Extensiones → Explorar repositorio → https://github.com/Joao-s02/rp-music-extensions → Consultar, actualizar el paquete de tu plataforma y revisar permisos. Fuera de APK/ZIP/adjuntos:

- YouTube Android0.5.0 / YouTube Windows0.5.0.
- YouTube Explorador Android0.2.0 / Windows0.2.0.

Requieren app0.3.11. Son actualizaciones de sus identidades existentes y conservan API2/Dart. El catálogo público conserva las variantes para apps anteriores. Elige la extensión compatible como Fuente.

Las fotos requieren una de estas fuentes y aceptar library.read/consultas de red. Al abrir la app con conexión, la fuente busca retratos por nombre de artista; solo se aceptan coincidencias de identidad y dominios autorizados. Las imágenes se guardan en soporte privado de la app. Vuelve a abrir sin red: primero aparecen las fotos ya guardadas. Un artista sin coincidencia conserva el icono; no se reemplaza por una portada al azar. Las consultas son opcionales según la fuente/permisos y no modifican etiquetas locales. Caché acotada a64MiB; las imágenes más antiguas pueden eliminarse al alcanzar ese límite.

## Conservar lo confirmado y comunicar fallos

Windows0.3.10: el usuario confirmó YouTube con sonido/descarga y M4A/OPUS sin errores. Repite esos recorridos en0.3.11. La lentitud AndroidAPI3 informada previamente sigue como trabajo separado; estas fuentes no se migran a JavaScript.

Al informar un problema, indica plataforma, versión, pasos, formato o colección pública y código del diagnóstico. No compartas rutas privadas ni credenciales. Los resultados automatizados/nativos finales y los límites de pruebas se mantienen en la nota40 de la bóveda; Android físico requiere una prueba propia.
