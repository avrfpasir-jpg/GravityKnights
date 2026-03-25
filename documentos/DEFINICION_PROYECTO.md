# Gravity Knights - Definición del Proyecto

## 🌌 Concepto General
**Gravity Knights** es un *Roguelike Deckbuilder* en vista isométrica que mezcla la exploración de mazmorras procedurales con un sistema de combate físico por turnos. El juego se ambienta en una fantasía oscura espacial donde el jugador se enfrenta a caballeros medievales galácticos.

## 🔄 Bucle de Juego (Core Loop)
1. **Exploración:** El jugador se mueve por salas (WASD/Joystick) en un mapa procedural estilo *The Binding of Isaac*.
2. **Combate por Turnos:** Al entrar en una sala con enemigos, se inicia el combate. 
   - El jugador roba 4 cartas por turno.
   - Las cartas se lanzan físicamente al escenario afectando a los enemigos según su masa, velocidad y tipo.
   - Al pasar turno, el enemigo realiza su acción (*Slay the Spire style*).
3. **Gestión de Mazo:** 
   - Si no se usa una carta, va al mazo de descarte.
   - Cuando el mazo principal se agota, se baraja el descarte para volver a empezar.
4. **Progresión:** Tras cada combate, se obtiene oro y nuevas cartas u objetos que generan sinergias.

## 🏆 Objetivo y Victoria
- Superar pisos con jefes intermedios.
- Múltiples finales dependiendo de las decisiones y acciones del jugador.
- **Plataforma:** PC.
