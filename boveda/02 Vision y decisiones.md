---
tipo: requisitos
estado: confirmado
actualizado: 2026-10-24
---
# Vision y decisiones

## Propósito

Crear un reproductor de música para una comunidad que pueda personalizarlo. Una aplicación base sencilla y de apariencia sencilla debe cubrir las funciones habituales; las extensiones permiten ampliar sus capacidades según los recursos y preferencias de cada usuario.

## Decisiones confirmadas

| Área | Decisión |
| --- | --- |
| Tecnología principal | Flutter; el usuario conoce Dart y Flutter. |
| Plataformas prioritarias | Android y Windows. |
| Web | Opcional; no condiciona la primera entrega. |
| Contenido base | Archivos musicales del dispositivo. |
| Conectividad base | Completamente sin internet y sin cuenta. |
| Público | Comunidad interesada en personalizar el reproductor. |
| Licencia y distribución | Código abierto; publicación en Play Store deseada a futuro. Licencia concreta pendiente. |
| Prioridad de optimización | Interfaz fluida al abrir biblioteca, reproducir y cambiar canciones. |
| Extensiones | Instalables sin reinstalar ni recompilar toda la app; reiniciar tras instalar es aceptable. |
| Actualizaciones de extensiones | Solo con aceptación del usuario. |
| Código actual | El usuario quiere reemplazar la versión alfa y empezar de cero. |
| Documentación | Crear primero una bóveda y mantenerla con todo contexto importante futuro. |

## Referencias visuales

- Spotify: le gusta el reproductor, pero quiere más personalización.
- Reproductor de Samsung: también le gusta, con la misma limitación de personalización.
- Namida: aprecia la presentación de carátulas y la agrupación automática por álbum.

Estas referencias orientan la experiencia; no se ha aprobado una maqueta ni un diseño visual concreto.

## Límites de lo decidido

No están elegidos el motor de audio, gestor de estado, persistencia, runtime de extensiones, lenguaje de sus programas ni licencia. No hay metas numéricas de rendimiento aceptadas. Las integraciones con servicios son objetivos sujetos a investigación, no capacidades garantizadas.

Detalles: [[03 Biblioteca y reproduccion]], [[04 Extensiones]], [[05 Rendimiento]], [[07 Preguntas e investigacion]]. Origen: [[08 Entrevista consolidada]].
