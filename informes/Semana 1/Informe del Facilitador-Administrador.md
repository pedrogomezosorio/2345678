# INTERFACES PERSONA-MÁQUINA
# Informe del Facilitador-Administrador - Semana 1

**Integrantes:**
* Pedro Gomez Osorio
* Xabier Guitian Lopez
* Miguel Fraga Pico

---

## 1. Resumen y Alcance Acordado

El objetivo de esta primera semana fue establecer las bases del proyecto, completando la **Tarea 1: Diseño software e implementación**. Como facilitador, coordiné la definición del alcance funcional basándonos en el `enunciado.md`.

El equipo consensuó los 8 casos de uso principales (UC-01 a UC-08) y el diseño de la interfaz de usuario, los cuales fueron documentados y entregados en el fichero `diseño-iu.pdf`.

---

## 2. Registro de lo Realizado Esta Semana

El equipo ha completado los siguientes hitos fundacionales:

* **Patrón Arquitectónico:** Se seleccionó el patrón **MVVM (Model-View-ViewModel)**. Esta decisión se tomó por su excelente integración con frameworks reactivos como Flutter, permitiendo una clara separación entre la lógica de estado y la interfaz de usuario.
* **Diseño de Software:** Se generó el documento `diseño_sw.md`, detallando la arquitectura MVVM con diagramas de clases y de secuencia en formato Mermaid.
* **Estructura del Proyecto (Flutter):** Se creó la estructura de directorios de la aplicación Flutter.
* **Capa de Modelo y Servicios:** Se definieron los modelos de datos (ej. `Friend`, `Expense`) y la capa de acceso a datos, incluyendo la interfaz `Repository` y la implementación `RestService` para la comunicación con la API.
* **Implementación Inicial:** Se implementó la primera vista funcional, `FriendsView`, conectada a su `FriendsViewModel`, logrando mostrar datos (simulados o reales) del servicio.

---

## 3. Asignación de Responsables (Acordado por el Equipo)

La distribución de tareas para esta fase inicial fue la siguiente:

* **Diseño de UI y SW (Documentación):** La definición de casos de uso y la creación de los diagramas UML fue un esfuerzo colaborativo del equipo.
* **Arquitectura y Capa de Datos:** Pedro Gómez Osorio se encargó de establecer la arquitectura MVVM, definir los modelos y la capa de servicios (`RestService`, `Repository`).
* **Implementación de Vistas (UI/ViewModel):** Xabier Guitian Lopez y Miguel Fraga Pico se centraron en la implementación de la interfaz de usuario en Flutter, desarrollando la vista de Amigos y su ViewModel.
* **Coordinación y Revisión:** Como Facilitador, mi labor fue asegurar que la implementación fuera coherente con el diseño y que el equipo avanzara alineado.

---

## 4. Estado de Completitud (Estimación)

* **Diseño de IU (Casos de uso y mockups):** 100%
* **Diseño SW (Patrón y diagramas):** 100%
* **Implementación (Tarea 1):** 30% (Vista de Amigos funcional. Pendientes las vistas de Gastos y Balance).

---

## 5. Dinámica del Equipo y Observaciones

La primera semana ha sido productiva. Como se esperaba, la principal dificultad fue la curva de aprendizaje inicial de Dart y el patrón MVVM, tal como se refleja en la retrospectiva del analista.

El equipo ha mostrado una excelente actitud y adaptación. La comunicación ha sido constante y no se han reportado conflictos. El ánimo es positivo para afrontar la siguiente tarea.

---

## 6. Próximos Pasos y Compromisos para la Semana 2

El objetivo para la Semana 2 es abordar la **Tarea 2: Gestión de la concurrencia y la E/S**, según el enunciado.

* **Identificar operaciones bloqueantes:** Se confirma que son todas las llamadas al `RestService`.
* **Implementar concurrencia:** Asegurar que las llamadas de red se realicen de forma asíncrona (Flutter lo facilita con `Future` y `async/await`).
* **Gestión de errores:** Implementar la captura de errores del servidor (HTTP 404, 500, etc.) y mostrar mensajes claros al usuario. El `Result` class será clave.
* **Continuar implementación:** Desarrollar las vistas de Gastos y Balance, aplicando ya estos principios de robustez.

---

## 7. Estado General del Repositorio (Visión Funcional)

El repositorio está organizado y contiene todos los entregables de diseño de la Tarea 1. La implementación de Flutter está iniciada, es funcional para la vista de Amigos y sigue la arquitectura MVVM definida. El proyecto está en un estado saludable para comenzar la Tarea 2.