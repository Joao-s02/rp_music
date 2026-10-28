# Pruebas de RP Music 0.3.9

## Comprobado

138 pruebas aprobadas (130 de app + 8 externas) en suite conjunta y una prueba optativa de red omitida. Análisis completo sin incidencias. QuickJS nativo interrumpe bucle y recursión excesiva y sigue aceptando llamadas. Pantallas reales360 px con escala 1.5, estado/permisos, cancelación, límites/dominios, audio/propietario y compatibilidad Dart comprobados. Paquetes anteriores YouTube mantienen hashes y operaciones reales en Dart.

Sonda Windows con red pública: búsqueda de artistas/álbumes/listas/canciones y apertura con contenido nuevo, resolución real AAC de La Incondicional y lista100+100. Radio Swiss Pop AAC 192: favorita, audio nativo avanzó2167 ms, pausa/reanudación y parada por desactivación sin errores. No es garantía sobre toda emisora ni prueba nativa YouTube Windows.

## Probar en dispositivos

1. Instalar universal o ARM64 encima sin desinstalar; Windows extraer todo el ZIP y abrir rp_music.exe con DLL/data. Confirmar versión0.3.9 y biblioteca/listas/ajustes conservados.
2. Consultar catálogo https://github.com/Joao-s02/rp-music-extensions, instalar Explorador musical0.1.0 y Radio por internet0.1.0 y revisar permisos. Mantener disponibles paquetes Dart; no cambiar propietario Fuente para usar las pantallas JS.
3. En Explorar JS buscar artista/álbum/lista/canción, abrir, volver y paginar. Probar lista pública larga y Cargar siguiente bloque; resultados deben renovarse, sin presentar errores como páginas nuevas.
4. Pulsar Escuchar y comprobar audio/pausa/notificación según plataforma. Anotar fallo de servicio/región/formato; YouTube Windows conserva sus límites conocidos.
5. En Radio JS buscar emisora, país o etiqueta. Probar populares, páginas/bloques; solo se muestran HTTPS MP3/AAC compatibles. Escuchar una, pausar/reanudar y cambiar a música local.
6. Guardar/quitar favoritas, cerrar/reabrir y verificar persistencia. Consultar favoritas sin red; escuchar requiere conexión y renueva URL por UUID.
7. Cancelar consulta/carga; una respuesta tardía no debe cambiar pantalla ni reproducir. Desactivar extensión mientras suena: detener audio propio. Volver a activar conserva datos privados, exige nueva selección de audio.
8. Cortar conexión: error recuperable; probar texto ampliado/teclado sin desbordes. Retestar música local, letras, descargas Dart, SD/SAF/widget/permisos y escucha prolongada.

Android físico no conectado en la verificación; firma/ABI/compilación no equivalen a instalación o prueba física. Informar equipo, plataforma, versión, pasos y resultado. Cuentas/sincronización y descargas/importación desde nuevas pantallas JS no están implementadas.
