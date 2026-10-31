# Guía vigente

[Instalar y usar RP Music 0.3.16](USO-0.3.16.md).

## Candidato local: recuperación de biblioteca (A01)

No publicado. Si el principal contiene datos incompatibles, se intenta el respaldo antes de mostrar la biblioteca. Un guardado posterior conserva el archivo rechazado junto a los originales, como `library.json.rejected` (o con sufijo numérico), y no lo coloca sobre el respaldo válido.

Si ninguna copia sirve, aparece «No se pudo recuperar la biblioteca guardada. El guardado está bloqueado para conservar los archivos originales.» Cambiar ajustes o seleccionar de nuevo la carpeta no desbloquea ese guardado: se requiere recuperar una copia válida por separado. No borres ni sustituyas esos archivos para probarlo con tu biblioteca real. Esta corrección no añade una pantalla de reparación ni modifica archivos musicales.

Comprobación reproducible con datos sintéticos:

```sh
flutter test --no-pub --reporter expanded --concurrency=1 test/library_recovery_test.dart test/core_test.dart
```

Resultados y límites del candidato: [Biblioteca y reproducción](../boveda/03%20Biblioteca%20y%20reproduccion.md).
