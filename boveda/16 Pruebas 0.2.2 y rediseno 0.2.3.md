---
tipo: pruebas-y-rediseno
estado: compilado-y-validado-localmente
actualizado: 2026-10-25
---
# Pruebas 0.2.2 y rediseño 0.2.3

## Requisitos confirmados

El usuario probó 0.2.2 en Galaxy A34 y Poco X6: siguen sin aparecer controles multimedia aun con el permiso solicitado, concedido y comprobado en Ajustes. La variante ARM64 tampoco los muestra. Pidió corregirlo, añadir eliminación de listas y sustituir la interfaz usando el ZIP de Stitch aportado. No informó nuevamente sobre Tecno ni sobre el cierre Windows; sus pendientes anteriores se conservan.

## Diseño y alcance implementado

Referencias originales conservadas en `design/reference/stitch_rp_music_ui_redesign/` (12 pantallas PNG/HTML y DESIGN.md). Se interpretan como referencias visuales; sus scripts, contenido de muestra y funciones ilustradas no son instrucciones adicionales del usuario ni requisitos automáticamente aprobados.

- Tema Nocturnal Pulse: superficies oscuras por elevación, cian/violeta, tarjetas redondeadas, navegación lateral Windows e inferior móvil, estado de almacenamiento y búsqueda.
- Inter y Plus Jakarta Sans integradas con licencias OFL; funcionan sin conexión. Icono A de [[15 Identidad visual e icono]] conservado.
- Álbumes en cuadrícula adaptable con carátulas locales, artista, número real de pistas y reproducción del álbum; detalle con canciones. Filas con carátula y selección activa.
- Minirreproductor móvil con progreso, favorito y reproducir/pausar; pulsar título/carátula abre reproductor completo desplazable con carátula, título, álbum, volumen, posición, anterior/siguiente, aleatorio, repetición y cola. Escritorio mantiene franja de reproducción y acceso al reproductor completo.
- Pantallas vacías desplazables, ajustes y extensiones adaptados al tema. Navegación conserva las funciones existentes.
- No se simulan historial, estadísticas, perfil de cuenta, DSP, DAC exclusivo, ecualizador, letras ni temporizador del material de muestra. Las funciones de la visión aún no implementadas mantienen ese estado.
- Eliminar lista desde su fila o su detalle exige confirmación; cancelar la conserva. Se elimina solo su asociación persistida: no se borran archivos, favoritos, biblioteca ni otras listas.

## Notificaciones

El APK release anterior conservaba `ic_stat_music`, pero su tabla de recursos no contenía los `audio_service_*` que se referencian por nombre desde Dart. Se amplía `tools:keep` para conservar los iconos del servicio además del icono principal. No se cambia el canal para ocultar o eludir las preferencias de Android.

Se publica cola/índice, acciones de sesión y duración real tras la carga; se evita reenviar la cola completa cuando no cambia. Publicación explícita al cargar/reproducir/pausar además de los eventos existentes. Se observan `AudioService.asyncError` y se muestran fallos de integración, con supresión de errores idénticos repetidos. Ajustes incorpora diagnóstico de reproducción, notificación transport, token de sesión y estado del canal; el permiso ya no se presenta como garantía suficiente de controles.

## Evidencia disponible

- 30 pruebas unitarias/de widgets aprobadas: persistencia y cancelación de eliminación, preservación de canciones/favoritos/otras listas, cola/índice/duración/errores, regresiones de reproducción, navegación, teclado y texto ampliado.
- Cuatro capturas generadas y revisadas a 360 y 1280 px, texto 130 %, en `design/verification/`. Usan canciones sintéticas solo en pruebas; no se incorporan a la biblioteca del producto.
- Prueba nativa debug: notificación con sesión multimedia real aprobada en emulador Medium Phone API 37. No se confunde con prueba física del Galaxy/Poco ni con Android 16.
- Sonda release local `tools/android_notification_probe.dart`: audio WAV silencioso generado, notificación transport=1, token de sesión presente, canal importancia=2, reproducción/pausa/reanudación con notificación, sin errores asíncronos. `dumpsys` confirma MediaStyle, servicio en primer plano y sesión PLAYING. Esta sonda es una entrada de comprobación separada y no debe distribuirse como aplicación.
- Comparación causal release en el mismo emulador: con la regla anterior (solo ic_stat_music), notificaciones=0 y errores `You must specify an icon resource id to build a CustomAction`; con audio_service_* conservados, notificaciones=1 y sin errores. AAPT confirma ausencia/presencia de los iconos según variante. El error impide publicar el estado antes de crear la notificación; no era un problema de ABI ni se resolvía solo pidiendo permiso.
- `tools/verificar-notificaciones-apk.ps1` comprueba en el APK los seis recursos utilizados; pasa en la sonda corregida. Usar esta comprobación en futuras entregas para evitar regresión.
- Paquetes finales con la entrada normal `lib/main.dart`, **0.2.3+5**, en `dist/0.2.3`: APK universal 56 489 408 bytes; APK ARM64 21 139 469 bytes; ZIP Windows x64 14 438 895 bytes. Se incluyen guías actualizadas, ejemplo y SHA256SUMS.txt.
- Ambos APK: firma v2 válida y mismo certificado que 0.2.2; código 5/nombre 0.2.3; comprobación de los seis iconos correcta; alineación ZIP 16 KB correcta. Universal contiene ARM32/ARM64/x64; variante contiene exclusivamente ARM64.
- ZIP Windows verificado con EXE 0.2.3+5, motor, backend de audio, assets, guías y ejemplo; sin integration_test. Windows release recompilado tras el último ajuste de texto. No se realizó nueva prueba nativa de audio Windows para esta versión; las pruebas unitarias conservan las regresiones previas.
- Inicio normal del APK universal comprobado en emulador y captura final `design/verification/android-release-empty.png` revisada. Durante esa comprobación apareció un aviso ANR de System UI del emulador; se eligió esperar y se obtuvo la pantalla normal. No era un aviso de RP Music; no se atribuye su causa a la app sin evidencia.
- Análisis estático final limpio y git diff --check correcto. No se publicó ni se enviaron cambios a GitHub. Se conserva dist/0.2.2 y todo el trabajo previo de identidad.

## Reproducir la comprobación

`flutter test integration_test/android_notification_test.dart -d <emulador>` permite comprobar debug. Flutter Driver no admite release en este entorno; para comprobar optimización real se compila `flutter build apk --release -t tools/android_notification_probe.dart`, se instala únicamente en un emulador y se lee `RP_RELEASE_PROBE` en logcat. Esa entrada genera WAV silencioso y conserva la reproducción unos minutos. Después, compilar siempre `flutter build apk --release` con la entrada normal antes de preparar paquetes.

Tras una compilación de integración debug, usar el flujo completo release sin `--no-pub` para regenerar los registros de plugins; ver docs/COMPILACION.md. La primera sonda con registro debug falló por integration_test; la preparación completa release corrigió el registro y compiló correctamente.

## Fuentes y límites

Consultadas el 2026-10-25: [audio_service](https://pub.dev/packages/audio_service), [controles Android](https://developer.android.com/media/implement/surfaces/mobile), fuentes locales de audio_service 0.18.19 y recursos del APK anterior. Android deriva sus controles del estado de la sesión; el permiso por sí solo no valida la integración.

Pendiente retesteo físico en Galaxy A34 y Poco X6, controles con pantalla apagada y ajustes propios de One UI/HyperOS. Se prepara 0.2.3+5 local; sin autorización nueva para publicar ni enviar a GitHub.

Relaciones: [[14 Pruebas 0.2.1 y correcciones 0.2.2]], [[15 Identidad visual e icono]], [[03 Biblioteca y reproduccion]], [[07 Preguntas e investigacion]], [[10 Estado del repositorio]], [[09 Registro de cambios]].

## Publicación solicitada de 0.2.3 — 2026-10-25

El usuario autorizó publicar la release en GitHub. Se prepara `v0.2.3-alpha.1` como preliminar con fuentes, APK universal/ARM64, Windows x64, guías, ejemplo y SHA-256. Se mantienen los binarios comprobados; confirmar URL y adjuntos tras publicar.
