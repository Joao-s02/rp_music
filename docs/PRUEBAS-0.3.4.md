# Pruebas de RP Music 0.3.4

## Evidencia ya obtenida

- Suite completa: 97 pruebas aprobadas; análisis sin incidencias. No se suman repeticiones como casos nuevos.
- Ruta real del reproductor: controles visibles sin scroll en 320×568, 360×640, 800×360 y 1280×720. Capturas con fuentes/iconos reales inspeccionadas.
- Letras: parser, lectura por canción, resaltado con avance/retroceso, seek al tocar línea y retirada de letra anterior al cambiar pista.
- Extensiones: navegación múltiple con elección explícita, permiso de descarga antes de resolver audio y límites de textos.
- Paquetes externos: intérprete real, consultas de letras sintéticas y recepción de audio. YouTube recibió un archivo completo de 5983881 bytes; Spotify entregó 65536 bytes de una vista previa. Son pruebas de red, no de escucha nativa.
- YouTube Windows: ensayos nativos fallidos; candidato manual, no integración terminada.

## Pruebas que debe realizar el usuario

1. Android: instalar encima de la anterior sin desinstalar. Windows: extraer todo el ZIP. Verificar conservación de biblioteca, favoritos, listas y configuración.
2. Abrir Ahora suena con una canción local. Cambiar tamaño/orientación y aumentar texto; comprobar que anterior/pausa/siguiente no requieren desplazar. Probar tema claro/oscuro, volumen, progreso, cola e historial con aleatorio.
3. Letras → Importar: elegir LRC UTF-8 con marcas conocidas. Pausar, reanudar, avanzar y retroceder; comprobar resaltado y salto al tocar una línea. Cambiar canción y volver: no debe mezclarse la letra y debe recuperarse la copia guardada. Importar TXT: debe mostrarse sin sincronización. Cancelar selección debe conservar la letra.
4. Actualizar YouTube Android a 0.3.0 desde catálogo y revisar permisos. Buscar/reproducir una canción; Letras → nube consulta LRCLIB. Probar ausencia de letra y pérdida de conexión. Esta consulta comparte metadatos de la canción con el proveedor.
5. Descargar desde un resultado YouTube: aceptar permiso, esperar recepción y elegir destino. Abrir el archivo guardado; si está en la raíz de música, actualizar biblioteca. Cancelar selector no debe guardar audio; revocar permiso/desactivar fuente debe impedir nuevas descargas. Probar conexión interrumpida y límite de tamaño. Guardado real pendiente de validación en Android/Windows.
6. Spotify: instalar Spotify · vistas previas, pulsar Usar esta fuente y pegar enlace público de canción. Debe identificar el fragmento, no prometer tema completo. Algunas canciones carecen de vista previa. Letras se presentan sin sincronización del fragmento.
7. Activar dos fuentes: ver sus accesos y comprobar que abrir otra no cambia silenciosamente la fuente elegida. Desactivar retira su acceso y detiene su audio.
8. Probar música local en segundo plano, pantalla apagada, anterior/siguiente desde notificación/widget y escucha prolongada en el dispositivo físico.

No considerar aprobado YouTube Windows porque la búsqueda devuelva resultados. No prometer reproducción completa de Spotify sin cuenta. Registra plataforma, canción, pasos y resultado al informar fallos.

## Verificación de paquetes de esta publicación

Android universal y ARM64 compilados para 0.3.4/código 13; firma verificada y certificado compatible con la release anterior. Universal contiene arm64-v8a/armeabi-v7a/x86_64; ARM64 solo arm64-v8a. No había emulador ni teléfono conectado para instalar/abrir estos APK. Windows normal release 0.3.4+13 inició y siguió activo tras 5 s; ZIP íntegro de 20 archivos con dependencias, sin extensiones ni sonda de integración. Estas verificaciones no acreditan escucha ni corrigen los fallos de fuente Windows.
