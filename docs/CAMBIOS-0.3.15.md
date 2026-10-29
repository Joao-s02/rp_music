# Cambios 0.3.15

- Android release retira REQUEST_INSTALL_PACKAGES y cambia las actualizaciones de la propia app a descarga oficial en navegador y apertura desde Archivos. Botones y mensajes se adaptan; abrir la descarga no pausa música.
- Firma propia de producción con transición compatible desde la identidad anterior; sin cambiar applicationId ni exigir desinstalación. Compilación de distribución rechaza credenciales ausentes.
- Se conservan funciones musicales, letras, descargas y extensiones. Windows se recompila con la misma versión; sin cambios en su motor de audio.
- Incluye el trabajo de firma del candidato 0.3.14, que no se publicó. La firma sola no resolvió el aviso.

Comparación controlada del universal 0.3.15: Play Protect bloqueó el control con permiso de instalación y aceptó como seguro el candidato sin él. Este último se instaló conservando fecha original y lista de prueba. El usuario después confirmó en su teléfono instalación directa sin aviso. No se desactivó Play Protect ni se envió apelación. No se promete idéntico resultado en todos los dispositivos; ARM64 es un binario distinto, verificado estructuralmente, sin análisis de Play Protect específico.

166 pruebas aprobadas, una optativa omitida y análisis limpio. Latencia API 3 Android, escucha prolongada y más dispositivos siguen pendientes. No se incluyen extensiones dentro de los binarios ni se modifican versiones anteriores.
