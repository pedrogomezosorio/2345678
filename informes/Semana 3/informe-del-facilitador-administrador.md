# INTERFACES PERSONA-MÁQUINA
# Informe del Facilitador-Administrador - Semana 3

**Integrantes:**
* Pedro Gomez Osorio
* Xabier Guitian Lopez
* Miguel Fraga Pico

---

## 1. Resumen y Alcance Acordado

El objetivo de esta semana ha sido asegurar la calidad y robustez de la aplicación mediante la **Tarea 3: Test End-to-End (E2E)**.

Como facilitador, coordiné la estrategia de pruebas para cumplir con los requisitos: validar los flujos principales de usuario (crear amigos/gastos) y, crucialmente, verificar que la aplicación responde correctamente ante situaciones de error (fallos de red y errores de validación), todo ello simulado a través de la interfaz gráfica.

---

## 2. Registro de lo Realizado Esta Semana

El equipo ha implementado una suite de pruebas de integración completa:

* **Infraestructura de Testing:** Se configuró el entorno de `flutter_test` para permitir la ejecución de pruebas de widgets que simulan la interacción real del usuario.
* **Mocking de Repositorios:** Se implementaron clases `Mock` para `FriendRepository` y `ExpenseRepository`. Esto ha sido fundamental para:
    * Desacoplar los tests del backend real.
    * Simular determinísticamente errores de E/S (excepciones de red) bajo demanda (flag `shouldFail`).
* **Tests de "Camino Feliz" (Happy Path):** Se implementaron tests E2E que recorren el flujo de creación de un amigo, verificando que el diálogo aparece, se rellena y la lista se actualiza correctamente.
* **Tests de Gestión de Errores (E/S):** Se creó un escenario de prueba donde el repositorio simula un fallo de red, verificando que la UI muestra el feedback adecuado (ej. SnackBar de error) en lugar de bloquearse.
* **Tests de Errores de Usuario:** Se validó que el formulario impide guardar datos vacíos y muestra los mensajes de validación correspondientes.

---

## 3. Asignación de Responsables

* **Diseño de la Estrategia de Pruebas:** Pedro Gómez (Definición de casos a probar: Happy Path vs Edge Cases).
* **Implementación de Mocks y Lógica de Test:** Xabier Guitián (Creación de los MockRepositories y configuración del `setUp`).
* **Implementación de Tests de UI (WidgetTester):** Miguel Fraga (Escritura de los tests E2E usando `finder`, `tap` y `pumpAndSettle`).
* **Coordinación:** Mi rol ha sido asegurar que los tests cubrían tanto los requisitos funcionales como los de robustez (errores).

---

## 4. Estado de Completitud

* **Tarea 3 (Tests E2E):** 100% completada. Tenemos un archivo `app_flow_test.dart` que valida los casos de uso críticos y los escenarios de error.

---

## 5. Dinámica del Equipo

La dinámica ha sido positiva. La principal dificultad fue entender cómo inyectar los repositorios falsos (Mocks) en el árbol de widgets para que la aplicación los usara en lugar de los reales durante los tests. Se resolvió eficazmente usando `Provider.value` en la configuración del test.

---

## 6. Próximos Pasos

Con las tres tareas finalizadas (Diseño/Impl, Concurrencia, Testing), el equipo se centrará en la **revisión final del repositorio**, limpieza de código, y preparación de la entrega y defensa del proyecto.