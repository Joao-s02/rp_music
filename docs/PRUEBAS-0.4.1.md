# Pruebas de RP Music 0.4.1

Aplicación 0.4.1+35. Distinguir las comprobaciones automatizadas de las realizadas en un teléfono o Windows real.

## Verificación de preparación

- Suite completa: 138 pruebas aprobadas, sin fallidas ni omitidas, con catálogo de prueba aislado.
- Análisis completo sin incidencias.
- Android universal y ARM64 release compilados con la entrada normal y firmados; versiones y ABI comprobadas durante el empaquetado.
- Windows x64 release compilado; se distribuye el conjunto de archivos del manifiesto de instalación y sus licencias.
- Prueba separada de capturas Flutter de Miku revisión 2 aprobada y revisada a ancho móvil/escritorio.
- Los casos nuevos verifican activación/persistencia y retirada de fotos, selección de revisiones compatibles, contraste de artista/canción, caché y descarte de portadas.


La consulta HTTP real de referencia comprobó Óscar Maydon/Tu Boda. Los Fernandez/Por eso canto sí aparece en el catálogo, pero la imagen coincide con una portada de otro álbum y se descarta; no se obtuvo un retrato alternativo válido. Las capturas Flutter usan datos de ejemplo y reproducción simulada, no equivalen a una prueba física.

## Recorrido Android

1. Instala universal o ARM64 sobre la versión anterior sin desinstalar. Revisa biblioteca, favoritos, listas, letras y temas.
2. Con Miku revisión 2, expande el reproductor desde cada pestaña y vuelve de Letras varias veces. Comprueba fondo, controles y ausencia de contenido anterior transparentándose dentro del reproductor.
3. Desplaza fuera de pantalla la canción actual: el resaltado debe acompañar a su fila. Revisa búsqueda y menús personalizados.
4. En Listas, baja/sube para recoger/recuperar cabecera. Abre una lista y prueba filtros, Reproducir/Aleatorio y menú de carátula/eliminación. Cancela el borrado y confirma que nada cambia.
5. En Temas, despliega cada sección; comprueba descarga, restauración, bloqueo de duplicados y actualización del Miku. Cambia al aspecto base y a Minimalista. Repite con texto ampliado y modo claro/oscuro.
6. Abre un LRC, expande letras, cambia línea, oculta controles y vuelve. Comprueba carátula de cabecera, seguimiento y ausencia del rótulo eliminado. Revisa también TXT sin tiempos.
7. En Artistas, confirma que las fotos no se consultan antes de activar el interruptor. Actívalo con conexión, revisa fuentes y desactívalo durante una consulta. Vuelve a activarlo y comprueba fotos guardadas sin conexión. No debe aparecer una imagen de otro artista mientras se recicla una fila.
8. Revisa reproducción con pantalla apagada, audífonos, notificaciones, widgets y regreso desde otra app. Comprueba batería/diagnóstico sin asumir que abrir ajustes ya cambia una restricción.

## Recorrido Windows

Extrae el ZIP completo, abre rp_music.exe, elige una carpeta y reproduce archivos locales. Revisa volumen, búsqueda, listas, letras, temas, consulta opcional de fotos, bandeja/salida y restauración sin audio automático. Prueba actualización conservando los datos privados y sin mezclar DLL viejas.

## Pendientes físicos

Los informes del usuario en Redmi Note 10S motivaron estas correcciones; el teléfono no estuvo conectado durante la implementación. La instalación final, tiempos de fotograma, Play Protect, escucha prolongada y recorrido Windows físico de esta release necesitan validación del usuario. No se ha retirado ninguna versión antigua como parte de estas pruebas.
