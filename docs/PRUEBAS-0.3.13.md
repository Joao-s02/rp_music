# Pruebas RP Music 0.3.13

164 pruebas aprobadas, una de red optativa omitida; análisis limpio. Nueve pruebas nuevas: conexión transitoria de metadatos, álbum verificado incrustado desde canción sin álbum, consentimiento conjunto/parcial y álbum adaptable a360/1280, fuentes a320 con texto1.6 y1280, movimiento reducido sin animación perpetua.

Cuatro paquetes reales API2 ejecutados con dart_eval. Álbum desconocido/conocido; edición estable ante orden invertido; campos opcionales ausentes/nulos; tolerancia pequeña de duración solo en identificación de álbum; rechazo de duración/interpretación incompatibles; lotes y LRC conservados. Detalles fallidos no borran el álbum oficial ya identificado.

Descarga nativa real Windows: canción llega con258000ms y sin álbum; metadatos oficiales admiten266560ms sin cambiar la elección de letras. Archivo M4A leído después de incrustar: Busca Una Mujer, pista5,55 líneas sincronizadas. Reproducción con avance>2s y solicitud de seek; bloques mdat comparados por SHA256 antes/después y conservados. Avisos conocidos no fatales de osc/caché multimedia. Audio y texto completo de prueba no se entregan.

Hubo intentos anteriores con TLS/503 y etiquetas parciales. Se verificaron por separado y motivaron un reintento limitado por etapa y conservación de álbum identificado. El resultado aprobado posterior devolvió ambos pasos de metadatos200. No se promete disponibilidad del proveedor.

Capturas Flutter revisadas de álbum/gestión/fuente genérica, en móvil y escritorio. No son prueba física Android ni juicio visual del usuario. Sin dispositivo Android conectado; escucha prolongada y valoración visual pendientes. Android universal/ARM64 y Windows se distribuyen junto a las guías y hashes.

## Pruebas del usuario

Actualizar sin desinstalar, actualizar paquetes externos y descargar una canción desde búsqueda sin abrir álbum: comprobar agrupación por álbum, artista de álbum, letra sincronizada y reproducción local. Repetir dos canciones del mismo álbum y una descarga de álbum completo. Probar cola más lenta y pausa, funda/animaciones de álbumes, catálogo/emblemas y Aceptar todo e instalar. Cancelar debe conservar el estado previo; Guardar desactivada admite permisos parciales. Probar fuentes a texto ampliado/con teclado y modo claro/oscuro. Escucha prolongada y Android físico pendientes.
