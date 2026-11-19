# Pruebas de RP Music 0.4.5

El análisis Dart, la compilación del canal Kotlin y la sonda local a 360 px pasaron. La sonda comprobó el menú, los gestos, la navegación al álbum, el menú de listas, el temporizador simulado, el aviso de cola y la reutilización de miniaturas.

Pruebas pendientes en los dispositivos de uso:

1. Actualiza Android sobre la 0.4.4 y verifica que se conservan catálogo, favoritos y listas. En Windows extrae el ZIP completo.
2. En el reproductor, abre los tres puntos y prueba álbum, ecualizador, detalles y temporizador de un minuto. Comprueba que la música se pausa al vencer.
3. Desliza hacia arriba y abajo desde la carátula. Abre los detalles y desliza hacia abajo. Añade y quita pistas para ver que Deshacer desaparece a los cuatro segundos.
4. Mantén pulsada una lista. Verifica portada, nombre y acciones. Comprueba las cabeceras y el orden en móvil.
5. Añade una canción en la carpeta y abre la app desde cero. Compara la carga de carátulas en el primer recorrido y al reabrir la app.
6. En el Redmi, prueba el selector sin auriculares, con Bluetooth y al desconectarlo.
