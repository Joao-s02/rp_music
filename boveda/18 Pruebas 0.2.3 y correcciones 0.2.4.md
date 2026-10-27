---
tipo: pruebas-y-correcciones
alcance: historico-de-version-o-proyecto
estado: publicado-con-validacion-local
actualizado: 2026-10-25
---
# Pruebas 0.2.3 y correcciones 0.2.4

> **Alcance de esta nota:** conserva la entrevista, investigación o etapas de la versión/proyecto indicados. Expresiones «local», «vigente», «pendiente» o «sin publicar» se refieren a ese momento; leer la confirmación posterior dentro de la nota. Estado global actual en [[10 Estado del repositorio]] y decisiones temáticas desde [[00 Inicio]].

## Informe y autorización confirmados

El usuario aprobó implementar [[17 Actualizaciones opcionales desde la app]] junto con estas correcciones de 0.2.3: teclado móvil que abre/cierra sin permitir buscar; reproducción que se detiene tras un tiempo en segundo plano; error startForegroundService no permitido por mAllowStartForeground false en Galaxy A34 5G Android 16; copiar/importar logs de diagnóstico; biblioteca siguiendo la imagen aportada con búsqueda contraída a una lupa. La imagen es referencia visual, no instrucciones ni datos reales de biblioteca/almacenamiento.

Se prepara **0.2.4+6** local. No se autorizó publicar una nueva release ni enviar cambios a GitHub en esta petición.

## Implementación

### Búsqueda y biblioteca

El TextField anterior estaba después de una tarjeta condicional a viewInsets: al abrir el teclado cambiaba la estructura del árbol y podía desmontar el campo. Ahora la búsqueda vive en una posición estable de la cabecera, con clave y FocusNode persistentes, sin depender de la presencia del teclado. La lupa la abre y enfoca; cerrar limpia el filtro. Continúa la búsqueda con debounce y se esconden reproductor/navegación durante el teclado para dar espacio.

Nueva biblioteca vacía: marca A, contador real, ilustración de ondas, «Tu biblioteca está en silencio», explicación local/sin cuentas, botón Elegir carpeta y tarjetas orientativas Music/SD que abren el selector autorizado. No se inventan 3.420 pistas, espacio libre, carátulas o perfiles de cuenta. Las tarjetas son sugerencias para buscar una carpeta en SAF, no concesiones automáticas a Music/SD.

### Reproducción Android

Se conserva el servicio ya iniciado en foreground durante pausa y transiciones (`androidStopForegroundOnPause=false`; `androidNotificationOngoing=false` por la restricción de configuración del paquete). Al cambiar de pista, el estado de carga mantiene la intención de reproducción y evita emitir idle transitorio por la pausa del decodificador. No se intenta reiniciar repetidamente un servicio que Android haya prohibido: se registra el error y se pausa el motor, permitiendo recuperación mediante una acción explícita del usuario.

Detener queda disponible en el reproductor ampliado y acciones del sistema. La primera prueba detectó un problema de audio_service 0.18.19: stopSelf no libera inmediatamente foreground/wake lock si el servicio sigue enlazado. Se conserva una copia local explícita en third_party/audio_service, con licencia MIT y RP-MUSIC-PATCH.md. Cambios funcionales del paquete: stop() llama exitForegroundState() antes de desactivar sesión/stopSelf; exitPlayingState() libera el wake lock de CPU al pausar aun cuando conserva foreground, y enterPlayingState() lo recupera al reanudar. Pausar mantiene el servicio preparado sin mantener la CPU despierta innecesariamente. No se modificó la caché Pub. Prueba repetida confirma liberación al detener. Actualizaciones futuras del paquete deben revisar este parche.

Se ofrece acceso a ajustes de optimización de batería; no se solicitan exenciones automáticas ni permisos de almacenamiento generales. Esto no garantiza que One UI/HyperOS no restrinjan una app ni prueba duración prolongada en el teléfono físico.

### Diagnóstico

Diálogo con texto seleccionable y Copiar texto, Exportar log, Importar log y Actualizar. Exportación mediante selector a TXT; importación de TXT/LOG hasta 256 KB como texto de lectura, sin ejecución ni envío. Registro acotado a cien eventos de la sesión actual con UTC, estados, selección por índice, ciclo de vida y errores de servicio. Incluye versión/build, modelo/Android/API, notificación, token de sesión, foreground y estado de optimización de batería. No recopila cuentas, números de serie ni catálogo musical; el error nativo puede incluir detalles técnicos de la app. Copiar/exportar es una acción explícita del usuario. Los eventos no sobreviven al cierre forzado salvo que se hayan exportado.

### Actualizador

Consulta opcional en segundo plano tras dibujar la app, como máximo una vez al día, sin impedir uso local y con errores automáticos silenciosos. Ajustes permite desactivar consulta, elegir incluir versiones de prueba y consultar manualmente. Por defecto incluye alfas porque esa es la distribución actual. Se puede omitir una versión; la consulta manual permite volver a verla.

GitHub releases públicas sin tokens; comparación numérica SemVer, prereleases, selección ARM64 o universal compatible y Windows ZIP. Descarga Android solo al pulsar, con progreso/cancelación, límites de tamaño y tiempos de inactividad, escritura incremental fuera de UI, SHA-256 del asset y rechazo de URLs/redirecciones externas a los hosts previstos de GitHub. Parciales no instalables y eliminados al cancelar/fallar cuando el sistema permite borrarlos. Preferencias separadas de la biblioteca, persistidas con LocalStore.

Antes de instalar, Kotlin vuelve a comprobar SHA-256, ruta privada, mismo paquete, nombre de versión esperado, versionCode superior y certificado exacto coincidente. FileProvider solo expone el directorio privado updates con acceso temporal al instalador. Se pide habilitar esta fuente si falta autorización y se entrega la confirmación a Android; no se instala en silencio. La firma actual de desarrollo se conserva. La rotación de firmas no está implementada: un certificado distinto se rechaza.

Windows consulta y abre la página de descarga al aceptar; no reemplaza automáticamente un EXE en ejecución. La primera 0.2.4 debe instalarse manualmente porque 0.2.3 carece del actualizador. Para una futura distribución Play, separar el canal/mecanismo y revisar sus políticas; REQUEST_INSTALL_PACKAGES solo se usa en esta distribución APK por GitHub.

## Verificaciones realizadas

- 42 pruebas unitarias/widgets aprobadas, incluidas selección de canales/arquitecturas, orden de versiones, exclusión de borradores/omitidas, URLs/digest inválidos, fallback universal, sin internet y espera diaria, integridad, cancelación, permiso del instalador simulado y regresiones previas.
- Búsqueda probada a 360×640 con texto 130 % y aparición del teclado: se conserva la misma instancia de EditableText y el foco, y se puede filtrar. Diálogo de diagnóstico a ese tamaño copia el error completo y no desborda; registro limitado a cien eventos.
- Prueba nativa debug API 37: cambio automático de pista con la actividad en segundo plano, pausa sin degradar foreground, reanudación sin errores y detención liberando foreground: aprobada después del parche.
- Sonda release con entrada separada: advanced=true; notificación/sesión/foreground presentes al reproducir, pausar y reanudar; cero notificaciones y foreground=false al detener; errors vacío. Se envió al fondo después del marcador de inicio. La sonda no se distribuye como aplicación.
- Validación nativa del actualizador en emulador API 37: rechaza hash o versión esperada incorrectos; acepta un APK local del mismo certificado con código superior y abre la autorización de fuente cuando está deshabilitada. Para ello se generó una sonda de prueba con código 7, guardada solo en build/update-check, y se transfirió con adb/run-as a una app debug. No se publicó ni se incluye en dist. No se confirmó un reemplazo de la app desde el instalador en esta prueba.
- Revisión visual de biblioteca vacía y álbumes/reproductor en móvil/escritorio, con capturas en design/verification. Análisis estático final limpio; git diff --check correcto para cambios propios. El código/licencias upstream se conservan como dependencia externa.

## Límites y retesteo

Falta repetir en Galaxy A34 5G Android 16 y Poco X6 durante un periodo prolongado y con pantalla apagada, incluyendo cambios automáticos de canción. Ante otro corte, copiar/exportar diagnóstico antes de cerrar la app, indicando duración y acción previa. La prueba en emulador API 37 no equivale a prueba física API 36.

Falta una actualización entre dos releases públicas posteriores con aceptación del instalador y comprobación de datos conservados. Descarga/guardas se probaron con respuestas aisladas y la validación APK con archivos reales; no se anuncia como ya completado ese recorrido público futuro. Se preservan pendientes anteriores de Tecno y cierre subjetivo Windows.

Fuentes consultadas 2026-10-25: [audio_service](https://pub.dev/packages/audio_service), [restricciones foreground Android](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start), [PackageManager](https://developer.android.com/reference/android/content/pm/PackageManager), fuentes locales 0.18.19 y referencias de [[17 Actualizaciones opcionales desde la app]].

Relaciones: [[03 Biblioteca y reproduccion]], [[05 Rendimiento]], [[07 Preguntas e investigacion]], [[10 Estado del repositorio]], [[09 Registro de cambios]].

## Entrega local final

- dist/0.2.4: APK universal de 57 047 748 bytes, APK ARM64 de 21 337 361 bytes y ZIP Windows x64 de 14 506 646 bytes, con guías, ejemplo y SHA256SUMS.txt.
- Ambos APK 0.2.4+6, firma v2 válida y mismo certificado que versiones anteriores; universal ARM32/ARM64/x64 y variante exclusivamente ARM64. Recursos multimedia protegidos y alineación ZIP 16 KB verificados.
- Windows EXE 0.2.4+6 y ZIP verificado con motor/backend/activos/guías, sin integración de pruebas. Recompilaciones finales tras resolver cierre del buscador y manejo repetido del rechazo foreground.
- Se comprobó también que cerrar la lupa cancela el debounce pendiente y limpia el filtro; la regresión de búsqueda pasó. La captura nativa de biblioteca vacía está en design/verification/android-0.2.4-empty.png. En la prueba de teclado real se mantuvieron foco y mInputShown=true con texto «prueba» en el campo.
- Sin publicar ni enviar cambios a GitHub. La última publicación sigue siendo v0.2.3-alpha.1. No se sustituyeron paquetes de versiones anteriores.

## Publicación solicitada de 0.2.4 — 2026-10-25

El usuario autorizó subir la nueva release a GitHub. Se prepara v0.2.4-alpha.1 como preliminar, con fuentes y siete adjuntos: APK universal/ARM64, Windows, dos guías, ejemplo y SHA-256. Se mantienen los binarios verificados y se actualizan las guías de distribución. Confirmar publicación, commit y digest de adjuntos al terminar.

## Publicación confirmada — 2026-10-25

- [Release v0.2.4-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.4-alpha.1) publicada como preliminar; GitHub confirmó isDraft=false e isPrerelease=true.
- Etiqueta sobre `08f783c1f4c69b475f04d95783004eb6df4ad87b`; fuentes enviadas a main. Esta confirmación es posterior al commit etiquetado.
- Siete adjuntos en estado uploaded, verificados contra los archivos locales por tamaño y digest SHA-256 de GitHub: APK universal/ARM64, ZIP Windows, USO.md, PRUEBAS-0.2.4.md, descubrir.json y SHA256SUMS.txt.
- Se actualizaron las guías y reempaquetó Windows para distribución: ZIP final de 14 506 717 bytes. Binarios compilados y ambos APK se conservaron sin cambios.
- 0.2.4 debe instalarse manualmente sobre la anterior para habilitar detección de versiones futuras. Publicar no sustituye el retesteo prolongado Galaxy A34 Android 16/Poco X6 ni completa por sí solo una actualización entre releases desde el instalador. No se alteraron releases anteriores.
