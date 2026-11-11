# Pruebas de RP Music 0.3.20

## Comprobaciones automatizadas

188 pruebas Flutter aprobadas y una opcional omitida por falta de un paquete externo. Se comprobó el área inferior simulada, Atrás en colecciones y fuentes de prueba, el menú de orden, las tarjetas y el desplazamiento en Letras. Análisis limpio de los archivos de interfaz y pruebas modificados.

## Pruebas pendientes en un equipo real

| Plataforma | Pasos | Resultado esperado |
| --- | --- | --- |
| Android | Instala el APK sobre 0.3.19 desde Archivos. Revisa el resultado de Play Protect. | La actualización conserva la biblioteca, listas, favoritos y extensiones. |
| Android | Con una pista activa, desplázate por Canciones, Álbumes, Artistas, Carpetas, Favoritos y Listas. Repite en el detalle de una lista y con gestos y tres botones. | La barra de la app se recoge al avanzar. El minirreproductor queda accesible y la barra vuelve al desplazarse hacia arriba. |
| Android | Abre un artista, carpeta y extensión. Pulsa Atrás en cada caso. En YouTube, recorre además las categorías y los resultados. | El detalle se cierra o retrocede en su historial. La entrada de la extensión vuelve a Explorar. |
| Android y Windows | Pulsa Filtrar por, elige un criterio y cambia la flecha. Selecciona Tarjetas en Ajustes y reinicia. | El menú se cierra al elegir y el orden cambia. La vista de tarjetas se conserva. |
| Android y Windows | Abre la lupa de Biblioteca y después Letras de una canción con texto largo. | La búsqueda se despliega suavemente y el conteo aparece una vez. La cabecera de Letras se recoge al avanzar y reaparece al volver hacia arriba. |
| Windows | Extrae el ZIP completo, abre el ejecutable y reproduce una pista local. | La aplicación abre con sus dependencias y conserva los datos del perfil. |
