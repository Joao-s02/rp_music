# Pruebas de RP Music 0.3.18

## Comprobaciones de esta entrega

Análisis limpio y suite completa: 181 aprobadas, cero fallidas, una optativa omitida por paquete externo de metadatos no suministrado; ambos salida 0. Capturas previas conservadas (50 PNG). Verificación final adicional: 13 pruebas de navegación/caché/JS aprobadas y análisis limpio, ambos salida 0. Android universal y ARM64 compilados y firmados con identidad/linaje existentes, perfil sin instalador; Windows release normal compilado, todas las operaciones salida 0. Sin prueba física ni medición Android nueva. Las comprobaciones Flutter y builds se ejecutan de una en una. Los tests usan datos sintéticos; ninguna prueba de widgets equivale a un teléfono físico.

## Recorrido recomendado para el usuario

1. Actualiza sin desinstalar. Comprueba que conserva carpeta, favoritos, listas, ajustes y extensiones.
2. En Biblioteca → Álbumes abre uno y pulsa Atrás del teléfono. Debe volver a álbumes, conservando la app abierta.
3. En YouTube Explorador busca un artista, ábrelo y abre un álbum. Comprueba separación de filas, títulos largos y texto ampliado. Arrastra la lista: buscador/cabecera deben salir de la vista y volver al subir.
4. Pulsa Atrás: álbum → artista → resultados de búsqueda, sin esperar una consulta nueva.
5. Busca y cambia a Biblioteca local. Regresa a la misma fuente: comprueba texto, colección y desplazamiento. Repite en una pantalla JS instalada. Tras cerrar realmente la app la caché no tiene que conservarse.
6. Desactiva una extensión o retira permisos: no debe recuperar resultados antiguos al volver a activarla. Realiza una búsqueda nueva.
7. Android: compara la MISMA carpeta de 500 y 900 canciones con caché fría y caliente. Mide por separado primera pista visible y fin del escaneo. Anota teléfono, almacenamiento interno/SD, formatos y segundos. Debe mantener todos los archivos; etiquetas completadas sin pérdidas ni duplicados. La reducción de tiempo real sigue pendiente de esta prueba física.
8. Reproduce música local y de la fuente, revisa búsqueda, listas y reproducción de álbum. Comprueba notificación/widgets/SD si los utilizas. No se modificaron esos contratos.
9. Windows: extrae todo el ZIP y comprueba arranque, álbumes, caché de fuente, reproducción y cierre a bandeja. Android ARM64: verifica actualización sobre el universal sin desinstalar.

No simules corrupción ni falta de permisos borrando tu biblioteca real. A01 se comprueba mediante tests sintéticos y no incluye una pantalla de reparación.
