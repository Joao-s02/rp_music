# RP Music 0.2.5 — guía de pruebas

Versión preliminar 0.2.5+7 para Android y Windows. Actualiza sobre 0.2.4 conservando tus datos. En Android instala encima sin desinstalar; en Windows extrae el ZIP completo en una carpeta nueva y abre rp_music.exe con sus DLL y data. Cierra la versión anterior desde Salir en bandeja antes de abrir la nueva.

## 1. Reproductor y títulos largos (Android y Windows)

En móvil pulsa título/carátula del minirreproductor; en Windows pulsa Abrir reproductor. La vista ampliada debe ocupar el área de la app completa. Una canción con título largo se mantiene en una línea y se desplaza para mostrarlo; los títulos cortos permanecen quietos. Prueba texto del sistema aumentado, cambiar de pista y cerrar/abrir la vista. Con reducir animaciones activado se muestra una línea con puntos suspensivos y el título completo queda disponible al lector de pantalla. En pantallas pequeñas se puede desplazar el contenido para acceder a todos los controles.

## 2. Notificación (solo Android)

Reproduce un archivo con carátula incrustada. Comprueba carátula, título, duración y acciones de anterior/reproducir/pausar/siguiente. Prueba cambiar rápidamente de canción y luego una pista sin imagen: no debe conservar la carátula anterior. Android y el fabricante determinan la composición final y pueden sustituir iconos de acciones estándar. Comprueba también pantalla de bloqueo y reproducción prolongada con pantalla apagada. No se añade integración multimedia del sistema Windows en esta versión.

## 3. Ajustes (Android y Windows)

Prueba Apariencia, Biblioteca y Actualizaciones; Android también muestra Reproducción en segundo plano. Verifica que las acciones tienen botones e iconos, tema claro/oscuro, cambiar carpeta y consulta manual de versiones. En Windows comprueba Seguir reproduciendo al cerrar la ventana y Salir desde bandeja.

## 4. Borrar un archivo (usar copias de prueba)

Copia dos o tres canciones prescindibles a una carpeta de prueba y selecciónala. Desde los tres puntos elige Eliminar del dispositivo. Primero cancela: archivo, favoritos y listas deben conservarse. Luego confirma: el archivo se borra permanentemente y se retira de biblioteca, favoritos, listas y cola. Comprueba tanto una pista detenida como la que estaba sonando; esta última debe detenerse. Los demás archivos deben conservarse. Quitar de la lista y Eliminar lista siguen conservando los archivos.

En Android, una carpeta elegida por versiones anteriores puede tener solo lectura. Si falla el borrado, vuelve a elegir la misma carpeta desde Ajustes → Biblioteca → Cambiar carpeta y concede escritura si el proveedor lo permite. Comprueba almacenamiento interno y SD. Si el sistema rechaza el borrado, el archivo y sus referencias deben seguir visibles. No todos los proveedores permiten eliminar documentos.

## 5. Actualizar desde 0.2.4

Con versiones de prueba activadas en Ajustes, busca actualizaciones. Android permite descargar, cancelar y verificar antes de abrir el instalador del sistema. Confirma allí y comprueba que se conservan carpeta, listas y favoritos. Windows ofrece el enlace a la descarga. La actualización automática completa entre releases públicas aún requiere prueba real del usuario; no se anuncia como comprobada por publicar esta release.

## Verificaciones y límites

46 pruebas unitarias/widgets aprobadas y análisis estático limpio. Prueba nativa Windows aprobada: cambios repetidos de pista, volumen, bandeja y borrado real de una pista cargada con limpieza de referencias y conservación de otros archivos. Windows release compilado en 0.2.5+7. Se usan archivos WAV sintéticos, no música privada. No se ha repetido aquí la prueba física Galaxy/Poco de carátulas/borrado SAF ni la reproducción prolongada. Siguen pendientes instalación Tecno y comportamiento de cierre con los archivos originales del usuario. Las notificaciones ya aparecen según el informe móvil de 0.2.4 del usuario.
