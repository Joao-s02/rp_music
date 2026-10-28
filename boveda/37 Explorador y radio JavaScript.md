---
tipo: implementacion-experimental
estado: publicado-con-limites-experimentales
actualizado: 2026-10-28
---
# Explorador y radio JavaScript

Confirmación posterior del usuario: ambas nuevas extensiones funcionan en Android; reporta3–6s en consultas/apertura de contenido/secciones API3. Modelo/red no especificados. YouTube API2 se conserva; diagnóstico y propuestas, sin mejora implementada, en [[38 Latencia de extensiones API 3]].

## Alcance confirmado

Usuario autoriza desarrollar Explorador musical y Radio por internet, añadiendo capacidades necesarias al motor JS. App local 0.3.9+18; publicada sigue 0.3.8+17. La etapa inicial no autorizaba push/publicación; autorización posterior y confirmación al final. API 2 y paquetes previos conservados. Antecedente: [[36 Motor JavaScript paralelo]]; separación: [[04 Extensiones]].

## Implementación local

API 3 conserva screen independiente y añade sourceConfig genérica, network.http, etapas request/next/context y playRemote. Cuatro consultas por acción; transporte HTTP existente acotado. Sin fetch/Node/Promesas. Árbol final validado antes de estado. Formularios recogen valores iniciales y se actualizan con árbol nuevo. Cancelación/generaciones/revisión de autorización descartan respuestas tardías; permisos retirables mientras espera red.

Audio por MusicHandler/broker existente sin desplazar propietario de Fuente. URLs solo en memoria, hasta 100; cambios de paquete/permisos/desactivación invalidan entradas. network.stream es permiso explícito para emisoras HTTPS de dominios variables. Comprueba URL/DNS público/redirecciones iniciales/plazo; no es cortafuegos del backend ni aislamiento OS. Contrato en docs/EXTENSIONES-API-3-RED.md; mapa en [[31 Arquitectura vigente]].

Fuentes y pruebas específicas exclusivamente en checkout Git independiente dist/extensions-repository (origin rp-music-extensions), ignorado por principal:

- Explorador musical 0.1.0, rp.explorador-musical-js: canciones/artistas/álbumes/listas públicas de YouTube Music, apertura, Atrás, paginación visual/continuación remota y resolución AAC sin cuenta. Variante independiente. Sin importación/descarga/cuenta/sincronización; no corrige por sí misma YouTube Windows.
- Radio por internet 0.1.0, rp.radio-internet-js: Radio Browser, nombre/país/etiqueta, populares/bloques/páginas, hasta 30 favoritas privadas con cuota, renovación por UUID y registro de clic antes de escuchar. HTTPS MP3/AAC; filtra HLS/listas remotas. Tres servidores de directorio con recuperación ante fallo. Disponibilidad de emisoras no garantizada.

build_music_screens.py genera previews/js-music-0.1.0 y hashes sin cambiar catálogo/paquetes anteriores. Requieren minAppVersion 0.3.9 y consentimiento de permisos.

## Verificación y hallazgos iniciales

15 pruebas dirigidas del motor aprobadas, incluidas seis JS previas. Contratos/red/estado, revocación/cancelación, error/límite de consultas, dominios, audio/propietario y no autoplay. Primera ejecución sin DLL en PATH falló; repetida con Release compilada pasó e interrumpió bucle en 1015 ms. No sumar repeticiones.

Seis pruebas particulares aprobadas: artista/álbum/100 pistas/continuación sin recomendaciones/Atrás, AAC sintético/errores/enlaces ajenos; radio/favoritas/restauración/UUID/servidores; pantallas 360px con escala 1.5. Recorrido recursivo desbordaba pila; corregido con recorrido iterativo acotado. Estado excesivo limita resultados con aviso.

Primera sonda nativa Windows reprodujo Radio Swiss Pop AAC 192, avanzó >2 s, pausó/reanudó y se detuvo al desactivar sin errores. No basta para confirmar colecciones: se endurece sonda para detectar errores que conserven resultados anteriores. Sonda definitiva, suite completa/análisis y binarios normales pendientes al redactar. Android físico sujeto a disponibilidad.

Fuentes primarias consultadas: https://docs.radio-browser.info/ (búsqueda/UUID/clic/formatos) y https://ytmusicapi.readthedocs.io/en/stable/reference/browsing.html (navegación como referencia; sin integrar Python). Sin credenciales/cuentas.

## Cierre local

**138 pruebas aprobadas** en suite conjunta: 130 app + ocho externas (dos previas/seis nuevas); una optativa de red omitida. No sumar repeticiones. Análisis final de lib/test/integration_test/tools y pruebas nuevas externas sin incidencias. Capturas históricas regeneradas por suite restauradas; imágenes ajenas previas conservadas.

Sonda nativa definitiva Windows aprobada exigiendo error=false por operación: búsqueda pública de artistas/álbumes/listas/canciones y apertura con contenido nuevo (artista50, álbum una pista en edición elegida, lista13). Resolución real AAC de La Incondicional; lista larga100 + continuación100. No acredita catálogo completo ni reproducción nativa YouTube Windows. Radio Swiss Pop AAC192: dos coincidencias, favorita, audio nativo avanzó2167ms, pausa/reanudación/parada por desactivación aprobadas sin errores. Informe externo tests/RESULTADOS-js-music-native.json. adb sin dispositivos: Android físico/escucha prolongada/más redes y emisoras pendientes.

Además del recorrido iterativo, se corrigió pila QuickJS Windows debug: 256KiB predeterminados insuficientes para JSON anidado normal; ahora512KiB, debajo de pila de hilo Windows1MiB. Otras plataformas conservan1MiB; heap32MiB/timeout1000ms sin cambios. Recursión excesiva y evaluación posterior comprobadas, sin deshabilitar límites nativos.

Binarios normales finales: Windows release63.3s, ProductVersion/FileVersion0.3.9+18, ZIP íntegro21 archivos/QuickJS/guía. APK universal release185.9s, versión0.3.9/código18, tres ABI Flutter/QuickJS, firma v2 válida y certificado SHA256 eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d compatible con anterior. Registrante Android sin integration_test. No se probó instalación física. APK/ZIP sin rpmx; no variante ARM64 separada ni release publicada.

Entrega dist/0.3.9-local, guía docs/PROBAR-JAVASCRIPT-0.3.9.md y manifiesto SHA256:

```text
3aaa63d205d2b051f4aef76c725d80f644322f657cdf31239eeca36a700345e3  RP-Music-0.3.9-local-android.apk
e9bbfdb198af452db1a035e0831f3cf0ffdb349f6c3a8eeb40be680150b33e3c  RP-Music-0.3.9-local-windows-x64.zip
```

Paquetes candidatos/hashes en repo externo/previews/js-music-0.1.0. YouTube estable0.4.0/Explorador Dart0.1.0 conservan hashes y ejecución comprobados; catálogo sin modificar. Sin push, commits nuevos ni publicación.

2026-10-28: usuario autoriza publicar la nueva release0.3.9. Se preparan universal/ARM64/Windows y guías/hashes; dos extensiones JS separadas en catálogo, paquetes anteriores preservados. Confirmación pública pendiente hasta verificar borrador y publicación.

Catálogo publicado en commit externo 026aa38ff251b61ec341786b079a323399ff87a1: ocho opciones comprobadas con cliente real. Cinco paquetes (dos nuevos, YouTube estable/Explorador y Laboratorio) descargados de revisión fija y comparados byte a byte. ARM64 normal0.3.9/código18 compilado71.4s, solo arm64-v8a y firma v2 compatible verificados. Publicación de app todavía en preparación.

## Publicación 0.3.9 confirmada

2026-10-28: release pública https://github.com/Joao-s02/rp_music/releases/tag/v0.3.9-alpha.1, app 0.3.9+18, tag/código 54bcb738f67cb34a2d50e5e3cecb863c45c04a91, release ID 426707453. Universal normal final reutilizado; ARM64 normal71.4s con versión/código18/firma v2 compatibles. Windows normal0.3.9+18, ZIP23 archivos con QuickJS y guías. Siete adjuntos comprobados en borrador por tamaño/digest SHA256 y target; API pública confirmó publicación/prerelease, mismos tamaños/hashes, tag correcto y manifiesto descargado idéntico. Extensiones de código 026aa38ff251b61ec341786b079a323399ff87a1, catálogo de ocho opciones verificado con cliente real; dos nuevas y YouTube estable/Explorador/Laboratorio descargados de revisión fija e idénticos. Suite138 aprobadas/una optativa omitida y análisis limpio; navegación/resolución y radio nativa Windows comprobadas. Android físico y audio nativo YouTube Windows pendientes. No se modifican releases anteriores. Commits documentales posteriores no cambian binarios del tag.
