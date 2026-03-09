Motor Lógico Híbrido (C / Ensamblador x86)

Este proyecto es un juego de “5 en raya” que se juega en un tablero de 10x10. Utiliza una arquitectura de software híbrida. El objetivo principal es implementar la lógica crítica y el cálculo de memoria a bajo nivel con Ensamblador (Intel x86). La interfaz y el bucle de eventos principal se gestionan desde C.

Desarrollado como proyecto para la asignatura de Estructura de Computadores en la Universitat Autònoma de Barcelona (UAB).

Características Principales

- Arquitectura Mixta (C + ASM): Interacción fluida entre rutinas de alto nivel (C) y subrutinas críticas de bajo nivel (Ensamblador x86). Se respetan las convenciones de paso de parámetros a través de la pila.

- Cálculo de Memoria Manual: Se navega por matrices bidimensionales (tablero 10x10) en Ensamblador. Se calculan desplazamientos de memoria directos.

- Algoritmia de Validación a Bajo Nivel: Algoritmos programados en x86 para detectar vecinos interactuables. Se comprueban condiciones de victoria (5 fichas consecutivas en horizontal, vertical y diagonal).

- Gestión de Registros y Pila: Control exhaustivo de los registros de propósito general de la CPU. Se preserva el estado con push y pop.

Tecnologías y Herramientas

- Lenguajes: Ensamblador (Intel x86), C

- Entorno de Desarrollo: Microsoft Visual Studio

- Arquitectura Target: 32-bits (x86)

Retos Técnicos Superados

El mayor desafío fue la manipulación segura de la memoria. Se integraron lenguajes de programación. Se implementaron algoritmos de búsqueda espacial sobre la matriz de juego. Se interactuó directamente con la memoria. Se aseguró que no se produjeran accesos fuera de los límites del tablero.

Además, fue crítico gestionar correctamente los flags de estado del procesador. Se gestionaron los saltos condicionales (jmp, je, cmp). Se creó un bucle de validación eficiente en la detección de las condiciones de victoria.

---

*Desarrollado por Víctor Segura - Estudiante de Ingeniería Informática en la UAB.*
