# A02 — adaptador Windows propio (candidato parcial)

## Estado y límites

Este candidato **no cierra A02**. Integra un contexto mpv propio para audio remoto y conserva el backend existente para archivos locales/SAF. No modifica MusicHandler, versiones de paquetes, permisos del sistema ni la implementación Android.

Las referencias públicas corresponden a just_audio 0.10.6, su interfaz 4.6.0 y mpv `652a1dd907`. Los Dart de referencia están comentados línea por línea para que no sean dependencias ejecutables. Se conservan los avisos del código mpv. El adaptador importa la interfaz ya presente en el lock; no se ejecutó resolución/instalación de paquetes.

## Flujo implementado

1. Todas las ramas remotas autorizadas de ExtensionSourceService registran una ruta en PublicAudioProxy. No devuelven el upstream al reproductor. La autorización conserva paquete, revisión y propietario/permisos; cada sesión mantiene la revocación y cierre existentes.
2. El broker usa ProgressiveAudioSource explícito. No infiere HLS/DASH desde extensión o MIME.
3. El relay registra su URI exacta en una tabla del host. Solo esas identidades pueden alcanzar el backend remoto. Query, fragmento, ruta alternativa o URI de red no registrada se rechazan sin fallback al backend local.
4. Windows recibe únicamente el endpoint loopback registrado. WinHTTP usa dirección literal 127.0.0.1, puerto y ruta exactos; sin proxy, cookies, autenticación ni redirecciones. Ninguna cabecera de contenido amplía ese endpoint.
5. mpv recibe `rp-a02://host`, no la URI upstream. Los callbacks limitan cada lectura a 64 KiB y reabren el mismo relay con Range al hacer seek. Un tamaño desconocido no se interpreta como EOF. El relay conserva el transporte público con IP aprobada y TLS/SNI del hostname original.

El contexto fuerza lavf y access-references=no; limita los protocolos FFmpeg a rp-a02; desactiva configuración, scripts explícitos/auto-carga, archivos de audio/subtítulos automáticos y caché en disco. Los errores de opciones requeridas abortan la creación. Se leen y verifican load-scripts, scripts, access-references y cache-on-disk después de inicializar. No se utiliza el rechazo histórico de ytdl como prueba de aislamiento.

**Límite de scripts:** esas lecturas demuestran configuración efectiva para scripts explícitos/auto-carga, no una inspección independiente de cada hook o script integrado en la DLL. Esta última evidencia sigue pendiente.

## Concurrencia y ciclo de vida

Las llamadas mpv se serializan en un worker nativo con cola acotada. Las respuestas del canal se entregan en el hilo de plataforma mediante un mensaje de ventana. Cancelar una capacidad cierra las peticiones activas mediante un grupo de cancelación independiente de la cola mpv. Así, cancelar no necesita esperar una consulta síncrona bloqueada por la apertura del demuxer. Los callbacks no llaman APIs mpv.

Las cookies viven hasta close; el grupo sincroniza destrucción/cancelación. El apagado cancela antes de unir el worker. Dart usa generaciones para rechazar cargas tardías y cancela el polling al reset/dispose. La tabla de capacidades sigue la vida de cada ruta del relay, incluida la expulsión por su límite existente.

## Evidencia y fallos conservados

- RED inicial: los nuevos tests no compilaban sin adaptador; 40 tests existentes aprobados. No equivale a RED nativo de seguridad.
- Primer candidato: enfocados 43 aprobados/1 fallido por expectativa antigua de URI upstream; análisis salida 1 con 15 infos; build normal debug salida 0.
- Primer fixture nativo: salida 1 al exigir un Range nuevo después de un seek servido por caché; los escenarios posteriores no se ejecutaron.
- Corrección: WAV silencioso de 180 s, caché mpv de 256 KiB y seek a 120 s. La prueba exige una petición real posterior con offset mayor que 3 MB, además de posición reproducida.
- Primera matriz ampliada: 4 aprobados/1 fallido; cancelar headers bloqueados tardó 33,674015 s. No se ocultó con un plazo más amplio. Se eliminan consultas síncronas de propiedades durante loading y se añade cancelación de IO independiente de la cola.
- Verificación Dart final: **48 aprobados, salida 0**; incluye interrupción de create por dispose sin comando load tardío. Análisis final **sin incidencias, salida 0**. El primer análisis de la corrección tuvo siete infos de llaves; se corrigieron antes del análisis final. Se formatearon los once Dart afectados.
- Segunda matriz ampliada: **5 aprobados, salida 0**. Incluye local→remoto→local, Range no cero observado, continuación sin Content-Length, cancelación bloqueada menor de 3 s, revocación en la siguiente petición, dispose repetido y listas anidadas con control HTTP real sin protección.
- El backend local existente sigue emitiendo `property not found ... osc` y `Failed to create file cache` en los recorridos locales/control sin protección. El contexto propio verifica cache-on-disk=no. No se atribuye el aviso a una regresión nueva ni se afirma una causa interna del plugin sin inspección adicional.

Comandos (secuenciales, sin publicación):

```sh
PATH="$(pwd)/build/windows/x64/runner/Release:$PATH" flutter test --no-pub --reporter expanded --concurrency=1 test/protected_windows_audio_test.dart test/protected_audio_source_test.dart test/public_audio_transport_test.dart test/public_audio_proxy_test.dart test/public_stream_probe_test.dart test/javascript_network_test.dart test/extension_source_test.dart test/desktop_lifecycle_test.dart
flutter analyze --no-pub
flutter test --no-pub --reporter expanded integration_test/a02_windows_native_io_test.dart -d windows
flutter build windows --debug --no-pub
```

Después de la última integración se reconstruyó la entrada normal con `flutter build windows --debug --no-pub`: **salida 0**. `git diff --check` terminó con salida 0 (avisos CRLF, sin errores de espacios).

El build normal debe ser el último: el fixture reemplaza temporalmente la entrada Debug. Los tests nuevos usan audio sintético silencioso y temporales nuevos bajo el directorio autorizado. No abren biblioteca, cuentas, dispositivos ni servidores externos.

## Verificación independiente posterior

El verificador ejecutó una única pasada en una copia completa nueva, autorizada
para esta sesión. Contrastó por SHA-256 227 archivos y 13 recursos antes de los
checks; hashes y estado Git originales permanecieron iguales. Los **48 tests
enfocados y el análisis aprobaron con salida 0**.

La integración nativa terminó **salida 1, cero casos ejecutados** antes de compilar:
«Building with plugins requires symlink support.». El build normal independiente
terminó salida 1 por el mismo prerrequisito. No se habilitó Developer Mode, reparó
ni reintentó el entorno. Por tanto, los cinco pases nativos y el build normal
anteriores siguen atribuidos al escritor; no son validación nativa independiente.
No se reprodujo un blocker de producto del candidato mediante inspección de fuente.

La evidencia y el manifiesto se conservaron en el hijo nuevo
`independent-BJ3mVK` del temporal exacto autorizado. Los pendientes relevantes son
aperturas fuera del relay y preservación de audio directo; no una auditoría
universal de codecs o scripts. Falta decisión explícita sobre el prerrequisito y
la prueba no disponible antes de otra tanda. No se cambia configuración de Windows
ni se inicia más verificación por inferencia.

## Pruebas todavía necesarias

- Evidencia observable de ninguna apertura file/UNC y controles positivos correspondientes. Los fixtures file actuales solo acreditan rechazo de decodificación; **no** acreditan ausencia de apertura del SO. No se envió tráfico SMB/LAN ni se activó auditoría global/elevada.
- Controles y casos DASH/ASX, poliglotas y lectura anidada en demuxers adicionales; la matriz actual no equivale a una auditoría de todos los formatos.
- Evidencia independiente del estado de hooks/scripts integrados en la DLL y revisión de WinHTTP/cancelación/destrucción concurrentes.
- Más formatos de audio directo sintéticos y escucha prolongada. WAV y el backend local conservado no prueban compatibilidad universal; no se ha aprobado ninguna reducción de formatos.
- Integración nativa Android y verificación independiente de seguridad. Para Android se mantiene el contrato de capacidad progresiva del host, no una URL upstream ni selección automática de playlist. Hará falta un emulador o dispositivo de prueba expresamente autorizado para instalar/operar el fixture. No hace falta conectar un teléfono para las pruebas Windows pendientes.

Hasta completar esos puntos, este candidato no está listo para release ni debe presentarse como cierre de SSRF nativo.
