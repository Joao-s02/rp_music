# Cambios de RP Music 0.3.6

Aplicación 0.3.6+15 · release preliminar 0.3.6-alpha.1.

## Corrección principal

Se corrige el etiquetado de MP4/M4A fragmentado. En 0.3.5 se reemplazaba moov por espacio libre y se añadía al final para mantener posiciones de audio. Ese diseño funcionaba en los MP4 planos de las pruebas, pero un archivo fragmentado real fallaba al interpretar sus pistas.

El escritor distingue ambos casos: mantiene la inicialización antes de sidx/moof en archivos fragmentados y comprueba direccionamiento relativo. No recodifica; conserva audio/fragmentos/índice. Variantes absolutas o con índices no soportados se rechazan para que la descarga guarde audio original con aviso. MP4 plano mantiene el comportamiento anterior.

Se añade una herramienta genérica para reparar copias compatibles ya afectadas, sin sobrescribir entradas o salidas existentes. La app no modifica automáticamente archivos locales anteriores. No se publican canciones aportadas por el usuario.

## Verificación

110 pruebas aprobadas (cuatro regresiones nuevas) y análisis de los cambios sin incidencias. Prueba de red optativa omitida en esta suite; el recorrido de proveedores de 0.3.5 se conserva como antecedente.

Archivo real aportado: la copia reparada se reconoce y decodifica, 257.026667 s; 26 bloques de audio, 26 fragmentos y un índice idénticos por SHA-256. Escáner de escritorio encuentra título/duración sin omisiones. M4A fragmentado sintético etiquetado: ffprobe/ffmpeg reconocen etiquetas y decodifican correctamente. Sin recodificación ni cambios al original.

## Compatibilidad y límites

Android universal, ARM64 y Windows x64; código Android 15 y firma compatible con 0.3.5. Actualizar sin desinstalar. Extensiones sin cambios: YouTube Android 0.4.0, Letras locales 0.1.0, Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0, solo en rp-music-extensions.

Falta validar el arreglo en Android físico con la biblioteca/selector del usuario. No se observó directamente cómo su biblioteca omitía el archivo; se confirmó y reparó el fallo del contenedor. El cambio de nombre .m4a a .mp3 al transferir por Drive no se atribuye a una conversión: el archivo enviado seguía siendo MP4/AAC por contenido. La causa de ese renombrado no se verificó.

No hay reparación automática de descargas anteriores ni garantía de todas las variantes MP4. El lector de metadatos puede mostrar duración 0 en algunos fragmentados sintéticos aunque se descubran. YouTube Windows mantiene sus fallos nativos previos. Servicios/letras/metadatos dependen de disponibilidad. Spotify y Play Store siguen cancelados; licencia concreta pendiente.
