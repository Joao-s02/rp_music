# Probar RP Music0.3.12 — letras y reproductor

Entrega local0.3.12+21, posterior a la release pública0.3.11. Android: instalar encima sin desinstalar. Windows: cerrar la anterior, extraer todo el ZIP en carpeta nueva y abrir rp_music.exe junto a DLL/data/licencias. Conservar soporte privado y archivos musicales.

## Recuperar letras dinámicas

Los nuevos paquetes están en rp-music-extensions/previews/0.3.12, fuera del APK/ZIP:

- YouTube Android/Windows0.5.1.
- YouTube Explorador Android/Windows0.2.1.
- Letras locales0.1.1.

Importar el paquete de tu plataforma desde Extensiones, revisar permisos y seleccionar Fuente/proveedor de letras cuando corresponda. Estos candidatos todavía no cambian el catálogo público. API2 y paquetes anteriores se conservan.

Descargar otra canción con una letra sincronizada disponible. Abrir Letras: debe seguir la posición, permitir tocar una línea para avanzar y retroceder al cambiar el tiempo. Se prioriza LRC de una interpretación compatible antes que texto plano de la edición exacta; esto no cambia álbum/portada/artista de álbum de la descarga. También se contrasta duración, título, artista y versión. Si solo hay texto disponible, se indica expresamente: no se inventan tiempos.

Para archivos descargados anteriormente con letras planas, instalar/activar Letras locales0.1.1. Al abrir Letras se intenta recuperar sincronización mediante el proveedor autorizado; también se puede pulsar Buscar sincronizada. La mejora se guarda exclusivamente en la app y sigue disponible offline, sin reescribir tu canción. Una copia sincronizada guardada precede al texto incrustado antiguo y no se sustituye por una respuesta plana.

## Letras vivas y Escena

La lectura destaca la línea actual con tipografía y transiciones; sigue la posición real. Puedes explorar manualmente y pulsar Seguir canción para volver al punto actual. Importar LRC/TXT sigue disponible.

El botón de pantalla completa abre Escena: composición con letras grandes, fondo cian/violeta y transición entre frases. Tocar el fondo oculta/muestra controles para grabar con el grabador del teléfono. Salir de escena vuelve a lectura. Pausa/avance/siguiente siguen operativos con controles visibles. No es un exportador de vídeos ni requiere subir audio o iniciar sesión.

Si importas EnhancedLRC con marcas explícitas por palabra, el resaltado respeta esos tiempos. LRC común se anima por línea; no se convierte artificialmente en karaoke por palabra. Se respeta Reducir movimiento del sistema. En letras sin tiempos se conserva una presentación legible y el acceso a buscar sincronización.

## Reproductor ampliado

La pantalla base queda fija, sin desplazamiento vertical. La carátula adapta su tamaño al espacio y no lleva borde cian. Se conserva el indicador superior de origen y se retira el inferior repetido. Detalles, Letras, Cola y Volumen quedan juntos; Volumen abre el control anterior en un panel y deja quieta la pantalla base.

Probar en vertical/horizontal y con texto ampliado: controles principales visibles. Deslizar con pequeña inclinación debe cambiar pista; arrastrar verticalmente la carátula no mueve la pantalla. El deslizador de tiempo conserva su gesto independiente.

Abrir Cola cuando llevas muchas canciones: debe mostrar la actual centrada con anteriores/siguientes accesibles. Puedes desplazarte libremente y tocar otra canción. El indicador de la actual se anima mientras reproduce y se detiene en pausa o con movimiento reducido. Es un indicador de reproducción, no un analizador de frecuencias.

## Alcance de pruebas

Escenarios de letras y reproductor a320×568,360×640,800×360 y1280×720, volumen oculto, gesto diagonal, cola78/100 y caché de sincronización comprobados con pruebas. Cinco paquetes reales pasan prioridad LRC/búsqueda alternativa/retención ante fallos/duración y conservación del álbum. Consulta pública y descarga nativa Windows:55 líneas sincronizadas incrustadas, audio reproducible, seek y bloques de audio idénticos tras etiquetar.

Los resultados finales de suite/análisis/binarios se mantienen en la nota41 de la bóveda. Android físico, escucha prolongada y juicio visual del usuario siguen pendientes; no se garantiza cobertura de letras de toda canción o región. La latencia AndroidAPI3 permanece como asunto separado.
