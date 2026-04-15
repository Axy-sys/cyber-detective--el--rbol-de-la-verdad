# Cyber Detective: El Árbol de la Verdad

## 🎯 Descripción del Proyecto
**Cyber Detective** es un entorno interactivo y videojuego de investigación y deducción desarrollado en **Godot 4**. El jugador asume el rol de un investigador cibernético de seguridad operando desde un entorno de escritorio táctico. Su misión principal es clasificar evidencias (Ley vs Crimen) e ir descubriendo y modelando la vasta estructura jerárquica de una red criminal de escala global.

## 🎓 Aspectos Destacados para la Evaluación Académica

A nivel técnico y de diseño de software, el proyecto fue construido aplicando diversos conceptos académicos avanzados para resolver problemas complejos de interfaz y gestión de estado:

### 1. Arquitectura tipo SPA (Single Page Application)
En lugar de cargar y destruir escenas (el comportamiento por defecto en muchos motores), el juego utiliza un contenedor principal llamado **`CentralOS`**. Este "Sistema Operativo" instancia y precarga todas las "aplicaciones" (Árbol, Evidencia, Chat, Radar) en memoria durante el inicio. Al navegar, simplemente se intercala la visibilidad de los nodos, preservando un ambiente ágil, ininterrumpido y permitiendo retener estados.

### 2. Estructuras de Datos: Árboles N-arios (N-ary Trees) y Recorridos (Traversal)
El sistema central recae en una implementación matemática de árboles de búsqueda/generación:
*   **Investigación y Nodos (`InvestigationTree`, `CrimeNode`):** La red criminal se modela de forma asimétrica. 
*   **Renderizado Recursivo y Geometría Procedural:** La vista `TreeView` recorre recursivamente el modelo de datos en memoria para crear y posicionar nodos en una grilla interactiva, trazando conexiones dinámicas usando Tesselación (`Curve2D`) y Trazado de Líneas en tiempo real (`Line2D`).

### 3. Patrones de Diseño Aplicados
*   **Patrón Observer (Eventos/Señales):** Modelos de datos (como `InventoryModel` y `InvestigationTree`) emiten señales a las Vistas cuando su estado interno cambia. Esto desacopla las interfaces de usuario de la lógica matemática.
*   **Singleton (Estado Global):** Se utiliza `GameManager` (Autoload) para persistir datos como el inventario actual de la partida, accesible desde cualquier vista de la arquitectura O.S. sin contaminación de referencias ("Spaghetti Code").
*   **MVC (Modelo-Vista-Controlador):** Los roles de los scripts están estrictamente separados en carpetas (`models/`, `views/`, `controllers/`).

### 4. Serialización y Persistencia (I/O)
Se implementó un sistema robusto de guardado y carga de partidas. Toda la estructura del árbol N-ario (con ramas y hojas asimétricas) y el inventario se convierten recursivamente en Diccionarios (JSON) y se almacenan usando el sistema de acceso a archivos (`FileAccess`) de Godot, permitiendo reconstruir instancias complejas a partir de un archivo serializado `.json`.

## 📂 Organización de Carpetas
*   `/models`: Entidades lógicas (Investigación, Nodos, Inventario).
*   `/views`: Nodos gráficos con la responsabilidad única de mostrar los Componentes de Usuario (IU) y recibir inputs. Controlado de forma reactiva.
*   `/controllers`: Orquestadores que resuelven los flujos (Ej: `DashboardController` reacciona cuando una evidencia es clasificada, modificando los modelos correspondientes).

## 💻 Entorno de Ejecución
*   **Motor:** Godot Engine 4.x
*   **Lenguaje:** GDScript (Tipado Estático opcional empleado)
