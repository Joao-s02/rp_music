# Guía de uso vigente

La versión publicada de referencia es **RP Music 0.3.3-alpha.1**, app **0.3.3+12**, para Android y Windows.

- [Abrir guía de uso 0.3.3](USO-0.3.3.md).
- [Qué probar](PRUEBAS-0.3.3.md).
- [Cambios de la versión](CAMBIOS-0.3.3.md).
- [Descargar instaladores y hashes](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.3-alpha.1).

Android: actualizar encima de la anterior, sin desinstalar para conservar datos. Windows: extraer el ZIP completo, con ejecutable, DLL y data juntos. Las extensiones se instalan/actualizan por separado desde su catálogo, con permisos revisados.

Esta página es la entrada a la guía actual; las instrucciones de versiones anteriores permanecen en sus archivos versionados. La antigua guía general de 0.2.6 se conserva en [USO-0.2.6.md](USO-0.2.6.md). Documentación completa: [índice](README.md).

## Cambios de 0.3.4

Ahora suena mantiene anterior/pausa/siguiente visibles. Letras → Importar permite elegir LRC sincronizado o TXT en UTF-8; tocar una línea LRC salta a ese momento. Las letras se conservan sin alterar el audio. En fuentes compatibles, el botón de nube consulta letras en línea enviando título/artista/duración al proveedor declarado por la extensión.

Paquetes externos compatibles con 0.3.4: importar el de YouTube correspondiente a Android o Windows y aceptar el permiso de descarga si se desea. El icono Descargar junto al resultado abre el selector después de recibir el audio (hasta 64 MiB); guardar en la raíz musical y actualizar biblioteca para incorporarlo. Cancelar no guarda una canción. No es una descarga en segundo plano.

Spotify experimental para ambas plataformas: acceso propio, Usar esta fuente y pegar enlace público de canción. Solo reproduce la vista previa cuando existe; no reproduce canciones completas ni busca por nombre. Sus letras se muestran sin sincronizar con el fragmento. Estas funciones requieren 0.3.4; 0.3.3 no las incorpora.

La variante YouTube Windows sigue siendo experimental: su reproducción nativa falló en las pruebas de preparación. La recepción de bytes no se considera prueba de reproducción. No se actualizó el catálogo publicado.
