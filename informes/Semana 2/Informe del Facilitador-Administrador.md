# INTERFACES PERSONA-MÁQUINA
# Informe del Facilitador-Administrador - Semana 2

**Integrantes:**
* Pedro Gomez Osorio
* Xabier Guitian Lopez
* Miguel Fraga Pico

---

## 1. Resumen y Alcance Acordado

El objetivo principal de esta semana fue **completar la Tarea 1: Diseño e Implementación**, centrándonos en la construcción de la interfaz de usuario.

Como facilitador, coordiné al equipo para asegurar que la implementación de Flutter se alineara con los diseños y se corrigieran los artefactos de diseño (diagramas y mockups) basándonos en los hallazgos de la implementación inicial. El alcance de la semana fue:
1.  Implementar las vistas principales (Móvil) en Flutter.
2.  Asegurar que el diseño fuera adaptativo (Tablet).
3.  Corregir los documentos de diseño (`diseño_sw.md` y `diseño-iu.pdf`) para que coincidieran con la implementación final.

---

## 2. Registro de lo Realizado Esta Semana

El equipo ha completado exitosamente la Tarea 1. Los logros específicos de esta semana son:

* **Implementación del Diseño Móvil:** Se ha desarrollado la interfaz de usuario principal para dispositivos móviles. Esto incluye la `FriendsView`, `ExpensesView` y los formularios de creación/edición (`ExpenseFormView`), siguiendo el patrón MVVM.

* **Implementación del Diseño de Tablet (Adaptativo):** La implementación se ha realizado utilizando widgets de Flutter que permiten un diseño adaptativo. Las vistas se escalan y reorganizan correctamente en pantallas de mayor tamaño, como tablets, cumpliendo con los requisitos de un diseño responsive.

* **Corrección de Diagramas:** Se han revisado y corregido los diagramas de clases y de secuencia en el `diseño_sw.md`. Las correcciones reflejan la estructura final de la arquitectura MVVM implementada en Flutter (ej. el uso de `ChangeNotifier` en los ViewModels).

* **Corrección del Diseño de Tablet:** Se actualizaron los mockups en el `diseño-iu.pdf` para alinear el diseño conceptual de la tablet con el resultado final de la implementación, asegurando la coherencia entre el diseño y el producto.

---

## 3. Asignación de Responsables (Acordado por el Equipo)

La distribución de tareas se gestionó de la siguiente manera:

* **Implementación de Vistas Móvil/Tablet (Flutter):** Pedro Gomez Osorio y Miguel Fraga Pico.
* **Corrección de Documentos de Diseño (Diagramas y UI Tablet):** Xabier Guitian Lopez.
* **Coordinación y Revisión (Facilitador):** Mi rol fue asegurar que las correcciones de diseño se comunicaran a los implementadores y que la implementación cumpliera con los diseños actualizados.

---

## 4. Estado de Completitud (Estimación)

* **Tarea 1 (Diseño e Implementación):** 100% completada. Los documentos están actualizados y la aplicación es funcional en ambos factores de forma (móvil/tablet).

---

## 5. Dinámica del Equipo y Observaciones

El equipo ha trabajado de forma muy cohesionada. La implementación en Flutter (Dart) presentó los desafíos esperados, pero el equipo los superó eficazmente. La decisión de corregir los diagramas *después* de la implementación inicial (en lugar de antes) resultó ser eficiente, ya que los diagramas ahora reflejan la realidad del código. No se han reportado conflictos.

---

## 6. Próximos Pasos y Compromisos para la Semana 3

Con la Tarea 1 finalizada, el equipo se centrará en la **Tarea 2: Gestión de la concurrencia y la E/S**.

* **Objetivo:** Implementar la gestión de errores del servidor y asegurar que la aplicación no se bloquee durante las llamadas de red (concurrencia).
* **Plan:**
    * Modificar el `RestService` para capturar errores HTTP.
    * Utilizar la clase `Result` para pasar los errores al `ViewModel`.
    * Mostrar indicadores de carga (`CircularProgressIndicator`) y mensajes de error en las Vistas.

---

## 7. Estado General del Repositorio (Visión Funcional)

El repositorio está completo y al día con respecto a la Tarea 1. Todos los informes de la Semana 1 están presentes, junto con los documentos de diseño actualizados y el código fuente funcional de Flutter.