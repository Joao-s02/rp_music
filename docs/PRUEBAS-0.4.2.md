# Pruebas de RP Music 0.4.2

## Comprobaciones realizadas durante el desarrollo

El análisis estático de código y pruebas pasó. La comprobación directa con Flutter y audio simulado verificó la secuencia real, prioridades, duplicados, restauración pausada, pulsación larga, clic derecho y quitar y deshacer. El ejecutor estándar de Flutter no pudo iniciar las suites por una conexión local bloqueada.

## Recorrido físico pendiente

| Prueba | Resultado esperado |
| --- | --- |
| Actualizar Android sobre 0.4.1 y extraer la carpeta completa de Windows | La app abre la biblioteca existente y conserva los datos. |
| Añadir B y después C a continuación de A | A sigue sonando desde su posición y luego suena C antes de B. |
| Activar aleatorio y avanzar desde los audífonos o teclas multimedia | Suena la primera pista pendiente que muestra la cola. |
| Desactivar aleatorio después de editar | Vuelve el orden de origen de las pendientes con las ediciones manuales. |
| Añadir canciones repetidas y quitar una | Se quita solamente el turno elegido. Deshacer recupera ese turno. |
| Reordenar al terminar una pista y reiniciar la app | La app mantiene una cola coherente y restaura en pausa. |
