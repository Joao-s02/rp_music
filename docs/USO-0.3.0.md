# RP Music 0.3.0+9 — release experimental

Release v0.3.0-alpha.1: añade programas Dart instalables y catálogo GitHub. Instalar el APK sobre la anterior sin desinstalar; en Windows, cerrar la anterior desde Salir en bandeja, extraer todo el ZIP y ejecutar rp_music.exe junto a sus DLL/data.

Para probar la primera extensión, abre **Extensiones → Explorar repositorio → Consultar → Biblioteca viva**, revisa y acepta sus permisos, y vuelve a Biblioteca. Filtros combinados permite seleccionar artista, álbum, carpeta, duración y favoritos. Puedes reproducir resultados y crear listas manuales o automáticas.

En Listas, abre una lista y pulsa Cambiar carátula para elegir imagen propia o mosaico. Las listas automáticas se recalculan al actualizar catálogo/favoritos; desactivar su proveedor conserva datos y carátula sin seguir ejecutándolo.

**Pulso nocturno** es un segundo ejemplo avanzado: controles antes de carátula y aleatorio que prefiere otro artista. Se puede activar junto a Biblioteca viva, y elegir qué programa controla cada función. Para ver su política de canciones hay que activar Aleatorio.

Volver a la base · modo seguro restaura controles de la app y desactiva programas. No borra música ni listas. Se conservan también los manifiestos declarativos API 1.

El SDK inicial tiene componentes visuales limitados y no expone red ni escritura de música. Los límites de tiempo/importación no son una cuota dura de memoria; usar solo ejemplos o archivos de confianza en este prototipo. No es todavía el sistema completo de extensiones de la visión del proyecto.

Consulta PRUEBAS-0.3.0.md para el recorrido de prueba y EXTENSIONES-API-2.md si quieres editar un ejemplo. Los paquetes se distribuyen en el repositorio separado, no dentro del APK. También se pueden importar como archivos `.rpmx` sin reinstalar la app.


El catálogo indica Instalada si ya tienes una versión igual o superior y Actualizar cuando hay una superior. YouTube Music requiere la 0.3.1 Android separada; no forma parte de esta release.
