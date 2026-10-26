---
tipo: requisitos-y-propuesta
estado: requisitos-confirmados-diseno-pendiente
actualizado: 2026-10-25
---
# Extensiones - alcance del primer sistema

Esta nota concreta la entrevista posterior a 0.2.5 sin elegir todavía un runtime ni afirmar que exista un sistema programable. Complementa [[04 Extensiones]]; no sustituye el objetivo de libertad visual/funcional de Android y Windows.

## Requisitos confirmados en esta conversación

- El agente creará las primeras extensiones. Primera demostración programable: biblioteca personalizada con filtros combinables por artista, álbum, carpeta, duración y favoritos; reproducir resultados, mezclarlos y añadirlos a una lista. El usuario acepta la propuesta y añade carátulas propias para cada lista.
- Carátulas: elegir una imagen propia del dispositivo y mosaico automático de canciones, ambas opciones.
- Listas automáticas desde la primera entrega: cambian al añadir canciones al catálogo. El escaneo base sigue siendo manual; recalcular reglas cuando cambie el catálogo no equivale a aprobar vigilancia continua del sistema de archivos.
- Varias extensiones activas desde la primera entrega. El usuario elige quién controla una pantalla o función cuando exista conflicto; no decidir silenciosamente por orden de carga.
- Permisos normales separados: leer biblioteca, controlar reproducción, internet y guardar datos propios. Modificar/borrar archivos musicales requiere autorización adicional. El acceso avanzado no equivale a aprobar acceso general a cuentas, sistema operativo o cualquier archivo.
- Nivel avanzado: añadir funciones y botones, reorganizar/cambiar comportamientos de la base. Ejemplos concretos del usuario: reemplazar pantalla del reproductor, cambiar el aleatorio y cómo funcionan las listas.
- Instalación inicial por archivo; catálogo después. Instalar sin recompilar la aplicación sigue confirmado por la entrevista original. Actualizaciones solo aceptadas por el usuario.
- Modo de recuperación, volver a la base y desactivar extensiones con fallos repetidos: aceptados. Umbrales exactos todavía son diseño.
- Desactivar una extensión conserva listas normales y carátulas. Las listas automáticas de su propiedad quedan guardadas e inactivas hasta reactivarla; no borrar datos por desactivar.

## Propuesta para convertirlo en contrato comprobable

Estas son propuestas de diseño, no APIs implementadas ni decisiones de lenguaje:

1. Puntos de extensión para biblioteca, reproductor, política de aleatorio y operaciones de listas. Sustituir comportamiento mediante esos contratos, en vez de permitir reescribir arbitrariamente el código compilado instalado.
2. La base conserva propiedad de reproducción/servicio del sistema y de los datos musicales; cada extensión accede mediante operaciones autorizadas. Una pantalla de reproductor propia debe seguir reflejándose en notificación/widget sin duplicar motores.
3. Distinguir permiso de gestionar listas/carátulas de permiso de modificar/borrar archivos musicales. Dar a una extensión permiso de editar listas no debe autorizar eliminación de música. Definir alcance de lectura de metadatos/IDs sin revelar rutas innecesarias.
4. Identidad estable por extensión/versión, versión del contrato, capacidades requeridas, dependencias y titularidad de datos. Guardar imágenes elegidas en almacenamiento de la app para que no dependan de una ruta temporal; límites de imagen/tamaño pendientes de diseño.
5. Selector por función para conflictos. Estado claro de activa, desactivada, incompatible, en recuperación o sin permiso. Volver a la base siempre accesible aunque una pantalla aportada falle.
6. Reglas de listas automáticas persistidas como datos; cambiar reglas no modifica los archivos originales. Al desactivar su proveedor se conservan definición y última composición, sin seguir ejecutándolo.
7. Primera validación real en Android y Windows: instalar archivo sin recompilar, abrir biblioteca propia, filtrar, crear lista automática y carátulas; instalar una segunda extensión compatible y elegir conflictos; simular fallo, retirar permiso, desactivar y restaurar datos.

## Investigación y decisiones técnicas pendientes

Elegir runtime/lenguaje y representación de pantallas tras comparar ejecución real de lógica, aislamiento, interrupción de bucles, límites, canales entre extensiones, rendimiento y compatibilidad de ambas plataformas. No se prometen todas las capacidades de Dart ni carga de código nativo descargado. La entrevista de esta ronda queda suficientemente concreta para investigar y diseñar el prototipo; las siguientes preguntas deben referirse a decisiones detectadas por esa investigación, sin repetir los requisitos ya aceptados. Resolver formatos de reglas/paquetes, control de versiones, permisos por extensión, migraciones y métricas atribuibles. La propuesta de contratos no significa que el SDK esté implementado.

## Estado comprobado

El código actual sigue usando ExtensionManifest v1 declarativo: dos disposiciones de biblioteca, acento y acción aleatoria predefinida. No ejecuta lógica de terceros ni permite aún carátulas de lista, reglas automáticas, varias extensiones de pantalla activas o sustitución del reproductor. Esta entrevista define el siguiente trabajo; las mejoras locales 0.2.6 de [[21 Pruebas 0.2.5 y mejoras 0.2.6]] no se anuncian como implementación de ese sistema.

Relaciones: [[04 Extensiones]], [[06 Primera version]], [[07 Preguntas e investigacion]], [[05 Rendimiento]], [[09 Registro de cambios]].
