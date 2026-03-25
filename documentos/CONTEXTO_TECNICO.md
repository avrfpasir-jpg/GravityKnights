# Gravity Knights - Contexto Técnico

## 🛠 Stack Tecnológico
- **Motor:** Godot 4.3 (Forward+ Renderer).
- **Lenguaje:** GDScript 2.0.
- **Físicas:** 3D con gravedad cero simulada (`gravity_scale = 0.0`).

## 🏗 Arquitectura de Datos
El juego utiliza un sistema basado en **Resources** para facilitar la creación de contenido:
- `CardData.gd`: Define las propiedades físicas de las cartas (masa, rebote, fricción, coste de energía, tipo).
- `LauncherUI.gd`: Gestiona la entrada del jugador para el "Drag & Shoot".

## 🎮 Escenas Principales
- `Main.tscn`: Escena de combate/exploración principal.
- `GameManager.gd`: Gestor de turnos, energía y estado del juego.
- `Projectile.tscn`: La entidad física de la carta una vez lanzada.
- `Launcher.tscn`: El arco/indicador de trayectoria.

## 📋 Pendientes (Roadmap Técnico)
- [ ] Generación procedural de salas.
- [ ] Lógica de barajado y descarte de mazo.
- [ ] IA básica para los caballeros espaciales (Enemies).
- [ ] Sistema de inventario y sinergia de objetos.
