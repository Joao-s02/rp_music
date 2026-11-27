# Guía de uso

[Instalar y usar RP Music 0.4.0](USO-0.4.0.md).

## RP Music 0.4.0

Escucha la biblioteca local desde Biblioteca, Favoritos y Listas. Letras lee las incrustadas y permite importar LRC/TXT. Las letras de la antigua búsqueda en línea identificadas por su marca de origen se eliminan del almacenamiento privado al arrancar esta versión.

En **Ajustes → Apariencia → Temas**, importa un archivo `.rptheme` o instala Minimalista desde el catálogo de prueba. El tema se aplica a toda la app. Pulsa **RP Music** para volver al aspecto predeterminado o usa la papelera para quitar un tema instalado. [Crear un tema](TEMAS.md).

La versión tiene pruebas automatizadas y compilaciones verificadas. La actualización real y las pruebas de escucha en dispositivos siguen pendientes.

## Recuperación de biblioteca (A01), incluida en 0.3.18

Si el principal contiene datos incompatibles, se intenta el respaldo antes de mostrar la biblioteca. Un guardado posterior conserva el archivo rechazado junto a los originales, como `library.json.rejected` (o con sufijo numérico), y no lo coloca sobre el respaldo válido.

Si ninguna copia sirve, aparece «No se pudo recuperar la biblioteca guardada. El guardado está bloqueado para conservar los archivos originales.» Cambiar ajustes o seleccionar de nuevo la carpeta no desbloquea ese guardado: se requiere recuperar una copia válida por separado. No borres ni sustituyas esos archivos para probarlo con tu biblioteca real. Esta corrección no añade una pantalla de reparación ni modifica archivos musicales.

Comprobación reproducible con datos sintéticos:

```sh
flutter test --no-pub --reporter expanded --concurrency=1 test/library_recovery_test.dart test/core_test.dart
```

[Pruebas y límites de la entrega](PRUEBAS-0.3.20.md).
