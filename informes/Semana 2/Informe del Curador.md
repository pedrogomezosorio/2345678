# Informe del Curador - Semana 2

**Integrantes:**
* Pedro Gomez Osorio
* Xabier Guitian Lopez
* Miguel Fraga Pico

---

## 1. Objetivos de Aprendizaje 

Esta semana, el objetivo fue implementar la lógica de negocio central y los flujos de usuario completos. Como traductor, definí estos objetivos de aprendizaje para el equipo:

* **Implementar CRUD Completo (Gastos):** Aprender a gestionar el ciclo de vida completo de los datos. No solo leer (Semana 1), sino también **Crear**, **Modificar** y **Borrar** (ej. `deleteFriend`). Esto incluye la gestión de formularios complejos para la entrada de datos.
* **Gestión de Formularios (Pagador/Participantes):** Aprender a construir formularios que manejen lógica condicional y selecciones múltiples (ej. quién pagó, quiénes participaron).
* **Vistas de Detalle:** Aprender a implementar la navegación a "vistas de detalle", pasando un ID (como un `friendId` o `expenseId`) para que la nueva pantalla pueda cargar y mostrar información específica de ese ítem (ej. ver los gastos de un solo amigo).
* **Cálculo de Datos Derivados (Balance):** Aprender a usar el `ViewModel` no solo para mostrar datos directos de la API, sino para calcular valores derivados (como el balance de un amigo) y mostrarlos en la vista.
* **Actualización de la UI post-Acción:** Aprender a refrescar la lista principal de forma reactiva (usando la gestión de estado de `Provider`) después de que un usuario crea, modifica o elimina un ítem.
* **Manejo de Errores (Tarea 2):** Como parte de estas implementaciones, aprender a capturar errores del `RestService` (ej. al borrar un gasto) y mostrar un mensaje claro al usuario usando un `AlertDialog` o similar.

---

## 2. Recursos Empleados (Curador)

Para alcanzar los objetivos de implementación (CRUD, Detalles, Balance), el equipo utilizó los siguientes recursos principales:

### 1. Flutter Navigation & Routing (Navegación y Formularios)

* **Descripción:** Documentación oficial sobre cómo navegar entre diferentes pantallas (Vistas) y cómo pasar argumentos (como el ID de un gasto) a la nueva ruta.
* **Enlace:** `https://docs.flutter.dev/cookbook/navigation/navigation-basics`
* **Utilidad en la Práctica:** Fundamental para implementar el "Ver Detalle" de amigos y gastos, y para abrir el formulario de "Crear/Modificar Gasto".

### 2. Flutter Forms Cookbook (Formularios y Selección)

* **Descripción:** Guías oficiales sobre cómo crear formularios con validación, `TextFields`, `DropdownButton` (para el pagador) y `CheckboxListTile` (para los participantes).
* **Enlace:** `https://docs.flutter.dev/cookbook/forms/handling-changes`
* **Utilidad en la Práctica:** Se usó como referencia directa para construir el `ExpenseFormView` y gestionar la selección del pagador y los múltiples participantes.

### 3. Documentación del paquete `http` y `provider`

* **Descripción:** La documentación de los paquetes que usamos para la red y la gestión de estado.
* **Enlace:** `https_://pub.dev/packages/http` y `https_://pub.dev/packages/provider`
* **Utilidad en la Práctica:** El paquete `http` fue clave para implementar las llamadas de `POST`, `PUT` y `DELETE` en nuestro `RestService`. El paquete `provider` fue esencial para que el `ViewModel` pudiera notificar a la vista que debía recargarse después de un borrado o una creación.

### 4. Flutter `AlertDialog` Class (Diálogos de Confirmación)

* **Descripción:** La documentación oficial del widget `AlertDialog`.
* **Enlace:** `https://api.flutter.dev/flutter/material/AlertDialog-class.html`
* **Utilidad en la Práctica:** Se usó para preguntar al usuario "¿Estás seguro?" antes de ejecutar acciones destructivas como "Borrar Gasto" o "Borrar Amigo", y también para mostrar los mensajes de error provenientes del servidor.