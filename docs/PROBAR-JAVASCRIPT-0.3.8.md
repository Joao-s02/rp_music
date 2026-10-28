# Prueba de JavaScript en 0.3.8 — Dart conservado

Distribución preliminar 0.3.8-alpha.1. Instala el APK universal encima de 0.3.7 sin desinstalar. Windows: extrae todo el ZIP y ejecuta rp_music.exe junto a sus DLL/data. Conserva datos/listas/extensiones. La extensión Laboratorio JS se entrega por separado desde el repositorio de extensiones; no viene dentro de los binarios.

1. Extensiones → Importar archivo → laboratorio-js.rpmx. Acepta navegación, estado privado, lectura de metadatos y control de reproducción.
2. Pulsa Abrir pantalla en su tarjeta, o abre su acceso de navegación. No elijas otra Fuente: Laboratorio no reemplaza YouTube.
3. Escribe un apodo, guarda el saludo y abre Mi panel. Suma/resta el contador y vuelve al inicio. Cierra y abre la app: comprueba que los datos se conservan.
4. Abre Biblioteca, busca título/artista y reproduce una canción local. La extensión ve hasta 500 canciones y muestra hasta ocho resultados, usando IDs opacos sin rutas.
5. Desactiva Laboratorio: su pantalla debe quedar inaccesible y los datos deben conservarse para reactivarla.
6. Prueba YouTube Android 0.4.0 y Explorador 0.1.0 como antes: buscar/reproducir/descargar y cambiar de fuente. Los paquetes existentes no se han convertido ni modificado.

La pantalla, navegación interna y acciones de la demo están en JavaScript. La app aporta componentes nativos combinables y servicios con permisos. No es Node.js ni HTML/CSS libre; no permite paquetes npm, red, login o sincronización en API 3 todavía. Audio, notificación y widget siguen en el reproductor base.

Verificaciones: motor QuickJS nativo en Windows, interfaz 360 px, persistencia, revocación, paquetes reales Dart y bucle interrumpido en unos 1037 ms; suite completa inicial120 aprobadas/una red optativa omitida. Cierre final en la bóveda. No hay dispositivo Android conectado; APK compilado no equivale a prueba física de esta variante.
