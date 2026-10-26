# Pruebas de RP Music 0.3.2

## Android

1. Actualizar desde 0.3.1 sin desinstalar. Comprobar conservación de carpeta, favoritos, listas y preferencias.
2. Biblioteca → Álbumes → abrir un álbum con carátula. Ver título/artista y duración disponible; reproducir y probar Aleatorio. Cambiar entre Pistas del álbum y Cola en curso; verificar orden de cola y pista activa. Guardar álbum como lista y comprobar su contenido.
3. Probar un álbum sin carátula/metadatos, nombres muy largos y tamaño de texto grande. Desplazarse hasta las últimas pistas.
4. Importar el paquete de fuente 0.2.0 del repositorio de extensiones y revisar/aceptar permisos de red, reproducción y navegación. Si sigue instalada la 0.1.0 debe actualizarse. Elegirla como fuente si otra ocupa esa función.
5. Usar el acceso YT de la navegación. Buscar y reproducir. Verificar que hay un único control pequeño, por encima de la barra de gestos o de tres botones. Abrir/cerrar teclado, girar el teléfono y volver a buscar.
6. Abrir el reproductor ampliado: debe mostrar el nombre del servicio. Reproducir luego un archivo: debe indicar Audio local.
7. Pausar, cambiar pista, avanzar posición, enviar app a segundo plano y apagar pantalla durante varios minutos. Verificar controles y carátula en notificación.
8. Desactivar fuente o retirar permisos: debe desaparecer el acceso y detenerse su audio; las demás funciones locales siguen disponibles.

## Windows

1. Extraer el ZIP completo, mantener ejecutable, DLL y data juntos. Abrir sin borrar datos anteriores.
2. Repetir álbum, cola, reproducción local, lista, búsqueda, orden y tamaño de ventana; comprobar salida/bandeja según preferencia.
3. La fuente inicial declara Android: no debe mostrar un acceso activo en Windows ni prometer reproducción de ese servicio.

## Alcance de verificación

Se registran las comprobaciones automatizadas/nativas y sus resultados finales en boveda/28 Pruebas 0.3.1 y mejoras 0.3.2.md. Estas pruebas manuales en teléfonos físicos quedan pendientes del usuario, especialmente gestos/tres botones y pantalla apagada prolongada.
