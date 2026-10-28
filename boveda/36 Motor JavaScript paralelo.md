---
tipo: implementacion-experimental
estado: publicado-con-validacion-fisica-pendiente
actualizado: 2026-10-28
---
# Motor JavaScript paralelo

## Alcance confirmado

Usuario solicita prototipo JavaScript y extensión de prueba, preservando las extensiones YouTube actuales. Se conservan API 1 y API 2/Dart; ninguna migración automática. En la etapa inicial no estaba autorizada la publicación; autorización posterior y confirmación al final de esta nota. Antecedente [[04 Extensiones]], [[31 Arquitectura vigente]] y [[35 Ampliacion de YouTube sin API oficial]].

## Elección provisional e implementación

App local 0.3.8+17 añade API 3/engine javascript con capacidad screen independiente. QuickJS ejecuta eventos síncronos en contexto nuevo por llamada; estado JSON propio autorizado persistente. Componentes genéricos nativos column/row/card/text/input/button/divider permiten que la extensión defina sus árboles y páginas, formularios y eventos. No es Node.js, HTML/CSS ni Flutter arbitrario. Datos de biblioteca hasta 500 canciones con IDs opacos y reproducción explícita por permisos. Código específico de prueba solo en rp-music-extensions: Laboratorio JS 0.1.0, fuera de catálogo/paquetes de app.

Se ensayó flutter_js 0.8.7 y se descartó antes de entregar: DLL Windows no exporta límite de memoria y jsNewRuntime ignora timeout en el puente antiguo; el bucle no se interrumpe nativamente. No usar timeout de Future como prueba de parada de FFI. Se sustituye por flutter_qjs_next 1.5.2, compilado desde fuentes, con timeout nativo 1000ms/heap32MiB y JsWebApis.none. Pruebas nativas en curso; resultados finales al cerrar. Estos límites no equivalen a aislamiento OS ni cuota total de proceso.

Referencias primarias consultadas: https://github.com/abner/flutter_js , https://github.com/abner/quickjs-c-bridge/blob/master/cxx/libfastdev_quickjs_runtime.cpp y https://github.com/NanCunChild/flutter_qjs_next . Fuente publicada descargada de pub.dev revisada localmente para timeout/memoryLimit y controles de APIs web.

Registro de plugins Flutter regenerado tras añadir dependencia; se usaron junctions locales dentro de windows/flutter/ephemeral para compilar sin cambiar modo desarrollador de Windows. No se alteran opciones del sistema ni paquetes Dart estables. Recompilar entrada main normal al finalizar sondas/pruebas.

## Pendientes

Verificar motor nativo, interrupción de bucle, contexto/estado, UI estrecha y paquetes reales Dart; compilar APK/Windows normales y preparar guías locales. Prueba física Android según disponibilidad. No prometer red/secretos/cuentas, npm, UI libre o SDK completo por este prototipo. Contrato en docs/EXTENSIONES-API-3.md.

Verificación parcial con motor definitivo: once pruebas dirigidas aprobadas (nueve del anfitrión, dos específicas externas), incluidas ejecución/estado, árbol inválido, interfaz360px, revocación y paquetes reales Dart. Interrupción nativa de bucle en 1037ms, inferior al deadline exterior4s; siguiente evaluación correcta. Windows normal con plugin compilado en151.5s. No hay dispositivo Android conectado según adb; APK en compilación, suite completa y binarios definitivos pendientes.

Suite completa final:120 aprobadas y una prueba de red optativa omitida; análisis lib/test/integration_test/tools sin incidencias. Las dos pruebas específicas de extensión externa se mantienen aparte y no se suman repeticiones. Capturas históricas regeneradas por la suite restauradas byte a byte. Primera compilación Android compiló QuickJS en cuatro ABI, pero falló por registrante Java de integration_test heredado de las pruebas; se regenera entrada normal con pub habilitado al cerrar. Sin Android físico conectado.

## Verificación final

122 pruebas aprobadas en una ejecución conjunta:120 de la app y2 de la extensión externa; una prueba optativa de red omitida. No se suman repeticiones. Incluye liberación del heap antes de comunicar el resultado al anfitrión para que matar el isolate no interrumpa dispose. Análisis completo sin incidencias. Windows normal final compilado en107.5s, ProductVersion0.3.8+17, ZIP completo21 archivos con flutter_qjs_next_plugin.dll, íntegro y sin rpmx. APK normal compilado en171.7s y se regenera después de la suite final para asegurar registros de producción; resultado definitivo al cerrar.

Hash estable YouTube 0.4.0=7caf7c3a08f5f7d1f3daf48d5ee384b71be8d087840859d8563686017ff88d2d y Explorador0.1.0=75f155625bc759ac48bd7aae97d6570937eac06139886b204a7a3b38cf137348 intactos. Catálogo sin cambios semánticos y sin archivos rastreados modificados en repo externo. Laboratorio JS permanece candidato local fuera del catálogo, paquetes solo en repo externo. No push/release ni prueba física Android; adb sin dispositivos. La prueba de compatibilidad ejecuta operaciones reales de código de ambos paquetes Dart, no una escucha nueva completa de YouTube.

Entrega final local: APK normal universal regenerado en124.0s después de suite, versión0.3.8/código17, tres ABI Flutter con libflutter_qjs_next.so. Paquetes en dist/0.3.8-local con guía y manifiesto SHA256; extensión en repo externo/previews/js-lab-0.1.0. APK y ZIP no contienen rpmx. Hashes finales:

2e90caa046efee30012936cdef6e6d16427ba6ac406fdcce77e084ee983a3bb5  PROBAR.md
1f756625ce4412d8de63fd02b3ad2718191685cf5c037744725d8c2ad8a11212  RP-Music-0.3.8-local-android.apk
f4831ccdbce991dfe8f7a0a3a82e1a0503f49d010e0b603d1aea7514aba1bd56  RP-Music-0.3.8-local-windows-x64.zip

Sin publicación, push ni cambio de catálogo. Prueba física Android pendiente.

APK final verificado: firma v2 válida y certificado SHA256 eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d, compatible con versiones anteriores; aapt confirma código17, versión0.3.8 y arm64-v8a/armeabi-v7a/x86_64.

2026-10-28: usuario autoriza publicar release0.3.8. Se preparan universal/ARM64/Windows y guías/hashes; Laboratorio JS como opción separada en catálogo, previas intactas. Confirmación remota pendiente hasta finalizar.

## Publicación confirmada

2026-10-28: release pública https://github.com/Joao-s02/rp_music/releases/tag/v0.3.8-alpha.1, app 0.3.8+17, tag/código d5452275e1023e6125feca130b884180f14b2a1e, release ID 426315233. Universal reutiliza binario normal final verificado; ARM64 release normal 165.0s, código17/versionName0.3.8 y firma v2 compatible. Windows normal ProductVersion0.3.8+17, ZIP completo con flutter_qjs_next_plugin.dll y guías. Siete adjuntos verificados en borrador por tamaños/digests SHA256 y target; después API pública confirmó publicación/prerelease, mismos siete tamaños/hashes, tag correcto y manifiesto descargado idéntico. Extensiones de código 9116d70e70a954618675d6d0e66b32cfb580d39f: catálogo de seis opciones verificado por cliente real; Laboratorio JS, YouTube estable y Explorador descargados y comparados byte a byte. Commits documentales posteriores no modifican binarios. Sin prueba física Android; SDK JS experimental sin Node/red/HTML libre. No se modifican releases anteriores.
