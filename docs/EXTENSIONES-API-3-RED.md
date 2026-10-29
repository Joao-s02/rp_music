# API 3 — red y audio remoto (0.3.9)

Complementa [API 3 original](EXTENSIONES-API-3.md). Implementación experimental publicada en 0.3.9+18. QuickJS sigue sin fetch/XHR/Node/npm/archivos ni Promesas de extensión. Se conserva API 2, capacidad screen independiente y propietario de Fuente de las extensiones Dart.

## Paquete

minAppVersion >= 0.3.9, capabilities=[screen], permisos navigation.add/network.http y sourceConfig: name, domains (hasta 12 dominios exactos o comodines de subdominio), platforms (android/windows), navigation opcional (label/icon/color). Para audio: playback.control. Para estado: storage.private, hasta 64 KiB.

network.http solo permite consultas a dominios declarados. Nuevo permiso network.stream autoriza **audio HTTPS público de dominios variables**, pensado para emisoras; no amplía consultas HTTP de datos. Requiere network.http/playback.control. Sin ese permiso, audio restringido a sourceConfig.domains. No implica cuenta, sincronización, capacidad source/lyrics ni nivel avanzado.

## Etapas HTTP

run(input) sigue síncrona. Entrada adicional: stage=start, context={}, date UTC YYYYMMDD. Salida intermedia exclusivamente {request,next,context?}, sin view/state/reproducción. El anfitrión valida y consulta fuera de QuickJS; vuelve a ejecutar con stage=next, context y response={status,body,cookies}. Máximo cuatro peticiones por acción y contexto 64 KiB.

request: url, method GET/POST, headers restringidas y body JSON opcionales. HTTPS/dominios declarados, sin redirecciones de consultas; cuerpo hasta 64 KiB, respuesta 1.5 MiB y plazo 25 s por petición. Fallo de transporte se entrega como status=0/body vacío/cookies vacías, permitiendo errores recuperables sin desactivar por fallos de conectividad. No guardar cookies o secretos en estado.

```javascript
function run(input) {
  if (input.stage === 'start') {
    return {request: {url: 'https://example.com/catalog'}, next: 'catalog'};
  }
  return {view: {type: 'text', text: 'Estado HTTP: ' + input.response.status}};
}
```

Salida final: view obligatorio y state opcional; árbol validado antes de guardar. Campos adicionales message/error pueden servir al paquete para informar fallos operativos en su árbol. Revocar permisos/desactivar/cambiar paquete/cancelar/cerrar pantalla descarta resultados tardíos. La petición ya enviada puede terminar hasta su plazo; cancelar no deshace trabajo recibido por el servidor. Formulario recoge valores iniciales y permite restablecerlos desde el siguiente árbol.

## Audio remoto

Salida final playRemote={id,title,url,artist?,album?}. ID simple y metadatos hasta 200 caracteres; URL hasta 16000. Solo en respuesta a botón explícito; no autoplay al abrir ni play/playRemote simultáneos. Usa MusicHandler y controles/notificación habituales.

Sin network.stream, el dominio debe estar declarado. Con network.stream, URL HTTPS público, sin credenciales/IP literal, puerto estándar; resolución verifica DNS público y hasta cuatro redirecciones iniciales con plazo global 20 s, sin descargar toda una emisora. Audio directo en esta entrega; no HLS/listas remotas. No es cortafuegos de proceso: el backend nativo vuelve a abrir el URL y aplica sus propias resoluciones/redirecciones. Límites nativos/aislamiento de QuickJS del contrato original se conservan.

Resoluciones se guardan solo en memoria (hasta 100 entradas). Reinstalar/desactivar/cambiar permisos/volver a base invalida audio propio; reiniciar exige seleccionar otra vez desde la pantalla. Favoritas pueden conservar IDs/datos públicos, renovando URL antes de escuchar. Cancelar durante carga de audio la detiene. Las pantallas no sustituyen al propietario de Fuente.

Extensiones/paquetes específicos exclusivamente en rp-music-extensions/previews/js-music-0.1.0, fuera de assets/adjuntos de app. Evidencia en [bóveda](../boveda/37%20Explorador%20y%20radio%20JavaScript.md).

## Adición local0.3.16: caché pública optativa

request.cacheSeconds puede solicitar1–60 segundos para consultas públicas sin efectos secundarios. El anfitrión limita8 respuestas/2MiB totales y512KiB por respuesta, acepta solo status200 sin cookies, distingue paquete/petición y elimina caché al cambiar revisión de permisos. Es memoria de una pantalla, sin persistencia. No usar para sesiones, acciones mutables ni URLs de reproducción. Los tiempos de motor/red/acción se añaden al diagnóstico de sesión, sin contenido de consultas/respuestas. No equivale a medición Android.
