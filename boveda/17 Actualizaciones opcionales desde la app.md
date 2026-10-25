---
tipo: investigacion-y-propuesta
estado: implementado-con-limites
actualizado: 2026-10-25
---
# Actualizaciones opcionales desde la app

Estado vigente: el usuario aprobó e implementamos el mecanismo en 0.2.4, con alcance y evidencia en [[18 Pruebas 0.2.3 y correcciones 0.2.4]]. El texto siguiente conserva la investigación y propuesta anteriores a esa autorización.

## Petición del usuario

El usuario menciona una función de Spoty Flac/Mornye como referencia: detectar una versión nueva y descargar/actualizar desde la app. Plantea una comprobación pequeña al inicio cuando haya internet, conservando el funcionamiento local del reproductor. No se investigó ni se confirmó el nombre, cambio de marca o implementación de la app citada; la referencia es el comportamiento descrito por el usuario.

La conectividad para actualizaciones es opcional; no implica cuentas, música por internet, telemetría ni dependencia de red para iniciar/reproducir. Se evalúa viabilidad y se propone el flujo, sin cambios de código ni nueva release en esta tarea.

## Propuesta

- Abrir biblioteca y reproductor inmediatamente. Consultar en segundo plano la distribución de RP Music con tiempo límite; si no hay acceso a red o GitHub falla, continuar sin bloquear ni mostrar error intrusivo.
- Como valores propuestos: consultar como máximo una vez al día, admitir desactivar consultas automáticas y ofrecer Ajustes → Buscar actualizaciones. No son preferencias ya aprobadas.
- Mostrar nueva versión, cambios y tamaño; descargar solo después de pulsar Actualizar. Permitir posponer/omitir una versión.
- Elegir el APK compatible con ABI real del dispositivo; ARM64 cuando corresponda y universal como alternativa. Validar versión posterior, identificador, firma compatible e integridad SHA-256 antes de solicitar instalación.
- Descargar por HTTPS a almacenamiento privado con progreso y cancelación; nunca tratar un archivo parcial como instalable. No incluir tokens GitHub en el cliente.
- Entregar el APK al instalador de Android. Gestionar permiso para instalar desde esta fuente y confirmación del usuario cuando el sistema los exija; no prometer instalación silenciosa. La reproducción puede interrumpirse al instalar/reiniciar el proceso, por lo que se guarda sesión antes.
- Conservar biblioteca/listas/favoritos mediante actualización del mismo paquete con firma compatible y migraciones de datos cuando se necesiten. La firma actual es de desarrollo; una clave de distribución estable requiere planificar compatibilidad y respaldo, sin sustituirla sin más.
- La versión 0.2.3 actual no tiene este mecanismo: la primera versión que lo incorpore deberá instalarse por el procedimiento actual; desde ella se podrán detectar versiones posteriores.

## Fuente de versiones

Las releases públicas de GitHub permiten consultar metadatos y descargar adjuntos sin cuentas de usuarios ni un servidor propio. La lista de releases incluye prereleases publicadas; `/releases/latest` excluye prereleases y por tanto no sirve como única fuente para nuestras alfas actuales. Separar canales estable/pruebas y comparar versiones correctamente, sin orden alfabético ni confundir el nombre de etiqueta alpha con versionName 0.2.3 y versionCode 5 del APK.

Límites de la API, caché, solicitudes condicionales, frecuencia, selección de canales y política de paquetes faltantes deben concretarse al implementar. La consulta directa tiene tráfico normal a GitHub (incluida IP de conexión); no se propone subir catálogo ni datos musicales.

## Plataformas y distribución

Primera implementación propuesta: Android distribuido por GitHub. Para Google Play, usar su mecanismo de actualizaciones y revisar las políticas antes de reutilizar un instalador propio. Windows necesita un flujo separado: la distribución actual es ZIP portable y no se sustituye un EXE en ejecución con el mismo mecanismo Android; puede comenzar notificando y abriendo la descarga, dejando un actualizador Windows para otra etapa.

## Verificación y pendientes

Investigación documental, no implementación comprobada. Pendientes: alcance Android/Windows, activación predeterminada, frecuencia, canal alfa/estable, red móvil/Wi-Fi, cancelación, recuperación de descargas interrumpidas, firma futura y prueba real de actualización entre dos versiones conservando datos.

Fuentes oficiales consultadas el 2026-10-25:
- [GitHub REST releases](https://docs.github.com/en/rest/releases/releases): lista pública sin autenticación, adjuntos y exclusión de prereleases en latest.
- [Distribución alternativa Android](https://developer.android.com/distribute/marketing-tools/alternative-distribution): instalación de APK y habilitación de fuentes externas.
- [PackageInstaller SessionParams](https://developer.android.com/reference/android/content/pm/PackageInstaller.SessionParams): acciones de usuario y condiciones de instalación.
- [Firma de aplicaciones](https://developer.android.com/studio/publish/app-signing): identidad y firma de actualizaciones.
- [Google Play In-app updates](https://developer.android.com/guide/playcore/in-app-updates): flujo propio de Play.

Relaciones: [[02 Vision y decisiones]], [[05 Rendimiento]], [[07 Preguntas e investigacion]], [[16 Pruebas 0.2.2 y rediseno 0.2.3]], [[09 Registro de cambios]].

## Implementación autorizada posterior

El usuario aprobó la propuesta junto con el informe 0.2.3. Android ya consulta versiones y descarga/verifica un APK antes de pedir instalación; Windows consulta y abre la descarga. Frecuencia diaria, opción automática y canal de pruebas están implementados; detalle, verificaciones y límites en [[18 Pruebas 0.2.3 y correcciones 0.2.4]]. No se completó aún una actualización entre dos releases públicas posteriores y no se publicó 0.2.4 en esta tarea.
