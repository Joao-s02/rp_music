---
tipo: correccion-y-diseno
estado: publicado-con-validacion-y-limites
actualizado: 2026-10-28
---
# Albumes y extensiones con identidad RP 0.3.13

## Confirmación del usuario de 0.3.12

Las letras sincronizadas funcionan tanto en la extensión como en canciones descargadas y abiertas en local. Aprueba la estética de lectura y especialmente la vista Escena. No especifica plataforma de esta confirmación. No equivale a nueva prueba física propia. Antecedente: [[41 Letras dinamicas y reproductor fijo 0.3.12]].

## Requisitos confirmados

1. Ralentizar el indicador animado de la cola.
2. Corregir álbum ausente al descargar desde todas las extensiones YouTube, también canciones antes reconocidas.
3. Animar y dar identidad propia RP a la sección local de álbumes, respetando colorimetría.
4. Hacer más clara/viva la gestión de extensiones, con emblemas reconocibles por función.
5. Aceptar todos los permisos e instalar mediante un botón explícito, conservando revisión individual.
6. Renovar las pantallas de YouTube con el mismo lenguaje visual.

## Diagnóstico y decisiones implementadas localmente

Los cuatro proveedores heredan una condición que abandona la identificación de grabación si el álbum de entrada está vacío o es Sin álbum. Se permite ahora identificar una grabación compatible por título/artista/versión/duración y escoger un álbum oficial no recopilatorio; en empates se prefiere fecha anterior y luego ID estable. Un álbum ya conocido conserva prioridad y los lotes con identidad fijada no se reclasifican. La letra sincronizada se elige aparte y nunca determina el álbum. Campos opcionales reales (secondary-types y length) se aceptan ausentes/nulos. La selección se encapsula en función para evitar diferencias de asignación entre ramas de dart_eval. No se cambia API2 ni audio original.

Candidatos externos exclusivos en rp-music-extensions/previews/0.3.13: YouTube Android/Windows0.5.2 y Explorador Android/Windows0.2.2, app mínima0.3.13. Catálogo público/bytes publicados intactos. Constructor reproducible build_0313.py y pruebas del proveedor en ese repositorio, no en la app.

La verificación real encontró también conexiones TLS intermitentes al proveedor de metadatos. El anfitrión reintenta una conexión fallida de metadatos de forma limitada, revalidando autorización; si no se recupera, conserva audio/etiquetas parciales y aviso, sin inventar álbum ni aplicar reintentos a búsqueda/reproducción.

Interfaz: indicador de cola pasa de1100 a2100ms por ciclo y mantiene pausa/movimiento reducido. PulseSurface dibuja cinco surcos cian/violeta ligados a entrada e interacción, sin bucle perpetuo decorativo. Álbum local abre una funda con disco/surcos, carátula legible y reacción al comenzar reproducción; cuadrícula y encabezados de colecciones comparten motivo. No se altera el icono maestro [[15 Identidad visual e icono]].

Extensiones: emblemas de función (exploración, vídeo/música, letras, radio, biblioteca, pulso y laboratorio), catálogo como acción principal, ajustes de propietarios plegados, permisos e instalación separados del catálogo. Aceptar todo e instalar concede únicamente los permisos declarados tras pulsarlo; guardar desactivada conserva permisos parciales. Fuentes: emblema, búsqueda redondeada, categorías con icono y resultados con tarjetas/surcos. Estos componentes son genéricos del anfitrión; lógica YouTube permanece externa.

## Comprobaciones y pendientes

Cuatro paquetes reales compilados/ejecutados con dart_eval: álbum desconocido/conocido, orden de respuesta invertido, campos opcionales, rechazo de interpretación incompatible, etiquetas y LRC conservados, lotes bloqueados. Consulta pública real: La Incondicional / Luis Miguel desde Sin álbum identifica Busca Una Mujer (1988-11-25), pista5/10, artista del álbum y55 líneas sincronizadas; no se registra el texto de la letra en la bóveda. Fallos TLS previos se conservan como límite de red, no como éxito.

Primera suite completa tras ajustes de navegación:160 aprobadas/una optativa omitida y análisis limpio. Pruebas adicionales de reintento/incrustación y descarga nativa en curso. Capturas de widgets Flutter a360/1280 revisadas; no equivalen a dispositivo Android. Compilaciones normales finales y entrega local pendientes. No se ha solicitado publicar esta versión en el mensaje actual.

## Diagnóstico adicional y cierre nativo

Con duración real de YouTube (258000ms), MusicBrainz identifica la misma grabación de álbum como266560ms. El filtro anterior de2.5%/5s la rechazaba. Para metadatos de grabación se exige título normalizado exacto, artista/versión compatibles y se toleran10s o5% de duración; letras conservan su filtro previo más estricto. Una grabación con diferencia grande se rechaza en los cuatro paquetes.

Si la consulta oficial ya identifica álbum y falla después la consulta de sus detalles, se conserva el álbum verificado y la fecha disponible, sin inventar artista de álbum/numeración. Prueba controlada503 después de identificación mantiene álbum y LRC, complete=false. Reintento del anfitrión limitado a una repetición por etapa, con revalidación de permisos; no se reintenta indefinidamente ni se evita TLS.

Descarga nativa Windows comprobada desde búsqueda de YouTube, eliminando el álbum de entrada: Busca Una Mujer incrustado y leído desde M4A, pista5,55 líneas LRC incrustadas, reproducción real con avance>2s, solicitud de seek y SHA256 de bloques mdat conservado. Avisos no fatales conocidos de osc/caché multimedia. Intentos previos tuvieron TLS/503 y datos parciales: no se presentan como éxito ni se oculta dependencia del servicio. No se distribuye audio de prueba ni letra completa.

## Verificación final de código

164 pruebas aprobadas/una optativa omitida; análisis limpio. Nueve pruebas nuevas incluyendo reintento/incrustación, permisos parciales/conjuntos, fuente320px/texto1.6 y movimiento reducido. Capturas finales revisadas. adb devices sin teléfono. Windows release normal compilado; Android normal en curso. No publicar ni actualizar catálogo sin solicitud correspondiente.

## Entrega local comprobada

Windows release normal50.6s y APK universal normal46.7s en recompilación final. APK0.3.13, código22, tres ABI (armeabi-v7a/arm64-v8a/x86_64), firma compatible SHA256 eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d. Windows EXE0.3.13+22 y ZIP completo32 archivos/licencias/guías verificados byte a byte. APK sin rpmx/DLL/audio Windows; registro generado normal sin integration_test. Un primer intento Android falló por registro de pruebas heredado de la sonda: se retiró exclusivamente ese bloque del archivo generado ignorado y se recompiló con éxito, sin modificar fuentes nativas de plataforma.

Entrega en dist/0.3.13-local: universal, Windows, USO/PRUEBAS/CAMBIOS y SHA256SUMS; cuatro extensiones aparte en repositorio externo/previews/0.3.13. No incluye ARM64 separado porque es entrega local, no publicación. No se ha publicado ni hecho push; referencia pública0.3.12 intacta. Capturas históricas restauradas después de los tests y cuatro archivos preexistentes del usuario excluidos de cambios del trabajo.

Revisión final de candidatos: la exclusión se aplica a Compilation, sin confundir Soundtrack con recopilación. Los cuatro paquetes reales repasan ese caso, opcionales, duración y conservación parcial. SHA256 de entrega local y cuatro candidatos comprobados.

## Publicación autorizada — 2026-10-28

El usuario solicita subir la nueva release. Se prepara0.3.13+22 con universal/ARM64/Windows, guías/hashes y cuatro paquetes externos actualizados; comprobación de borrador y pública antes de confirmar publicación. [[42 Albumes y extensiones con identidad RP 0.3.13]].

## Comprobación previa a publicación

ARM64 normal compilado72.1s, versión0.3.13/código22 y firma idéntica al universal/entregas previas. Windows ZIP32 archivos verificados byte a byte. Siete adjuntos y manifiesto preparados. Catálogo externo ab48a63 publicado: diez opciones,29 paquetes/variantes verificados byte a byte y cliente real selecciona los cuatro nuevos paquetes. Binarios normales sin complemento de integración ni rpmx.

## Publicación comprobada — 2026-10-28

0.3.13-alpha.1 publicada, app0.3.13+22. ReleaseID 427408912; tag/código a3f8449a83aaec7da29c5762c4adfff82bd1fbc0. Android universal/ARM64 y Windows x64 completo32 archivos/licencias/guías. Siete adjuntos verificados en borrador y por API pública: tamaños/SHA256, tag al commit correcto y manifiesto descargado idéntico. Catálogo externo ab48a631237f3bf04057b6662b8b168b94b62449: diez opciones y29 paquetes/variantes verificados byte a byte; cliente real selecciona YouTube Android/Windows0.5.2 y Explorador Android/Windows0.2.2. 164 pruebas aprobadas/una optativa omitida, análisis limpio; descarga nativa Windows con álbum Busca Una Mujer, pista5,55 líneas LRC incrustadas, reproducción y bloques mdat conservados. Android físico, escucha prolongada, valoración visual del usuario y latencia API3 Android pendientes. [[42 Albumes y extensiones con identidad RP 0.3.13]].

[Release pública](https://github.com/Joao-s02/rp_music/releases/tag/v0.3.13-alpha.1). Las fases locales y límites anteriores se conservan como historial, no como estado final.
