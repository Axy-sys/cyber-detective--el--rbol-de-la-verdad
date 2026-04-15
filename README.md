# Proyecto Académico: Cyber Detective - El Árbol de la Verdad

## 1. Resumen del Proyecto (Abstract)
**Cyber Detective: El Árbol de la Verdad** es un software interactivo desarrollado como herramienta de simulación de investigación cibernética. Construido sobre el motor **Godot 4.x**, el proyecto se focaliza en la aplicación práctica de Estructuras de Datos Avanzadas (Árboles N-arios), Patrones de Diseño de Software y Arquitecturas de Interfaz de Usuario Orientadas a Componentes.

El objetivo central del sistema es permitir al usuario (que asume el rol de investigador) analizar conjuntos de información en bruto (evidencias), clasificarlos algorítmicamente y visualizar en tiempo real una red criminal modelada matemáticamente a través de nodos interconectados.

---

## 2. Arquitectura de Software y Patrones de Diseño

Para garantizar la mantenibilidad, escalabilidad y la baja cohesión, el código fuente ha sido particionado bajo una estricta filosofía **MVC (Modelo-Vista-Controlador)** adaptada al ecosistema de Godot.

### 2.1. Patrón Modelo-Vista-Controlador (MVC)
*   **Modelos (`/models/`)**: Clases puras de abstracción de datos. Carentes de cualquier lógica de interfaz o despliegue visual. Implementan diccionarios, arrays y validaciones matemáticas. (Ej. `InventoryModel`, `CrimeNode`, `InvestigationTree`).
*   **Vistas (`/views/`)**: Jerarquías de Nodos UI (Interfaces Gráficas). Responsables únicamente de la captura de inputs del usuario y renderizado de píxeles basándose en las señales recibidas.
*   **Controladores (`/controllers/`)**: Orquestadores de mutación ("Bus de Eventos"). Escuchan la vista, aplican la lógica de negocio mutando el modelo subyacente (Ej. `DashboardController.gd`).

### 2.2 Patrón Singleton (Estado Global Restringido)
El sistema emplea un entorno de estado asíncrono instanciado al inicio de la aplicación a través del nodo autoloader `/root/GameManager`. Este patrón confina el estado global estricto (Inventario, Árbol del Proyecto y Sistema de I/O) previniendo el "Spaghetti Code" o acoplamiento cruzado de jerarquías de interfaz.

### 2.3 Patrón Observer (Escucha de Eventos Reactiva)
A nivel comunicacional, se evitan las llamadas síncronas bloqueantes entre módulos gráficos. En su lugar, los módulos se suscriben a **Señales** (Eventos estandarizados). 
*Ejemplo:* Cuando un Controlador muta el `InventoryModel`, este dispara la señal `evidence_added`. Cualquier vista en el O.S. (como el `EvidenceView`) suscrita a este evento repintará y reconstruirá automáticamente sus componentes gráficos, demostrando un sistema plenamente reactivo.

---

## 3. Soluciones Algorítmicas y Estructuras de Datos

### 3.1 Estructuras de Árboles N-arios (N-ary Trees)
El corazón del proyecto radica en un árbol jerárquico no binario (`InvestigationTree` y `CrimeNode`). Dado que una estructura criminal posee múltiples ramificaciones asimétricas, el modelado matemático debía soportar **N** hijos por nodo.
Esta abstracción permite aislar la información criminal por niveles de profundidad topológica y generar ramas de evidencia infinita.

### 3.2 Trazado y Renderizado Dinámico Recursivo
Para desplegar visualmente la información del modelo lógico, se implementó un sistema de dibujo dinámico transversal. A través de algoritmos recursivos (Ej. `_draw_node_recursive(...)` implícito en `TreeView.gd`), el motor despliega contenedores espaciados lógicamente según el número de hojas descendientes del caso actual. 
El trazado de las aristas o conexiones implementa la API de Curvas de Bézier paramétricas bidimensionales (`Curve2D`), generando teselaciones interpoladas para interconectar los nodos visuales (`Line2D`).

### 3.3 Arquitectura SPA (Single Page Application) e Instancia "CentralOS"
En contraposición a los diseños clásicos (donde el contexto es destruido transicionando de escena a escena, generando costosos manejos y fugas en RAM), este proyecto implementó una abstracción **SPA**. 
Mediante una Interfaz Maestra o Shell (el **CentralOS**), todas las "aplicaciones" internas (Árbol, Evidencia, Analizador, Chat) son cargadas interactivamente en segundo plano (`preload`) localizadas en un Diccionario Hash en Memoria. Permutarlas requiere un tiempo O(1) de procesamiento afectando solo la visibilidad renderizada, optimizando radicalmente el uso de la GPU mientras se persisten los estados en cada aplicación de forma nativa.

---

## 4. Persistencia de Datos e I/O Estructurado

### 4.1 Serialización Estructural N-aria sobre JSON
El guardado estático a disco requirió un algoritmo iterativo que asciende/desciende la complejidad del Árbol N-ario y el Inventario para transformar los objetos instanciados a tipos primitivos básicos (via interfaces polimórficas de `.to_dict()`). 
Usando la API abstracta de Archivos del motor (`FileAccess`), este estado topológico general es serializado finalmente en formato **JSON**. Para la carga del entorno, se emplea un modelado "Bottom-Up", parseando y emsamblando instantáneamente los objetos y readjuntándolos al Singleton de Gestión en un estado limpio.

---

## 5. Requisitos y Tecnologías Empleadas
*   **Motor Base de Renderizado y Lógica:** Godot Engine 4.x
*   **Lenguaje Formal de Programación:** GDScript 2.0 (Soportando tipado estricto por convención).
*   **Paradigmas Implementados:** Programación Orientada a Objetos (OOP), Programación Reactiva (Arquitectura Dirigida por Eventos) e Inyección Dinámica Multihilo.
