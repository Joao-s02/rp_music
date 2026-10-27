---
tipo: implementacion
alcance: historico-de-version-o-proyecto
estado: primer-incremento
actualizado: 2026-10-24
---
# Reconstruccion - primera base

> **Alcance de esta nota:** conserva la entrevista, investigación o etapas de la versión/proyecto indicados. Expresiones «local», «vigente», «pendiente» o «sin publicar» se refieren a ese momento; leer la confirmación posterior dentro de la nota. Estado global actual en [[10 Estado del repositorio]] y decisiones temáticas desde [[00 Inicio]].

## Autorización

El usuario pidió empezar la reconstrucción y reiteró que podía eliminarse el código anterior. Se sustituyeron `lib` y `test`, conservando Git, la bóveda y las carpetas de plataforma. No se envió nada a GitHub.

## Decisiones de implementación provisionales

- Flutter nativo Android/Windows. Web queda fuera del incremento; el código usa `dart:io`.
- `just_audio` con `just_audio_windows` como backend inicial, sujeto a validación de códecs y rendimiento. `audio_service` para Android y `audio_session` para sesión de audio.
- Controladores pequeños con `ChangeNotifier` y streams del reproductor. Se retiraron Riverpod, Drift, SQLite y generación de código del alfa para esta base; no se afirma que esas herramientas fueran inadecuadas.
- Catálogo y preferencias en JSON con escritor serializado, archivo temporal y respaldo del guardado anterior; codificación/decodificación fuera del hilo de interfaz. Persistencia en subcarpeta `v2` del soporte de aplicación, sin migración del alfa.
- Windows: escaneo en isolate, sin seguir enlaces simbólicos; etiquetas sin imágenes durante el escaneo y carátula bajo demanda para la canción activa.
- Android: canal nativo Kotlin, `ACTION_OPEN_DOCUMENT_TREE`, permiso persistente de lectura y recorrido con `DocumentsContract`; metadatos mediante `MediaMetadataRetriever` en ejecutor de trabajo. No se solicita permiso general de lectura de medios.
- Escaneo manual por ahora. Inicio desde el catálogo guardado, sin escanear automáticamente; cambiar raíz solo se confirma cuando el escaneo termina con éxito.
- Selecciones de canción serializadas con generaciones para omitir selecciones obsoletas; pausar durante la carga conserva la intención de pausa.

Estas elecciones son implementación de este incremento, no preferencias atribuidas al usuario ni arquitectura definitiva del runtime de extensiones.

## Funciones presentes

Vistas de canciones/álbumes/artistas/carpetas, búsqueda con breve espera, listas virtualizadas, favoritos y listas persistentes, reproducción básica, posición, anterior/siguiente, aleatorio, repetición de canción, cola de selección, carátula activa y tema claro/oscuro. Interfaz en español adaptable.

La agrupación de álbumes usa álbum y artista de pista; compilaciones requieren mejorar el modelo. La cola actual se puede consultar y seleccionar, pero todavía no editar ni restaurar al reiniciar.

## Extensión de prueba

`examples/extensions/descubrir.json` cambia tarjetas/acento y aporta la acción predefinida `playRandom`. Se puede importar, activar, reemplazar explícitamente y desinstalar sin recompilar. El manifiesto se valida, limita a 64 KB y no concede permisos.

Es una **prueba declarativa**, no ejecución de código de terceros ni sustitución arbitraria de pantallas. El runtime programable, SDK, aislamiento, colaboración, niveles de permisos y panel de consumo siguen pendientes en [[04 Extensiones]]. No se ha satisfecho todavía todo el experimento de libertad de pantallas y lógica descrito en [[06 Primera version]].

## Verificación y límites

- Flutter 3.47.6 / Dart 3.13.5 comprobados.
- 13 pruebas automatizadas aprobadas: escaneo recursivo/formato, WAV de un segundo, recuperación de respaldo, persistencia, cancelación y fallo de raíz, manifiestos, selección de extensión, cambios rápidos, pausa durante carga, recuperación de error y navegación a 360/1280 px.
- Análisis estático de `lib` y `test`: sin problemas.
- Compilaciones debug de APK Android y ejecutable Windows completadas. Consultar [[10 Estado del repositorio]] para artefactos y alcance.
- No hubo pruebas físicas de audio ni uso manual en dispositivos. Las pruebas de carreras y UI utilizan un reproductor simulado. No se garantiza compatibilidad de todos los códecs por haber compilado.
- No hay benchmarks de fluidez, batería o RAM. Escaneo completo por actualización, sin índice incremental ni cancelación; JSON debe reevaluarse si las mediciones lo justifican.
- Windows necesitó enlaces temporales locales a complementos y una definición de compatibilidad para cabeceras antiguas del backend frente a Visual Studio 2026. No se modificó la caché del paquete ni el modo de desarrollador del sistema.

## Pendientes del producto

Letras, metadatos editables, restauración de sesión, bandeja/controles multimedia Windows, gapless/fundidos, carátulas de biblioteca, gestión completa de listas/cola, runtime de extensiones e integraciones. La integración multimedia Android está compilada, pero segundo plano/notificaciones deben probarse en dispositivo.

## Fuentes técnicas consultadas

- [Android: acceso a documentos y carpetas](https://developer.android.com/training/data-storage/shared/documents-files).
- [just_audio](https://pub.dev/packages/just_audio).
- [audio_service](https://pub.dev/packages/audio_service).
- [file_picker](https://pub.dev/packages/file_picker).

Consultadas el 2026-10-24; también se inspeccionaron fuentes locales de las versiones instaladas. No se investigaron todavía APIs de Spotify/YouTube Music ni políticas de Play Store.

Relaciones: [[02 Vision y decisiones]], [[03 Biblioteca y reproduccion]], [[05 Rendimiento]], [[07 Preguntas e investigacion]], [[09 Registro de cambios]].
