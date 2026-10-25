---
tipo: estado
estado: primer-incremento-compilado
actualizado: 2026-10-25
---
# Estado del repositorio

## Estado actual

Trabajo local vigente: **0.2.3+5**, interfaz Stitch y correcciones posteriores al informe 0.2.2. Consultar [[16 Pruebas 0.2.2 y rediseno 0.2.3]] y la actualización al final de esta nota para evidencia y paquetes. La última publicación sigue siendo 0.2.2; la nueva versión permanece local.

Identidad confirmada el 2026-10-25: el usuario eligió `assets/branding/rp-music-variant-a.png`. Integrado en lanzador Android adaptativo, ICO Windows para ventana/bandeja e iconos web. Windows debug compilado y APK Android release completo compilado tras instalar/seleccionar Temurin JDK 17.0.20.1+1 en usuario y Flutter; firma APK v2 verificada. APK 0.2.2+4 local con icono A en `build/app/outputs/flutter-apk/app-release.apk`, sin publicar ni reemplazar adjuntos de dist. Pautas de diseño documentadas; tema Flutter sin rediseñar. Ver [[15 Identidad visual e icono]] y docs/COMPILACION.md para validación y límites.

Actualización 2026-10-25: aplicación `0.2.2+4` publicada como `v0.2.2-alpha.1`, con notificaciones, volumen y bandeja. Etiqueta en `9f1e4f80966d5d020235200e23b6b58170c8b7fc`, fuentes en `main`, ocho adjuntos verificados por tamaño/digest y release confirmada como preliminar publicada. Ver [[14 Pruebas 0.2.1 y correcciones 0.2.2]] para límites y pendientes. El estado que sigue describe antecedentes de 0.2.1/0.2.0.

Actualización posterior: aplicación `0.2.1+3`, publicada como release preliminar `v0.2.1-alpha.1` en GitHub tras autorización. Etiqueta sobre `4b094e164123a5615285e5637043a4bcf24811c5`; seis adjuntos y sus hashes verificados. Ver [[13 Pruebas reales y correcciones 0.2.1]] para implementación, evidencia y pendientes. Las afirmaciones de la primera base que siguen describen el antecedente 0.2.0.

Raíz: `C:\joao\flutter\music_reprod\rp_music`. El usuario autorizó la reconstrucción. Se reemplazaron las fuentes de aplicación y pruebas del alfa, y se conservan Git, bóveda y plataformas. Manifiesto `rp_music`, versión `0.2.0+2`.

La implementación y sus decisiones provisionales están en [[11 Reconstruccion - primera base]]. El README contiene instrucciones reales de ejecución y la guía del ejemplo está en `examples/extensions/README.md`.

## Verificación realizada

- Flutter 3.47.6 y Dart 3.13.5 instalados y ejecutados.
- Análisis estático de código y pruebas: sin problemas.
- Suite: 13 pruebas aprobadas, incluidas navegación móvil/escritorio y carreras de reproducción con motor simulado.
- Compilación Android debug: `build/app/outputs/flutter-apk/app-debug.apk`.
- Compilación Windows debug: `build/windows/x64/runner/Debug/rp_music.exe`. El ejecutable necesita los DLL y carpeta de datos que lo acompañan; no distribuir solo el EXE.
- No hay pruebas manuales en dispositivo, comprobación física de audio, mediciones de rendimiento ni validación de todos los formatos. No se ha abierto la bóveda visualmente en Obsidian.

Windows no tenía habilitado soporte habitual de symlinks. Se prepararon junctions temporales en `windows/flutter/ephemeral/.plugin_symlinks` sin cambiar ajustes globales. El backend `just_audio_windows` necesitó una definición de compatibilidad de cabeceras coroutine con Visual Studio 2026, limitada a ese target en CMake. Reevaluar backend antes de estabilidad.

## Funcionalidad aún pendiente

Letras, edición de etiquetas, restauración de sesión, cola editable, bandeja y controles del sistema Windows, gapless/fundidos, carátulas de biblioteca, benchmarks, permisos de extensiones, panel de consumo, runtime ejecutable e integraciones con servicios. La personalización importable actual es declarativa, no el SDK completo. Web queda fuera del incremento.

## Antecedentes y conservación

Al crear la bóveda existían fuentes alfa y un documento `arquitectura-reproductor-flutter.md`. Ese documento es histórico: sus paquetes y prioridades no son decisiones actuales por defecto. No hay migración de la biblioteca alfa; los nuevos datos se guardan en `v2` dentro del soporte de aplicación.

La publicación fue solicitada por el usuario y completada en `Joao-s02/rp_music`: release preliminar `v0.2.0-alpha.1`, fuentes en `main`, APK y paquete Windows compilados en modo release, instrucciones, ejemplo y sumas SHA-256. La etiqueta apunta a `bdd01f012e3f6e8e61ac13ad6565ce32911beae8`. GitHub confirmó publicación y cinco adjuntos completos. Ver [[12 Release 0.2.0-alpha.1]]. Siguientes prioridades: [[06 Primera version]] y [[07 Preguntas e investigacion]].

## Trabajo local posterior: 0.2.3+5

Rediseño Flutter basado en el ZIP Stitch, tipografías integradas, álbumes en tarjetas, minirreproductor móvil y reproductor ampliado; eliminación persistida de listas con confirmación. Iconos dinámicos del servicio protegidos del recorte release, estado/cola/duración y diagnóstico multimedia. 30 pruebas aprobadas y sonda release aprobada en emulador API 37. Paquetes finales y comparación causal registrados en [[16 Pruebas 0.2.2 y rediseno 0.2.3]]. Sin publicar ni enviar fuentes a GitHub. Los cambios previos de identidad e iconos se conservaron.

Comprobación final 0.2.3: APK universal/ARM64 y Windows x64 compilados en release en `dist/0.2.3`, con guías, ejemplo y SHA-256; firmas Android v2, certificado de actualización coincidente, código 5 y ABIs verificados. Recursos multimedia presentes en ambos APK y comprobación negativa de regresión correcta. ZIP Windows íntegro y sin plugin de integración. La comparación causal release y el retesteo físico pendiente se detallan en [[16 Pruebas 0.2.2 y rediseno 0.2.3]]. Análisis limpio y diff sin errores.

## Publicación solicitada de 0.2.3 — 2026-10-25

El usuario autorizó publicar la release en GitHub. Se prepara `v0.2.3-alpha.1` como preliminar con fuentes, APK universal/ARM64, Windows x64, guías, ejemplo y SHA-256. Se mantienen los binarios comprobados; confirmar URL y adjuntos tras publicar.
