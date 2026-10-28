# Probar Explorador musical y Radio por internet

Entrega **0.3.9+18**, en publicación autorizada. La app 0.3.8 publicada no admite estos paquetes de red. Actualiza con el APK universal/ARM64 o abre la carpeta Windows completa; conserva datos y no desinstales para actualizar.

Las dos extensiones están en el catálogo público de https://github.com/Joao-s02/rp-music-extensions y también en previews/js-music-0.1.0 de ese repositorio. No se incluyen dentro del APK/ZIP:

- explorador-musical.rpmx — Explorador musical 0.1.0.
- radio-internet.rpmx — Radio por internet 0.1.0.

## Instalación

1. Abre la app0.3.9 y entra en Extensiones → Explorar repositorio → https://github.com/Joao-s02/rp-music-extensions → Consultar. También puedes instalar desde archivo.
2. Instala cada opción del catálogo o importa el .rpmx y revisa sus permisos. Ambas usan red a dominios declarados, datos privados, navegación y reproducción. Radio añade permiso para audio HTTPS de servidores públicos de emisoras con dominios variables.
3. Abre **Explorar JS** o **Radio JS** en la navegación. No hace falta cambiar el propietario de Fuente; YouTube estable y Explorador Dart siguen disponibles.

## Explorador

Escribe un nombre y pulsa Canciones, Artistas, Álbumes o Listas. Abre un resultado con Abrir, recorre sus elementos y usa Atrás. Página siguiente recorre el bloque cargado; Cargar siguiente bloque solicita la continuación del servicio. Acepta enlaces HTTPS de listas públicas de YouTube. Escuchar solicita audio AAC y lo entrega al reproductor de RP Music.

Es experimental y sin cuenta. No promete discografía completa, contenido privado ni disponibilidad por región. Esta variante no incorpora importar listas, descargar ni sincronizar; YouTube Explorador Dart conserva sus funciones previas. Navegación y resolución de URL comprobadas con red pública en Windows; eso no prueba reproducción nativa de YouTube Windows, cuyo límite previo se conserva. Android físico pendiente.

## Radio

Busca por nombre y, si quieres, país o etiqueta/género. País y etiqueta se consultan tal como se escriben en el directorio; prueba otros términos si no hay coincidencias. Emisoras populares consulta el directorio sin esos filtros. Página siguiente recorre resultados; Más emisoras pide otro bloque. Solo muestra HTTPS MP3/AAC, sin HLS/listas remotas. Algunas búsquedas pueden no tener emisoras compatibles aunque existan otras HTTP/HLS.

Guarda hasta 30 favoritas privadas (sujeto a espacio). Mis favoritas funciona para consultar/editar la lista guardada sin conexión; escuchar siempre requiere conexión y renueva datos por UUID. No sincroniza con ninguna cuenta. Una emisora puede fallar o cambiar de dirección. Cambiar de radio/canción usa el único reproductor de la app.

## Comprobaciones recomendadas

- Buscar, abrir artista/álbum/lista y pasar páginas sin perder botones con texto ampliado.
- Reproducir una emisora, pausar/reanudar y cambiar a música local.
- Guardar una favorita, cerrar/reabrir y verificar que sigue guardada.
- Cancelar una búsqueda y verificar que una respuesta tardía no cambia la pantalla.
- Desactivar la extensión mientras suena: debe detenerse el audio correspondiente.
- Cortar conexión: debe aparecer un error recuperable; no un falso resultado nuevo.

No confundir resolución HTTP de audio con escucha nativa. Registrar plataforma/dispositivo, función y resultado. [Evidencia técnica y pendientes](../boveda/37%20Explorador%20y%20radio%20JavaScript.md).
