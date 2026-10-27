---
tipo: estado-actual
estado: publicado-con-limites-experimentales
actualizado: 2026-10-27
---
# Estado del repositorio

## Referencia publicada

**0.3.4-alpha.1**, aplicación **0.3.4+13**, Android universal/ARM64 y Windows x64. [Release pública](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.4-alpha.1).

- Tag/código: d873ae3ada998fcefc89b4a5f98cd298f9db6204.
- Extensiones: 833044ab11a2d03a4fd82134822246fc52149aed de rp-music-extensions, exclusivamente en ese repositorio.
- Siete adjuntos públicos verificados por tamaño/SHA-256: dos APK, ZIP Windows completo, USO, PRUEBAS, CAMBIOS y SHA256SUMS. Manifiesto descargado públicamente idéntico al local.
- Evidencia, hashes, preparación y fallos conservados en [[32 Pruebas 0.3.3 y mejoras 0.3.4]]. La entrega anterior permanece en [[29 Pruebas 0.3.2 y mejoras 0.3.3]]; antiguos estados acumulativos en [[30 Archivo de navegacion y estado]].

## Capacidades actuales

| Área | Estado |
| --- | --- |
| Biblioteca local | Raíz/subcarpetas, caché, escaneo manual/progresivo, búsqueda, álbumes/artistas/carpetas y orden. |
| Audio | Cola de selección, controles, volumen, aleatorio/repetición, historial anterior/avance local y restauración sin autoplay. |
| Listas y archivos | Manuales/favoritos, carátulas, añadir álbumes; automáticas por extensión; borrado confirmado, metadatos de lectura. |
| Reproductor | Carátula/espacios adaptables y controles principales fijos fuera del desplazamiento, incluso con disposición de extensión. |
| Letras | Importación UTF-8 LRC/TXT, copia privada por canción, sincronización por línea/seguimiento/seek y consulta opcional mediante extensión. No extracción incrustada ni sincronización por palabra. |
| Android | Sesión/notificación, carátula/controles, permisos y widget; retesteo físico de esta versión pendiente. |
| Windows | Audio local, volumen y bandeja/salida. Fuente YouTube Windows candidata con ensayos nativos fallidos; no declararla compatible funcional. |
| Descargas | Exportación manual por fuente con storage.download, selector, límite 64 MiB/3 min y transporte acotado. Guardado real mediante selector pendiente de validación en dispositivo. |
| Actualizaciones | Consulta opcional/manual/diaria y canales, descarga/verificación; Android solicita instalador, Windows extrae ZIP manualmente. |
| Extensiones | API 1/2 experimental, permisos, recuperación, catálogo compatible y múltiples destinos; una fuente elegida con acción explícita. |

Comportamiento en [[03 Biblioteca y reproduccion]], contratos/paquetes en [[04 Extensiones]], módulos en [[31 Arquitectura vigente]].

## Extensiones para esta app

Catálogo: YouTube Android 0.3.0 (letras/descarga), Spotify · vistas previas 0.1.0 (Android/Windows, solo fragmentos por enlace), Biblioteca viva 0.1.1 y Pulso nocturno 0.1.0. Paquetes nuevos requieren anfitrión 0.3.4. Variantes 0.3.1/0.3.2/0.3.3 conservadas.

YouTube Windows 0.3.0 es candidato manual fuera del catálogo recomendado; sus pruebas nativas fallaron. Spotify no aporta canciones completas ni búsqueda por nombre, y sus letras no se sincronizan con el fragmento. No hay nueva prueba nativa aprobada de estos paquetes. Ninguna extensión viene instalada, dentro del APK/ZIP ni adjunta a la release principal.

## Verificación registrada de 0.3.4

| Comprobación | Resultado y alcance |
| --- | --- |
| Suite completa | 97 pruebas aprobadas; las repeticiones seleccionadas no se suman como casos nuevos. |
| Análisis | Sin incidencias. |
| UI/letras | Controles visibles en cuatro tamaños, capturas 360/1280 inspeccionadas; caché/resaltado/seek/cambio de canción LRC comprobados. |
| Paquetes/red | Intérprete real y bytes de audio; no confundir con escucha nativa. Catálogo público y nuevos paquetes externos comparados. |
| Android normal | Universal/ARM64 compilados; versión/código 0.3.4/13, ABI y firmas correctos, certificado compatible con 0.3.3. Sin dispositivo conectado para instalar/abrir. |
| Windows normal | Release 0.3.4+13 compilada; proceso activo tras 5 s y ZIP de 20 archivos íntegro, sin sonda ni paquetes de extensión. |
| Publicación | Borrador y API pública verificados: siete archivos, tamaños/digests SHA-256 correctos, tag y manifiesto descargado confirmados. |

## Pendientes activos

YouTube Windows funcional, Spotify completo y búsqueda por nombre sin cuenta; exportación real con selector, nuevos paquetes Android/Spotify y escucha física/segundo plano prolongado. También actualización entre releases conservando datos, formatos/redes/SAF/SD/launcher, cuentas/listas/favoritos/historial online, edición de etiquetas/gapless/fundido/cola editable, ecualizador como extensión y aislamiento/métricas/firmas del SDK/licencia. [[07 Preguntas e investigacion]].

La consolidación documental previa se incluyó con la publicación autorizada; notas históricas conservan sus fechas y evidencia. No convertir antecedentes de dispositivos/versiones anteriores en pruebas físicas de 0.3.4. Publicación posterior siempre requiere autorización; requisitos en [[27 Publicacion de releases - contenido obligatorio]].
