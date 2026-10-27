---
tipo: implementacion-e-investigacion
alcance: historico-de-version-o-proyecto
estado: antecedente-del-prototipo-publicado-en-0.3.0
actualizado: 2026-10-25
---
# Extensiones programables - primer prototipo

> **Alcance de esta nota:** conserva la entrevista, investigación o etapas de la versión/proyecto indicados. Expresiones «local», «vigente», «pendiente» o «sin publicar» se refieren a ese momento; leer la confirmación posterior dentro de la nota. Estado global actual en [[10 Estado del repositorio]] y decisiones temáticas desde [[00 Inicio]].

## Autorización y separación de entregas

El usuario pidió publicar 0.2.6 y comenzar la implementación de extensiones tras la entrevista de [[22 Extensiones - alcance del primer sistema]]. 0.2.6 se publicó primero sobre 2aa8648d7fe274e5b177ec773456613d6c52215f con sus siete adjuntos verificados; no contiene este motor. Este trabajo pasa a **0.3.0+9 local experimental**, sin autorización de otra publicación ni de enviar este incremento a GitHub.

## Elección técnica provisional

Se comparó documentalmente dart_eval (Dart puro, permisos del intérprete y ejecución AOT), flutter_eval (widgets Flutter dinámicos, pero más superficie de ejecución en UI) y alternativas QuickJS/FJS (requieren integración nativa; FJS advierte que no es aislamiento de código hostil). Se eligió probar **dart_eval 0.8.5** para lógica portable en isolates, con UI representada mediante contratos limitados del anfitrión. Esto es decisión técnica del agente para el prototipo, no lenguaje elegido explícitamente por el usuario ni decisión irreversible.

Se incorpora analyzer 8.4.1 directamente para revisar AST de imports. El solucionador añadió dependencias de compilador y bajó package_config de 3.0.0 a 2.2.0; no se modifican motor de audio, parches audio_service ni firma. Los paquetes quedan fijados en pubspec.lock. No se prometen todas las capacidades de Dart/Flutter: los ejemplos requieren tipos genéricos explícitos, y conversiones dinámicas de String encontradas durante la prueba requirieron adaptación. El SDK documenta el subconjunto comprobado.

## Implementación

- Paquete API 2 `.rpmx`: JSON UTF-8 con identidad/versionado/capacidades/permisos y fuente Dart; hasta 128 KB de archivo y 64 KB de fuente. No es ZIP y no permite extraer rutas arbitrarias. El código se compila en la app y se ejecuta al invocar `String run(String request)` con JSON.
- Revisión de AST permite solo dart:core, dart:convert y dart:math, sin imports condicionales, exports ni partes externas. El Runtime no recibe permisos/puentes de IO, red, procesos, FFI ni plataforma. Se pasan IDs SHA-256 opacos y metadatos autorizados, no rutas musicales ni imágenes privadas.
- Compilar y ejecutar ocurren fuera del hilo de interfaz: plazo 12 s y 2 s respectivamente; se mata el isolate al terminar o expirar. Caché LRU de ocho bytecodes (hasta 4 MB cada uno), entrada hasta 4 MB y salida hasta 512 KB UTF-8, datos propios hasta 64 KB.
- Registro separado en soporte/v3/extensions.json con respaldo, sin migrar ni borrar datos v2. Source/enable/grants/propietarios/datos propios persistidos. Un marcador de llamada pendiente permite dejar desactivada la extensión que quedó ejecutándose cuando murió el proceso. Tres fallos desde activar provocan desactivación; reactivar explícitamente reinicia el contador.
- Revisión de permisos al importar/actualizar y antes de activar. Actualización que no compila conserva el paquete anterior. Paquetes sin todos sus permisos quedan desactivados. Permisos iniciales: lectura de metadatos/favoritos, reproducción, listas de la app, estado propio. Nivel avanzado explícito para reproductor/aleatorio con behavior.override, sin acceso irrestricto al sistema.
- Varias instaladas/activas; el usuario elige propietario de biblioteca, reproductor y aleatorio. Instalar otra no sustituye un propietario existente. Las reglas pertenecen a su extensión/lista, sin un dueño global de todas las listas. Modo seguro desactiva programas y mantiene base, música, listas y carátulas.
- Source/estado ajeno no se evalúan en bindings de widgets Flutter. El anfitrión valida IDs, duplicados y formas de respuesta antes de aplicar datos; reproducción siempre usa MusicHandler/servicio original. Resultado tardío de aleatorio se ignora si cambió la selección.
- Gestor de extensiones conserva API 1 y añade importación con código, permisos, capacidades, fallos y tiempo de llamada. Incluye botones para instalar los dos ejemplos empaquetados offline, siempre con consentimiento y sin autoactivarlos por instalar el APK.

### Biblioteca viva

Programa Dart real que aplica filtros por artista, álbum, carpeta, duración, favoritos y búsqueda; devuelve IDs/textos/disposición y preferencias propias. Pantalla con filtros contraíbles, resultados perezosos, reproducir/mezclar y guardar lista manual o automática. Guardado manual agrupado en una escritura. Las reglas se vuelven a invocar cuando cambian catálogo/favoritos; escaneo continúa siendo manual. Desactivar el proveedor conserva regla y última composición sin recalcularla.

Carátulas de cualquier lista: imagen elegida mediante selector, hasta 8 MB, normalizada a PNG 512×512 en datos privados; alternativa mosaico con hasta cuatro carátulas disponibles. Los errores de imagen vuelven a una presentación segura. Las listas automáticas se identifican y no admiten edición manual de integrantes que el siguiente cálculo pudiera sobrescribir.

### Pulso nocturno

Segundo programa, nivel avanzado, simultáneo al anterior. Aporta reproductor ampliado con controles antes de la carátula y política de aleatorio que prefiere otro artista de la cola, con alternativa cuando no existe. Dos contratos visuales iniciales (artworkFirst/controlsFirst), no widgets arbitrarios. El tiempo mostrado es duración de llamada incluyendo preparación, no atribución exacta de CPU/RAM.

## Verificación inicial comprobada

- Pruebas reales del intérprete: lógica/JSON, imports de recursos bloqueados y bucle infinito terminado sin inutilizar la siguiente llamada.
- Paquetes reales probados con filtros, estado persistido, permisos insuficientes/revocación, varias activas y conflicto explícito, actualización inválida, tres fallos/recuperación, reglas al cambiar catálogo y datos/carátula conservados al desactivar/reactivar.
- Widgets a 360/1280: biblioteca programable, controles habilitados, crear lista automática desde UI, detalle, elegir imagen/mosaico y modo seguro; capturas revisadas en design/verification/program-library-*.png.
- Sonda Windows AOT/release separada, con datos sintéticos: library/shuffle/player/timeout=true y dos paquetes instalados. No se distribuye esa entrada; reconstruir siempre lib/main.dart antes de empaquetar.
- Sonda Android AOT/release en emulador API 37 también aprobada: ok/library/shuffle/player/timeout=true, dos programas instalados. Sin datos reales de usuario.
- Suite final: 65 pruebas aprobadas y análisis limpio; regresión nativa Windows de audio/bandeja/borrado aprobada. Se añade verificación de firma de entrada String run(String), límites por bytes UTF-8 y coexistencia de la selección API 1 con API 2. El cierre de paquetes se registra abajo. No sustituye pruebas en Galaxy/Poco ni demuestra todos los casos del selector de imágenes.

## Límites importantes

El primer SDK implementa lógica nueva y contratos de UI, **no la libertad visual/funcional completa de la visión**. Pendientes: más componentes y acciones, interacción entre extensiones, red con permisos/consentimiento, APIs de archivos bajo confirmación, autenticidad/firma de autor, migraciones de estado, catálogo, métricas fiables, rendimiento y validación física. No se implementó ecualizador ni servicios musicales.

Los isolates no son una cuota dura de memoria ni un proceso separado del OS. El marcador ayuda a recuperar después de un cierre, pero no impide toda caída ante código deliberadamente hostil; por ello solo archivos/ejemplos de confianza en este prototipo. Las imágenes sustituidas permanecen como copias privadas; limpieza/cuotas del almacén de carátulas siguen pendientes. Reglas de catálogos grandes pueden superar el presupuesto y volver a base; no hay promesa de escala o rendimiento sin medir.

Fuentes 2026-10-25: [dart_eval](https://pub.dev/packages/dart_eval), [Runtime](https://pub.dev/documentation/dart_eval/latest/dart_eval/Runtime-class.html), [flutter_eval](https://pub.dev/packages/flutter_eval), [FJS y frontera de seguridad](https://pub.dev/packages/fjs). Contrato de autor en docs/EXTENSIONES-API-2.md y ejemplos en examples/extensions/programables.

Relaciones: [[22 Extensiones - alcance del primer sistema]], [[04 Extensiones]], [[05 Rendimiento]], [[07 Preguntas e investigacion]], [[10 Estado del repositorio]], [[09 Registro de cambios]].

## Cierre del prototipo local

Aplicaciones normales reconstruidas con lib/main.dart después de las sondas. APK universal 0.3.0+9 con mismo certificado que 0.2.6, recursos multimedia y alineación ZIP 16 KB verificados; ambos ejemplos embebidos coinciden byte por byte con sus paquetes. Windows EXE 0.3.0+9 y ZIP con motor/backend/data, guías, ejemplos/fuentes y empaquetador verificados. Se comprobó ausencia del marcador RP_PROGRAM_PROBE en los binarios Dart de distribución y ausencia de integration_test en el ZIP. No se distribuyen las entradas de prueba.

Análisis limpio, 65 pruebas de la suite aprobadas, regresión Windows nativa de audio/bandeja/borrado aprobada y sondas AOT de intérprete aprobadas en Windows/Android. Tras ajustar selección API 1/API 2 se repitieron las dos pruebas UI de 360/1280 con desplazamiento real, creación de lista automática, opciones de carátula y modo seguro: aprobadas. Las pruebas del selector muestran ambas opciones; no se afirma un recorrido físico completo de galería en Galaxy/Poco.

Paquetes locales en dist/0.3.0-local; sin publicación ni push de este incremento. La última release pública es 0.2.6. Compilador/intérprete aumentan el tamaño del APK; no se han medido RAM, batería ni latencia con miles de canciones. Pendientes de alcance y seguridad permanecen indicados arriba.

- RP-Music-0.3.0-android.apk: 67282673 bytes; SHA-256 df8e3c7eab213047d46e3fa01cf8b147893d71b7da6e73ac0305949b56d96733.
- RP-Music-0.3.0-windows-x64.zip: 15539566 bytes; SHA-256 bcf4e47f1544798de827c5d3676fcf447c3b6f4d94cb8026586d73a0e9f749d1.


## Catálogo por repositorio — 2026-10-26

Confirmado por el usuario: separar las extensiones de prueba en un repositorio y consultar su enlace desde la app para listar e instalar paquetes. Se creó y publicó https://github.com/Joao-s02/rp-music-extensions (público) con Biblioteca viva y Pulso nocturno, fuentes y catalog.json schemaVersion 1. Publicación autorizada solo del repositorio de extensiones; el incremento de la aplicación continúa local.

Implementado en el código local: Extensiones → Explorar repositorio, enlace GitHub HTTPS público (oficial prellenado, editable), consulta de rama predeterminada y revisión fija, lista remota, descarga de paquete desde esa misma revisión y verificación SHA-256/id/versión/nombre/descripción. Permisos siguen siendo explícitos y no hay activación ni actualización silenciosa. Se conserva importar archivo. No requiere cuentas/tokens. Red solo por acción del usuario, sin conceder internet a programas.

Sustituye los botones de instalación offline anteriores: los .rpmx se quitaron de assets de producción. Instalaciones ya guardadas permanecen. Los ejemplos siguen como fuentes/fixtures en el proyecto y ahora en el repositorio separado. La sonda AOT anterior se adaptó para descargar del catálogo; sus resultados históricos no se atribuyen a esta revisión nueva sin repetirla.

Límites: solo GitHub público y catalog.json en raíz; sin repositorios privados, otros proveedores, búsqueda global, suscripciones persistidas o actualizaciones automáticas. HTTP sin redirecciones, límites 128 KB para índice/paquetes, hasta 100 entradas y plazo total 25 segundos por petición. Los paquetes solo admiten rutas relativas restringidas al mismo repositorio/revisión. SHA-256 verifica coherencia; no es firma/autenticidad independiente del autor. No hay validación física nueva en Galaxy/Poco.

Verificación: descarga real desde el cliente Dart de ambos paquetes publicados con hashes y metadatos correctos. Se detectó y corrigió normalización de saltos de línea de Git usando .gitattributes para preservar bytes .rpmx. Pruebas de validación de enlaces/rutas/hashes/duplicados y regresiones del sistema/UI registradas en el cierre de esta tarea. Release pública principal continúa 0.2.6.


Cierre 2026-10-26: repositorio de extensiones público confirmado, main d7d99045340e9d8ad6780f9608a69b0e75012f29. Once pruebas de catálogo/sistema/UI aprobadas; dos UI repetidas tras ajustar diálogo, aprobadas. Análisis final limpio. Builds normales release Android y Windows completados. APK con firma anterior verificada; APK y ZIP Windows sin paquetes de ejemplo ni integration_test. Nuevos archivos locales en dist/0.3.0-catalogo, con USO.md y SHA256SUMS.txt; los artefactos previos se conservan y no incluyen el explorador. No se publicó ni se envió el incremento de la app, ni se afirma una nueva prueba física/AOT de instalación por catálogo.

- 8fd28a9c67b250f718906fc8a3c6cdbca6b653b784c3a9d2f17ffa42dbbaefb1  RP-Music-0.3.0-catalogo-android.apk
- ac47f4fd08b73b1a52aa0bd289e7f220a0f54cfbd4d57e5b2442d8cbe6ee1e44  RP-Music-0.3.0-catalogo-windows-x64.zip


2026-10-26: usuario confirma descarga/instalación y permisos del catálogo. Código local ahora muestra Instalada para id presente con versión igual o superior (incluye desactivadas); solo una versión remota superior ofrece Actualizar. Tres pruebas del catálogo aprobadas. Este cambio todavía no está en los APK/ZIP anteriores. Se inicia entrevista/investigación de YouTube Music; conexión no implementada, alcance pendiente de respuestas. Ver boveda/24 YouTube Music - definicion e investigacion.md.


Trabajo vigente 2026-10-26: [[24 YouTube Music - definicion e investigacion]] — el usuario aceptó priorizar Android y la primera entrega de búsqueda/reproducción sin cuenta. 0.3.1+10 local añade fuente Android y paquete externo; 77 pruebas y recorrido nativo instalado aprobados, con límites documentados. Windows/listas/favoritos/historial de la fuente pendientes. No repetir elección de vía no oficial ni prioridad de plataforma. Última release pública de la app: 0.2.6.
