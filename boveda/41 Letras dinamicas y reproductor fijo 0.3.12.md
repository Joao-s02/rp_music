---
tipo: requisitos-correccion-y-diseno
estado: publicado-con-validacion-y-limites
actualizado: 2026-10-28
---
# Letras dinamicas y reproductor fijo 0.3.12

## Informe confirmado y alcance

El usuario prueba0.3.11 y confirma que el cambio de canción deslizando funciona, pero el movimiento vertical del reproductor ampliado interfiere algunas veces. Solicita estrictamente:

1. Recuperar letras incrustadas sincronizadas en descargas; informa que las nuevas aparecen planas, a diferencia de antes.
2. Renovar letras con animaciones/presentación expresiva, apta para grabar pantalla como vídeo de letras. No equivale a exportador de vídeo ni a garantía de audiencia.
3. Reproductor ampliado quieto y refinado, sin pequeño desplazamiento vertical.
4. Gesto horizontal sin competir con ese movimiento.
5. Volumen oculto tras botón junto a Detalles/Letras/Cola; mostrar control existente al pulsarlo.
6. Retirar indicador duplicado de nube/local debajo de la línea de tiempo; conservar el superior.
7. Eliminar/refinar bordes cian de carátula en tema oscuro.
8. Cola abre directamente en canción actual con anteriores/siguientes accesibles e indicador animado al reproducir.

Trabajo local0.3.12+21. Referencia pública0.3.11+20. No se solicita publicar otra release en este mensaje. Conservar identidad/icono maestro [[15 Identidad visual e icono]], controles visibles/texto ampliado [[32 Pruebas 0.3.3 y mejoras 0.3.4]] y proveedores exclusivamente externos [[04 Extensiones]]. Antecedente de metadatos coherentes en [[40 Gestos widgets albumes y descargas 0.3.11]].

## Diagnóstico y decisiones

La puntuación anterior otorgaba tres puntos a coincidencia de álbum y uno a letras sincronizadas; podía preferir texto plano del álbum exacto a LRC de la misma interpretación en otra edición. Además, no se intentaba consulta alternativa si había texto plano. La duración se convertía con split('.') en el intérprete Dart, cuya implementación trata patrones como expresiones regulares: perdía la parte numérica y desactivaba la comprobación. Se reemplaza por valores numéricos int/double; pruebas rechazan duración incompatible. Letras y metadatos de álbum se deciden por separado: sincronización válida gana entre interpretaciones coincidentes; no cambia el álbum elegido ni se inventan tiempos.

Fuente común nueva lyrics_result_0312.dart y cinco candidatos externos en previews/0.3.12: YouTube Android/Windows0.5.1, Explorador Android/Windows0.2.1 y Letras locales0.1.1, minApp0.3.12. Catálogo/paquetes publicados permanecen intactos. Se retiene texto disponible si la consulta alternativa falla, respetando contexto64KiB. El anfitrión valida que syncedLyrics incluya marcas LRC; una mejora sincronizada en caché privada precede al texto incrustado antiguo. Reconsulta no degrada una sincronizada por texto plano. Abrir Letras puede intentar mejorar una plana mediante proveedor autorizado; no se escriben archivos originales.

ExpandedPlayer abandona SingleChildScrollView y distribuye con restricciones reales, carátula flexible y disposición horizontal cuando corresponde. Volumen en panel modal sin mover la pantalla base. Un solo indicador superior de origen; carátula sin borde cian. Cola con scroll inicial centrado por índice, filas adaptadas a escala de texto e indicador decorativo animado de reproducción (no analizador DSP). Pausado/movimiento reducido detienen animación.

Letras: lectura viva con foco y desplazamiento al tiempo real, búsqueda/importación conservadas, vista Escena con transiciones, fondo cian/violeta, tipografía grande y controles ocultables al tocar el fondo. Respeta movimiento reducido. EnhancedLRC reconoce marcas explícitas por palabra; LRC común se anima por línea, sin simular sincronización por palabra. Línea tocada permite seek. Pausa/seek/cambio de pista usan posición real.

## Verificación en curso

Ocho pruebas nuevas dirigidas aprobadas: incrustación/lectura LRC y caché sobre texto anterior, EnhancedLRC sin tiempos ficticios, cuatro tamaños de reproductor fijo/gesto diagonal/volumen oculto y texto1.6, cola centrada78/100 con indicador que se pausa, letras vivas y Escena/controles ocultos. Regresión de letras anterior detectó Material de tinta oculto por fondos; se añadió superficie transparente apropiada. Lectura de caché en test de escena se precarga en runAsync como en contexto real; no presentar reloj falso de tests como fallo de IO nativo.

Cinco paquetes reales verificados con dart_eval: prioridad sincronizada, alternativa, retención tras fallo, duración e identidad. Consulta pública real de una canción devolvió55 líneas con tiempos; texto no impreso ni entregado como artefacto. Prueba nativa de descarga/incrustación/reproducción en curso. Pendientes suite completa, análisis final, revisión visual con capturas sin bandera debug y binarios normales posteriores a integración. Sin Android físico conectado.


## Autorización posterior de publicación — 2026-10-28

El usuario solicita continuar y luego subir la nueva release. Se publica0.3.12+21 tras cerrar validaciones, con universal/ARM64/Windows, guías/hashes y cinco actualizaciones del catálogo externo. Se mantiene registro separado de preparación local, pruebas y publicación. [[41 Letras dinamicas y reproductor fijo 0.3.12]].

## Cierre de validación previo a publicación

155 pruebas aprobadas, una optativa omitida, análisis limpio. Ocho pruebas dirigidas incluyen texto 1.6 y 2, espacios del sistema y cuatro tamaños. Descarga nativa Windows: 55 líneas sincronizadas incrustadas, reproducción real y solicitud de seek a un tiempo de letra; SHA256 de bloques mdat conservado. Capturas revisadas de widgets Flutter, sin representar dispositivo físico. Compilaciones normales posteriores a integración: Windows 90.5s, Android universal 131.8s y ARM64 153.5s. APK versión 0.3.12, código 21; firma conservada y ABI verificadas. Windows ZIP completo de 32 archivos. Siete adjuntos y hashes preparados. Extensiones publicadas en 1121a41: diez opciones y 25 paquetes/variantes verificados byte a byte. Sin Android físico conectado; escucha prolongada, valoración visual real y latencia API3 pendientes.

## Publicación comprobada — 2026-10-28

0.3.12-alpha.1 publicada, app0.3.12+21. ReleaseID 427362713; tag/código ea48d880c9c48c599026fe6605e4f94ce175bb85. Android universal/ARM64 y Windows x64 completo (32 archivos, licencias y guías). Siete adjuntos comprobados en borrador y por API pública: tamaño, SHA256, destino del tag y manifiesto descargado idéntico. Catálogo externo 1121a419cf4999b765de64cb0374ccf241bd28ec: diez opciones y 25 paquetes/variantes comprobados byte a byte; cliente real selecciona YouTube0.5.1, Explorador0.2.1 y Letras locales0.1.1. 155 pruebas aprobadas/una optativa omitida, análisis limpio; descarga nativa Windows con55 líneas LRC incrustadas, reproducción y bloques de audio conservados. Android físico, escucha prolongada, valoración visual del usuario y latencia API3 Android pendientes. [[41 Letras dinamicas y reproductor fijo 0.3.12]].

[Release pública](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.12-alpha.1). Las secciones de preparación anteriores describen el orden histórico, no el estado final.
