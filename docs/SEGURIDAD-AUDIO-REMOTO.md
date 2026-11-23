# Audio remoto: candidato parcial A02

**No listo para integrar. S2/A02 sigue abierta.** Esta nota describe el candidato
local y sus pruebas, no una garantía de reproducción nativa ni una corrección
completada. No reescribe el informe histórico de auditoría.

## Estado posterior: integración Windows y prueba independiente limitada

Existe un [adaptador Windows productivo propio](A02-WINDOWS-NATIVE.md): todas las
ramas remotas autorizadas entregan capacidades del relay y fuente progresiva;
mpv consume callbacks limitados al endpoint local exacto, sin recibir el upstream.
Se conserva el backend previo para audio local. Los apartados históricos siguientes
conservan sus fallos y límites; no deben leerse como ausencia actual del adaptador.

El escritor informó 48 tests enfocados, cinco nativos, análisis limpio y build
normal debug final aprobados, salida 0. La única verificación independiente nueva
contrastó 227 archivos/13 recursos de una copia completa y mantuvo intacta la
fuente: **48 tests enfocados y análisis aprobados, salida 0**. Integración/build
nativos independientes terminaron salida 1 **antes de compilar**, cero casos
nativos ejecutados, por «Building with plugins requires symlink support.». No se
activó Developer Mode, reparó el entorno ni reintentó. No hubo defecto de producto
reproducido; tampoco aprobación independiente de la frontera nativa.

Quedan sin acreditar ausencia observable de aperturas file/UNC, referencias
secundarias relevantes y preservación de más formatos directos. No se exige una
auditoría universal de codecs/scripts ni se acepta rechazo de decodificación como
prueba de ausencia de apertura del SO. Android nativo permanece sin implementar.
Tras la corrección acotada y el verificador se detienen nuevas tandas automáticas:
falta disposición explícita sobre prerrequisito Windows y prueba faltante. Sin
suite completa, commit nuevo ni publicación. Conectar Android no resuelve esos
bloqueos Windows; las pruebas físicas futuras requieren autorización concreta.

## Conexiones y TLS

`PublicAudioTransport` usa los validadores actuales de URI/dirección. Cada
apertura y cada redirección resuelve DNS de nuevo, rechaza respuestas vacías o
mixtas público/privado y entrega una `InternetAddress` al conector de sockets.
No entrega el hostname a una segunda resolución independiente. Cada petición
utiliza un HttpClient nuevo, sin proxy de entorno ni redirecciones automáticas.

`connectionFactory` **no convierte automáticamente Socket a TLS**. El candidato
llama explícitamente a `RawSecureSocket.secure(host: hostnameOriginal)`, manteniendo
Host, SNI y verificación de certificados. El contexto opcional de prueba no se
configura en producción: el valor predeterminado conserva la confianza normal.
No hay `badCertificateCallback` permisivo.

La fixture genera en memoria una identidad RSA sintética e insegura exclusivamente
para tests; no utiliza claves de usuarios ni herramientas externas. El cliente de
prueba confía explícitamente en ese certificado. Aprobaron la transferencia de
bytes por TLS, el hostname original, ClientHello/SNI, el rechazo de certificado
no confiable y el rechazo de hostname incorrecto. El conector registra la IP
pública seleccionada y la mapea únicamente en la fixture a un servidor local.
Esto prueba la decisión del conector y TLS real sin Internet; no es conexión a
una IP pública real ni prueba de backend Android/Windows.

Se conservan plazos finitos de conexión y handshake. El conector ahora devuelve
`RawSocket`: se conecta únicamente a la IP ya aprobada y se conserva ese socket
TCP durante `RawSecureSocket.secure(host: hostnameOriginal)`, sin una segunda
resolución DNS. No depende del metadato `InternetAddress.host` del resolver.
Cancelar cierra el TCP real y resuelve la tarea pública con error de autorización;
no espera al futuro de handshake del SDK, que puede quedar pendiente al cerrar
localmente. Los tests exigen tanto el error inmediato como la desconexión observada
por el peer dentro de dos segundos: no basta con ganar una carrera de futuros.

Un adaptador privado entrega el TLS ya establecido a HttpClient. `IOSink`
serializa las escrituras; el consumidor espera disponibilidad tras escrituras
parciales sin acumular otra cola propia. La pausa de lectura desactiva eventos
raw y destruir el adaptador cierra también el TCP retenido. No hay una ruta
alternativa antigua con Socket ni un salto de proxy nuevo.

## Relay y permisos

`network.stream` entrega al backend una capacidad HTTP en 127.0.0.1, con ruta
aleatoria de 256 bits. Hay hasta 16 rutas y ocho respuestas activas por relay.
No acepta una URL del cliente, no reenvía cabeceras arbitrarias ni Location y
solo transmite tipo, rango y longitud. GET/HEAD y un rango simple están admitidos.
El sondeo `resolvePublicStream` vuelve a entregar la URI final de la redirección.

Los tests aprobaron respuestas completas 200, parciales 206 y 416, rangos, bytes
idénticos, redirecciones internas sin Location remoto y rechazo de DNS
público→privado en el salto siguiente. También aprobaron aperturas nuevas/rangos
con DNS cambiado y respuestas mixtas IPv4/IPv6 rechazadas antes del conector.

Las rutas capturan paquete y revisión de autorización; se comprueban antes y
después de DNS, antes de conectar y durante el cuerpo. La prueba integrada de
reemplazo de paquete invalidó la capacidad antigua sin nuevas peticiones upstream.
Se conserva el permiso `network.http` y el propietario de Fuente independiente
de las pantallas JavaScript.

**Descargas:** API3 no admite `storage.download` en `ProgramPackage.parse`.
Intentar construir un paquete con ese permiso produjo el rechazo esperado del
contrato vigente. La prueba final conserva el contrato: ambas interfaces de
descarga rechazan la pista protegida antes de resolver/abrir audio y no crean
archivos. No se inventó permiso nuevo para obtener una prueba exitosa. Por tanto,
no hay evidencia de descargas protegidas exitosas; cualquier ampliación de ese
contrato necesita decisión separada. Las rutas API2 existentes y sus límites de
64 MiB/512 MiB no se unifican ni cambian en esta corrección.

## Listas y comportamiento previo

Además del MIME, el relay inspecciona un prefijo de hasta 4096 bytes iniciales.
En la corrección acotada de continuidad deja de esperar cuando los bytes ya no
pueden completar una de las firmas filtradas; no exige 4096 bytes ni EOF para
audio inequívoco. Conserva la espera acotada para prefijos ambiguos/blancos y
configura `bufferOutput = false` en la respuesta local.
Rechaza prefijos comunes M3U/PLS/XML/ASX/MPD/SMIL y listas de URL, incluso si el
MIME declara audio. Una prueba M3U con MIME audio/mpeg aprobó sin entregar bytes ni
realizar una petición secundaria.

**No es una garantía completa:** prefijos desplazados, formatos no reconocidos,
políglotas, aperturas de rangos intermedios y decisiones del demuxer no quedan
cubiertos por esa detección. No se introdujo una lista cerrada de codecs ni se
desactivó silenciosamente streaming para aparentar seguridad. Cerrar esta frontera
requiere decidir cómo restringir las aperturas secundarias del backend o aceptar
un conjunto explícito de formatos verificables; eso no está demostrado aquí.

En la tanda inicial, la prueba de revocación durante cuerpo quedó bloqueada antes
de recibir cabeceras y alcanzó el timeout de 30 segundos; esa tanda se detuvo.
La reanudación autorizada posterior corrigió el buffering y comprobó continuidad
y revocación en fixtures locales, como se detalla abajo. No equivale a evidencia
de reproducción continua con el backend nativo.

## Propiedad y ciclo de vida

La corrección evita listeners y servidores nuevos por cada servicio efímero:
existe una sesión/relay perezosa compartida por ProgramController. Los servicios
no usados para streaming no añaden listeners. Las rutas siguen acotadas; el broker
cierra la sesión compartida al disponer. El cierre Windows dispone fuentes antes
de cerrar audio, mientras que cerrar hacia bandeja mantiene reproducción.
Dispose repetido y reemplazo de paquete aprobaron. La sesión es de ámbito del
controlador; Android no se cierra al pausar/separar su actividad y conserva el
ciclo de vida de audio en segundo plano. No se afirma una prueba física de cierre.

## Evidencia de la corrección acotada

- RED TLS: certificado sintético sin confianza inyectada produjo
  `CERTIFICATE_VERIFY_FAILED: self signed certificate`.
- Suite enfocada inicial: **27 aprobadas, dos fallidas, salida 1**. Fallos:
  `close cancels a live TLS handshake and peer observes disconnect` y
  `revocation during body terminates backend response and removes route`.
- El primer intento del test de descargas falló porque API3 rechaza
  storage.download; se corrigió la fixture para probar el rechazo vigente.
- Diferencial aislado de los helpers públicos de URI/IP y sondeo con entradas
  rechazadas/revocadas contra 98f0650503512f14395233783dd6af5d068b16f4:
  stdout/stderr/salida idénticos, ambos salida 0. No cubre todos los consumidores.
- Formato ejecutado sobre archivos tocados. Análisis inicial de esta tanda:
  siete avisos de estilo, salida 1; corregidos. Ejecución final de
  `flutter analyze --no-pub`: salida 0, `No issues found!`.

### Reanudación acotada: continuidad del relay

Se reprodujeron ambos fallos previos: 12 aprobadas, dos fallidas, salida 1.
La nueva prueba de tres bytes sobre una emisión sin EOF y HEAD falló inicialmente
por timeout; también seguía fallando la revocación. La fixture HTTP de origen
necesitó `bufferOutput = false`: `flush()` por sí solo no liberaba esos bytes.
Tras corregir la fixture y el relay, la ejecución enfocada de transporte, proxy,
red JavaScript y ciclo de vida obtuvo **26 aprobadas, una fallida, salida 1**.
Aprobaron el primer fragmento exacto de tres bytes, HEAD sin cuerpo, revocación
sin enviar el fragmento siguiente, ruta revocada 404 sin nueva petición upstream,
y las pruebas existentes de bytes 200/206/416 y permisos. Esto es evidencia con
sockets TLS locales, no reproducción física ni una garantía de todos los formatos.

### Corrección posterior de propiedad TLS

El primer intento con RawSocket produjo **27 aprobadas, dos fallidas, salida 1**:
la tarea de handshake seguía esperando al SDK y la nueva prueba de cuerpo pausado
no tenía un observador adecuado de desconexión. La corrección conservó TCP también
en el adaptador y resolvió explícitamente la tarea cancelada después de iniciar el
cierre físico. La prueba del cuerpo usa ahora un peer TLS que observa directamente
EOF/error de socket, sin depender de cerrar una respuesta HttpServer aún abierta.

La primera ejecución verde de los mismos cuatro archivos obtuvo **29 aprobadas,
cero fallidas, salida 0**. Después se cubrió también el cierre mientras se crea
el conector: la conexión tardía se cierra sin enviar bytes TLS ni dejar errores
de cancelación sin observador. La ejecución final, tras formato, obtuvo
**30 aprobadas, cero fallidas, salida 0**. El análisis inicial detectó dos avisos
de estilo; corregidos, `flutter analyze --no-pub` terminó con salida 0 y
`No issues found!`. Incluye desconexión durante handshake, cierre con lectura
pausada, cabecera de petición de 100000 caracteres, respuesta de 1 MiB idéntica
tras pausa/reanudación, confianza/hostname/SNI, relay continuo, HEAD, rangos y
revocación. La guarda BOM está presente en esa ejecución; no se añadió una prueba
específica de fragmentación de BOM. No es una medición de cuota de RAM ni una
prueba de plataformas nativas.

El escritor registró estos resultados antes de que su ejecución terminara por
inactividad después de una llamada bash. No se recuperó la salida de esa última
llamada: el timeout del agente sigue siendo un fallo de ejecución, no una prueba
aprobada ni evidencia de que los tests anteriores fallaran. La implementación y
la observación del escritor están conservadas, sin reiniciar el agente agotado.

La primera verificación independiente no pudo ejecutar los casos: su scratch omitió
`assets/fonts/Inter.ttf` (suite salida 1 antes de cargar tests) y
`assets/branding/rp-music-variant-a.png` (análisis salida 1). Son fallos de
preparación, no regresiones demostradas. Revisión de fuente: implementado pero
sin verificación funcional independiente; ningún defecto de producto reproducido.
En esa tanda tampoco se ejecutó el diferencial del resolvedor. No se reparó ni
reintentó ese scratch; la autorización posterior abrió una unidad nueva.

### Unidad autorizada de compatibilidad: resultado funcional del coordinador

La copia completa dentro de `.dart_tool/a02_verification_v2` incluye todos los
assets y el paquete local de audio. El nuevo verificador no creó otro scratch ni
lanzó comandos: su contrato exige una copia fresca en el temporal del sistema y
no permite el aislamiento dentro del proyecto autorizado para esta unidad. La
verificación independiente sigue no disponible; no se sustituye por el coordinador.

El coordinador ejecutó primero 30 tests y análisis limpios, y luego un diferencial
con siete casos y catorce registros contra el helper anterior, con dos seams de IO
sintético (lookup/conector) y TLS confiable local. Aparecieron cuatro regresiones:
MIME 200 text, aceptación de 416 y mensajes 404/revocación. Se observaron RED y
GREEN, separando `probe` de la política estricta de `open`/relay; los destinos,
peticiones y rangos fueron iguales. Un test adicional reprodujo y restauró el
rechazo inicial sin IO con el mensaje «Audio remoto no autorizado.».

Resultado final observado por el coordinador en el árbol productivo: **40 tests
aprobados, salida 0; `flutter analyze --no-pub` sin incidencias, salida 0**.
El diferencial sin modificar volvió a pasar sobre copias idénticas del código
actual: **siete pares iguales, `differences: []`, salida 0**. Los diez tests
permanentes del sondeo no leen Git ni una revisión histórica. El helper acepta
200/206 sin filtrar MIME y conserva errores previos/plazo total de 20 s; esto
no garantiza audio reproducible. `open` mantiene MIME estricto y su respuesta 416.

El análisis de la copia diagnóstica tuvo salida 1 por dos infos de estilo en los
scripts temporales (`curly_braces_in_flow_control_structures` y `avoid_print`).
Sus tres archivos permanecieron byte-idénticos; no se silenciaron advertencias.
El análisis productivo verde excluye naturalmente `.dart_tool`, que no se entrega.
Ningún resultado equivale a prueba independiente, suite completa, plataforma
nativa, aprobación RDD o permiso de publicación.

**A02/S2 global sigue abierta y el candidato no es una entrega acreditada.**
Siguen faltando seguridad completa ante listas/demuxers y aperturas secundarias
nativas e integración Android; Windows recibió después el adaptador descrito
al comienzo, todavía con prueba independiente nativa no disponible. También falta
prueba específica de cambio de propietario y diferencial integral de consumidores.
No se cambiaron políticas del backend ni se limitaron codecs. No usar un fallback
remoto ni relajar TLS para eludir estos pendientes.

### Sonda del backend Windows existente

`tools/a02_mpv_io_probe.py` es un experimento, no el adaptador productivo. La DLL
local informa mpv `v0.36.0-403-g652a1dd907`, FFmpeg `n6.0` y API de cliente 2.1.
Tras corregir una escritura de puntero ctypes, el control sin protección abrió
realmente `/nested.wav` en un servidor loopback sintético. El contexto restringido
leyó un WAV en memoria mediante protocolo propio, seleccionó lavf y avanzó tras
un seek; las fixtures M3U/PLS/HLS/DASH/ASX no hicieron peticiones HTTP. No se usó
música del usuario ni una red externa.

La matriz completa terminó con **salida 1**: `ytdl=no` no está disponible (`-5`).
No se trata esa opción como aceptada. El experimento tampoco observa aperturas
file/UNC ni acredita todos los formatos, emisoras continuas, cancelación nativa
o el ciclo de vida productivo. Registrar un protocolo propio no elimina los otros
manejadores de mpv. En esa tanda aún no había integración del adaptador; la
integración posterior se documenta al comienzo y no convierte esta sonda en una
garantía global de IO. Los resultados acotados no cierran A02 ni autorizan una release.
