# API 3 JavaScript — experimental 0.3.8

**Ampliación publicada 0.3.9+18:** HTTP por etapas y audio remoto en [contrato de red](EXTENSIONES-API-3-RED.md). Los límites de ausencia de red/configuración descritos abajo corresponden al prototipo publicado 0.3.8. El nuevo contrato conserva capacidades anteriores, añade permisos explícitos y requiere minAppVersion >= 0.3.9 para usarlos.

Conserva API 1 y API 2/Dart sin migración. API 3 usa QuickJS (flutter_qjs_next 1.5.2), no Node.js. No ejecuta HTML/CSS ni widgets Flutter arbitrarios. La extensión define un árbol visual componible, estado, eventos y navegación; no un tipo de página predeterminado por servicio.

## Paquete

Archivo .rpmx JSON UTF-8 de hasta 128 KiB: apiVersion=3, engine=javascript, id/name/version/description/source, minAppVersion=0.3.8, capabilities=[screen]. Requiere navigation.add; opcionales storage.private, library.read y playback.control. Este prototipo rechaza red, fuente, letras, DSP y nivel avanzado para API 3. Los paquetes Dart siguen usando su motor/contratos anteriores. Instalar no sustituye propietarios de Fuente ni migra paquetes.

## Entrada y salida

Función síncrona run(input), devuelve objeto JSON. Cada evento crea un contexto nuevo; variables globales no persisten. input incluye event=screen, action=open o el identificador del botón, fields (valores de formulario), state autorizado y tracks solo con library.read. Tracks: snapshot de hasta 500 canciones locales, con IDs opacos/metadatos sin rutas.

Salida: view (árbol visual obligatorio), state opcional (hasta 64 KiB y permiso storage.private), play opcional (ID opaco de la selección autorizada). El anfitrión solo acepta play como respuesta a una acción explícita del usuario, con permisos de biblioteca/reproducción aún vigentes. No autoplay al abrir. Audio pasa por MusicHandler; no acceso directo al backend.

## Componentes

- column/row/card: children; row se adapta mediante Wrap. Card admite color #RRGGBB.
- text: text, style=title opcional.
- input: id único, label y value inicial; hasta 500 caracteres, 20 campos. Los valores se envían al pulsar un botón.
- button: label y action; el paquete interpreta el identificador y decide el árbol siguiente.
- divider.

Hasta 200 nodos, profundidad 12 y 100 hijos por contenedor; textos hasta 2000 caracteres. La navegación puede representarse en state y devolver un árbol distinto por página. No requiere agregar una página específica al código Flutter por cada flujo nuevo. Componentes aún limitados: sin HTML/CSS libre, imágenes externas, audio DSP ni navegación del sistema definida por el paquete.

## Ejecución y límites

Fuente hasta 64 KiB, entrada hasta 4 MiB y salida hasta 512 KiB. Configuración de QuickJS: interrupción nativa tras 1000 ms de trabajo JS y heap de 32 MiB; deadline adicional de 4 s. No son cuota de memoria de todo el proceso ni aislamiento de sistema operativo. Sin APIs web instaladas (JsWebApis.none), fetch/XHR, Node, archivos, procesos ni imports de módulos; no se registran callbacks nativos de la app. Promesas no se ejecutan como flujo de extensión.

La pantalla valida la estructura antes de guardar estado. Revocar permisos o desactivar elimina acceso; respuestas tardías se descartan y tres fallos desactivan el paquete. Los datos propios se conservan para recuperación. Metadatos/estado permanecen locales; el prototipo no conecta servicios.

La extensión Laboratorio JS vive exclusivamente en rp-music-extensions/previews/js-lab-0.1.0. No se integra como asset ni se publica con la app. Ver [[documentación de bóveda]](../boveda/36%20Motor%20JavaScript%20paralelo.md).


## Pantalla reciente desde 0.3.18

El host puede restaurar el árbol validado, campos y desplazamiento al volver a una pantalla de esta sesión, sin ejecutar open ni repetir acciones. Caché en memoria acotada a ocho pantallas/30min, ligada a identidad y revisión de permisos; no persiste URL ni reemplaza las verificaciones al pulsar acciones. Los programas no deben depender de open para iniciar reproducción.
